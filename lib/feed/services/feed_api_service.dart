import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:signalr_core/signalr_core.dart';

import '../models/dto/requests/get_team_feed_articles_posted_before_request_dto.dart';
import '../models/dto/article_dto.dart';
import '../models/dto/requests/get_article_request_dto.dart';
import '../models/dto/requests/unsubscribe_from_team_feed_request_dto.dart';
import '../models/dto/requests/post_article_request_dto.dart';
import '../enums/article_type.dart';
import '../errors/feed_error.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../interfaces/ifeed_api_service.dart';
import '../models/dto/requests/subscribe_to_team_feed_request_dto.dart';
import '../models/dto/team_feed_update_dto.dart';
import '../../../../general/errors/api_error.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/forbidden_error.dart';
import '../../../../general/errors/invalid_authentication_token_error.dart';
import '../../../../general/errors/validation_error.dart';
import '../../../../general/services/server_connector.dart';
import '../../../../general/services/subscription_tracker.dart';
import '../../../../general/enums/message_type.dart' as enums;

class FeedApiService implements IFeedApiService {
  final ServerConnector _serverConnector;
  final SubscriptionTracker _subscriptionTracker;

  HubConnection get _connection => _serverConnector.connection;
  Dio get _dio => _serverConnector.dio;

  final Map<String, StreamController<TeamFeedUpdateDto>>
      _teamIdentifierToUpdatesChannel = {};

  FeedApiService(
    this._serverConnector,
    this._subscriptionTracker,
  ) {
    _serverConnector.message$
        .where((message) => message.item1 == enums.MessageType.FeedUpdate)
        .listen((message) {
      _updateFeed(message.item2);
    });
  }

  dynamic _wrapHubException(Exception ex) {
    var errorMessage = ex.toString();
    if (errorMessage.contains('[AuthorizationError]')) {
      if (errorMessage.contains('Forbidden')) {
        return ForbiddenError();
      } else if (errorMessage.contains('token expired at')) {
        return AuthenticationTokenExpiredError();
      } else {
        return InvalidAuthenticationTokenError(
          errorMessage.split('[AuthorizationError] ').last,
        );
      }
    } else if (errorMessage.contains('[ValidationError]')) {
      return ValidationError();
    } else if (errorMessage.contains('[FeedError]')) {
      return FeedError(errorMessage.split('[FeedError] ').last);
    }

    print(ex);

    return ApiError();
  }

  dynamic _wrapError(DioError error) {
    // ignore: missing_enum_constant_in_switch
    switch (error.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return ConnectionError();
      case DioErrorType.response:
        var statusCode = error.response.statusCode;
        if (statusCode >= 500) {
          return ServerError();
        }

        switch (statusCode) {
          case 400:
            var failure = error.response.data['failure'];
            if (failure['type'] == 'Validation') {
              return ValidationError();
            } else if (failure['type'] == 'Feed') {
              return FeedError(
                failure['errors'].values.first.first,
              );
            }
            break; // @@NOTE: Should never actually reach here.
          case 401:
            var failureMessage =
                error.response.data['failure']['errors'].values.first.first;
            if (failureMessage.contains('token expired at')) {
              return AuthenticationTokenExpiredError();
            }
            return InvalidAuthenticationTokenError(failureMessage);
          case 403:
            return ForbiddenError();
        }
    }

    print(error);

    return ApiError();
  }

  void _updateFeed(List<dynamic> args) {
    var update = TeamFeedUpdateDto.fromMap(args[0]);
    var teamIdentifier = 'team:${update.teamId}';
    if (_teamIdentifierToUpdatesChannel.containsKey(teamIdentifier)) {
      _teamIdentifierToUpdatesChannel[teamIdentifier].add(update);
    }
  }

  @override
  Future<Stream<TeamFeedUpdateDto>> subscribeToTeamFeed(int teamId) async {
    await _serverConnector.ensureConnected();

    var teamIdentifier = 'team:$teamId';

    _subscriptionTracker.addSubscription(teamIdentifier);

    var updatesChannel = StreamController<TeamFeedUpdateDto>();
    _teamIdentifierToUpdatesChannel[teamIdentifier] = updatesChannel;

    try {
      var result = await _connection.invoke(
        'SubscribeToTeamFeed',
        args: [
          SubscribeToTeamFeedRequestDto(
            teamId: teamId,
          ),
        ],
      );

      var update = TeamFeedUpdateDto.fromMap(result['data']);
      updatesChannel.add(update);

      return updatesChannel.stream;
    } on Exception catch (ex) {
      _subscriptionTracker.removeSubscription(teamIdentifier);
      updatesChannel.close();
      _teamIdentifierToUpdatesChannel.remove(teamIdentifier);

      throw _wrapHubException(ex);
    }
  }

  @override
  void unsubscribeFromTeamFeed(int teamId) async {
    await _serverConnector.ensureConnected();

    var teamIdentifier = 'team:$teamId';

    _subscriptionTracker.removeSubscription(teamIdentifier);

    var updatesChannel = _teamIdentifierToUpdatesChannel.remove(
      teamIdentifier,
    );
    if (updatesChannel != null) {
      updatesChannel.close();

      await _connection.invoke(
        'UnsubscribeFromTeamFeed',
        args: [
          UnsubscribeFromTeamFeedRequestDto(
            teamId: teamId,
          ),
        ],
      );
    }
  }

  @override
  Future<Iterable<ArticleDto>> getTeamFeedArticlesPostedBefore(
    int teamId,
    DateTime postedBefore,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      var result = await _connection.invoke(
        'GetTeamFeedArticlesPostedBefore',
        args: [
          GetTeamFeedArticlesPostedBeforeRequestDto(
            teamId: teamId,
            postedBefore: postedBefore,
          ),
        ],
      );

      return (result['data'] as List<dynamic>).map(
        (articleMap) => ArticleDto.fromMap(articleMap),
      );
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<ArticleDto> getArticle(int teamId, DateTime postedAt) async {
    await _serverConnector.ensureConnected();

    try {
      var result = await _connection.invoke(
        'GetArticle',
        args: [
          GetArticleRequestDto(
            teamId: teamId,
            postedAt: postedAt,
          ),
        ],
      );

      return ArticleDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future postVideoArticle(
    int teamId,
    ArticleType type,
    String title,
    Uint8List thumbnailBytes,
    String summary,
    String content,
  ) async {
    var formData = FormData.fromMap(
      {
        'type': type.index,
        'title': title,
        'thumbnail': MultipartFile.fromBytes(
          thumbnailBytes,
          filename: 'thumbnail.jpg',
        ),
        'summary': summary,
        'content': content,
      },
    );

    try {
      await _dio.post(
        '/api/teams/$teamId/feed',
        options: Options(
          headers: {'Authorization': 'Bearer ${_serverConnector.accessToken}'},
        ),
        data: formData,
      );
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future postArticle(
    int teamId,
    ArticleType type,
    String title,
    String previewImageUrl,
    String summary,
    String content,
  ) async {
    await _serverConnector.ensureConnected();

    try {
      await _connection.invoke(
        'PostArticle',
        args: [
          PostArticleRequestDto(
            teamId: teamId,
            type: type,
            title: title,
            previewImageUrl: previewImageUrl,
            summary: summary,
            content: content,
          ),
        ],
      );
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }
}
