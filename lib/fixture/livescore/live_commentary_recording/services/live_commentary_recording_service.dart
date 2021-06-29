import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:either_option/either_option.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../account/services/account_service.dart';
import '../enums/live_commentary_recording_entry_status.dart';
import '../enums/live_commentary_recording_status.dart';
import '../interfaces/ilive_commentary_recording_api_service.dart';
import '../models/dto/live_commentary_recording_entry_dto.dart';
import '../models/entities/live_commentary_recording_entry_entity.dart';
import '../models/vm/live_commentary_recording_entry_vm.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/connection_error.dart';
import '../../../../general/errors/server_error.dart';
import '../../../../general/interfaces/iimage_service.dart';
import '../../../../general/utils/policy.dart';
import '../models/vm/live_commentary_recording_vm.dart';
import '../../../../general/persistence/storage.dart';
import '../../../../general/errors/error.dart';

class LiveCommentaryRecordingService {
  final Storage _storage;
  final ILiveCommentaryRecordingApiService _liveCommentaryRecordingApiService;
  final IImageService _imageService;
  final AccountService _accountService;

  final Map<String, bool> _liveCommRecordingIdentifierToIsInPublishMode = {};

  Policy _wsApiPolicy;
  Policy _apiPolicy;

  LiveCommentaryRecordingService(
    this._storage,
    this._liveCommentaryRecordingApiService,
    this._imageService,
    this._accountService,
  ) {
    _wsApiPolicy = PolicyBuilder().on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    ).build();

    _apiPolicy = PolicyBuilder().on<ConnectionError>(
      strategies: [
        When(
          any,
          repeat: 1,
          withInterval: (_) => Duration(milliseconds: 200),
        ),
      ],
    ).on<ServerError>(
      strategies: [
        When(
          any,
          repeat: 3,
          withInterval: (attempt) => Duration(
            milliseconds: 200 * pow(2, attempt),
          ),
        ),
      ],
    ).on<AuthenticationTokenExpiredError>(
      strategies: [
        When(
          any,
          repeat: 1,
          afterDoing: _accountService.refreshAccessToken,
        ),
      ],
    ).build();
  }

  Future<Either<Error, LiveCommentaryRecordingVm>> loadLiveCommentaryRecording(
    int fixtureId,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var recording = await _storage.loadLiveCommentaryRecordingOfFixture(
        fixtureId,
        currentTeam.id,
      );

      var liveCommRecordingIdentifier =
          'fixture:$fixtureId.team:${currentTeam.id}';

      if (!_liveCommRecordingIdentifierToIsInPublishMode.containsKey(
        liveCommRecordingIdentifier,
      )) {
        _liveCommRecordingIdentifierToIsInPublishMode[
            liveCommRecordingIdentifier] = false;
      }

      return Right(
        LiveCommentaryRecordingVm.fromEntity(
          recording,
          _liveCommRecordingIdentifierToIsInPublishMode[
              liveCommRecordingIdentifier],
        ),
      );
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      return Left(Error(error.toString()));
    }
  }

  Future<Option<Error>> renameLiveCommentaryRecording(
    int fixtureId,
    String name,
  ) async {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      await _storage.renameLiveCommentaryRecordingOfFixture(
        fixtureId,
        currentTeam.id,
        name,
      );

      return None();
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      return Some(Error(error.toString()));
    }
  }

  Stream<Either<Error, LiveCommentaryRecordingVm>>
      postLiveCommentaryRecordingEntry(
    int fixtureId,
    String time,
    String icon,
    String title,
    String body,
    Uint8List imageBytes,
  ) async* {
    var needCleanupOnFailure = false;
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var liveCommRecordingIdentifier =
          'fixture:$fixtureId.team:${currentTeam.id}';

      bool isInPublishMode = _liveCommRecordingIdentifierToIsInPublishMode[
          liveCommRecordingIdentifier];

      String imagePath;
      if (imageBytes != null) {
        var result = await _imageService.compressImage(
          imageBytes,
          2 * 1024 * 1024,
        );

        List<int> compressedImageBytes = result.item1;
        String imageFormat = result.item2;

        var path = (await getApplicationDocumentsDirectory()).path;
        imagePath =
            '$path/${DateTime.now().millisecondsSinceEpoch}.$imageFormat';
        var file = File(imagePath);

        await file.writeAsBytes(compressedImageBytes, flush: true);
      }

      var entry = LiveCommentaryRecordingEntryEntity(
        fixtureId: fixtureId,
        teamId: currentTeam.id,
        postedAt: DateTime.now().millisecondsSinceEpoch,
        time: time,
        icon: icon,
        title: title,
        body: body,
        imagePath: imagePath,
        imageUrl: null,
        status: isInPublishMode
            ? LiveCommentaryRecordingEntryStatus.Publishing
            : LiveCommentaryRecordingEntryStatus.None,
      );

      await _storage.addLiveCommentaryRecordingEntry(entry);

      var allEntries = await _storage.loadLiveCommentaryRecordingEntries(
        fixtureId,
        currentTeam.id,
      );
      if (allEntries.isNotEmpty) {
        yield Right(
          LiveCommentaryRecordingVm(
            entries: allEntries
                .map(
                  (entry) => LiveCommentaryRecordingEntryVm.fromEntity(entry),
                )
                .toList(),
          ),
        );
      }

      if (!isInPublishMode) {
        return;
      }

      var recording = await _storage.loadLiveCommentaryRecordingNameAndStatus(
        fixtureId,
        currentTeam.id,
      );
      if (recording.creationStatus == LiveCommentaryRecordingStatus.None) {
        yield Right(
          LiveCommentaryRecordingVm(
            name: recording.name,
            creationStatus: LiveCommentaryRecordingStatus.Creating,
          ),
        );

        await _wsApiPolicy.execute(
          () =>
              _liveCommentaryRecordingApiService.createLiveCommentaryRecording(
            fixtureId,
            currentTeam.id,
            recording.name,
          ),
        );

        await _storage.updateLiveCommentaryRecordingStatus(
          fixtureId,
          currentTeam.id,
          LiveCommentaryRecordingStatus.Created,
        );
      }

      entry = await _uploadImage(entry);

      await _prevEntryPublished(entry);

      await _wsApiPolicy.execute(
        () =>
            _liveCommentaryRecordingApiService.postLiveCommentaryRecordingEntry(
          fixtureId,
          currentTeam.id,
          LiveCommentaryRecordingEntryDto.fromEntity(entry),
        ),
      );

      await _storage.updateLiveCommentaryRecordingEntry(
        entry.copyWith(status: LiveCommentaryRecordingEntryStatus.Published),
      );

      allEntries = await _storage.loadLiveCommentaryRecordingEntries(
        fixtureId,
        currentTeam.id,
      );
      if (allEntries.isNotEmpty) {
        yield Right(
          LiveCommentaryRecordingVm(
            entries: allEntries
                .map(
                  (entry) => LiveCommentaryRecordingEntryVm.fromEntity(entry),
                )
                .toList(),
          ),
        );
      }
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      if (needCleanupOnFailure) {
        // @@TODO: Delete entry, delete file if any, change status back to None if necessary, load all entries.
      }

      yield Left(Error(error.toString()));
    }
  }

  Stream<Either<Error, LiveCommentaryRecordingVm>>
      toggleLiveCommentaryRecordingPublishMode(
    int fixtureId,
  ) async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      var liveCommRecordingIdentifier =
          'fixture:$fixtureId.team:${currentTeam.id}';

      bool isInPublishMode = _liveCommRecordingIdentifierToIsInPublishMode[
              liveCommRecordingIdentifier] =
          !_liveCommRecordingIdentifierToIsInPublishMode[
              liveCommRecordingIdentifier];

      yield Right(
        LiveCommentaryRecordingVm(isInPublishMode: isInPublishMode),
      );

      if (!isInPublishMode) {
        return;
      }

      var entries =
          await _storage.loadNotPublishedLiveCommentaryRecordingEntries(
        fixtureId,
        currentTeam.id,
      );

      if (entries.isEmpty) {
        return;
      }

      var allEntries = await _storage.loadLiveCommentaryRecordingEntries(
        fixtureId,
        currentTeam.id,
      );
      if (allEntries.isNotEmpty) {
        yield Right(
          LiveCommentaryRecordingVm(
            entries: allEntries
                .map(
                  (entry) => LiveCommentaryRecordingEntryVm.fromEntity(entry),
                )
                .toList(),
          ),
        );
      }

      var recording = await _storage.loadLiveCommentaryRecordingNameAndStatus(
        fixtureId,
        currentTeam.id,
      );
      if (recording.creationStatus == LiveCommentaryRecordingStatus.None) {
        yield Right(
          LiveCommentaryRecordingVm(
            name: recording.name,
            creationStatus: LiveCommentaryRecordingStatus.Creating,
          ),
        );

        await _wsApiPolicy.execute(
          () =>
              _liveCommentaryRecordingApiService.createLiveCommentaryRecording(
            fixtureId,
            currentTeam.id,
            recording.name,
          ),
        );

        await _storage.updateLiveCommentaryRecordingStatus(
          fixtureId,
          currentTeam.id,
          LiveCommentaryRecordingStatus.Created,
        );
      }

      entries = await Future.wait(entries.map((entry) => _uploadImage(entry)));

      await _prevEntryPublished(entries.first);

      await _wsApiPolicy.execute(
        () => _liveCommentaryRecordingApiService
            .postLiveCommentaryRecordingEntries(
          fixtureId,
          currentTeam.id,
          entries.map(
            (entry) => LiveCommentaryRecordingEntryDto.fromEntity(entry),
          ),
        ),
      );

      await _storage.updateLiveCommentaryRecordingEntries(
        entries.map(
          (entry) => entry.copyWith(
            status: LiveCommentaryRecordingEntryStatus.Published,
          ),
        ),
      );

      allEntries = await _storage.loadLiveCommentaryRecordingEntries(
        fixtureId,
        currentTeam.id,
      );
      if (allEntries.isNotEmpty) {
        yield Right(
          LiveCommentaryRecordingVm(
            entries: allEntries
                .map(
                  (entry) => LiveCommentaryRecordingEntryVm.fromEntity(entry),
                )
                .toList(),
          ),
        );
      }
    } catch (error, stackTrace) {
      print('========== $error ==========');
      print(stackTrace);

      yield Left(Error(error.toString()));
    }
  }

  Future<LiveCommentaryRecordingEntryEntity> _uploadImage(
    LiveCommentaryRecordingEntryEntity entry,
  ) async {
    if (entry.imagePath != null) {
      var imageUrl = await _apiPolicy.execute(
        () => _liveCommentaryRecordingApiService
            .uploadLiveCommentaryRecordingEntryImage(
          entry.fixtureId,
          entry.teamId,
          entry.imagePath,
        ),
      );

      entry = entry.copyWith(imageUrl: imageUrl);
      await _storage.updateLiveCommentaryRecordingEntry(entry);
    }

    return entry;
  }

  Future _prevEntryPublished(LiveCommentaryRecordingEntryEntity entry) async {
    while (true) {
      var prevEntryStatus =
          await _storage.loadPrevLiveCommentaryRecordingEntryStatus(
        entry.fixtureId,
        entry.teamId,
        entry.postedAt,
      );

      if (prevEntryStatus == null ||
          prevEntryStatus == LiveCommentaryRecordingEntryStatus.Published) {
        break;
      }

      await Future.delayed(Duration(milliseconds: 200));
    }
  }
}
