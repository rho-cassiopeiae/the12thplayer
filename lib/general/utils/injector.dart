import 'package:kiwi/kiwi.dart';

import '../../match_predictions/bloc/match_predictions_bloc.dart';
import '../../match_predictions/interfaces/imatch_predictions_api_service.dart';
import '../../match_predictions/services/match_predictions_api_service.dart';
import '../../match_predictions/services/match_predictions_service.dart';
import '../../feed/bloc/comment_bloc.dart';
import '../../feed/interfaces/ifeed_api_service.dart';
import '../../feed/services/feed_api_service.dart';
import '../../feed/bloc/feed_bloc.dart';
import '../../feed/services/feed_service.dart';
import '../../fixture/livescore/player_rating/bloc/player_rating_bloc.dart';
import '../../fixture/livescore/player_rating/interfaces/iplayer_rating_api_service.dart';
import '../../fixture/livescore/player_rating/interfaces/iplayer_rating_repository.dart';
import '../../fixture/livescore/player_rating/persistence/repositories/player_rating_repository.dart';
import '../../fixture/livescore/player_rating/services/player_rating_api_service.dart';
import '../../fixture/livescore/player_rating/services/player_rating_service.dart';
import '../bloc/notification_bloc.dart';
import '../services/notification_service.dart';
import '../../fixture/livescore/video_reaction/interfaces/ivimeo_api_service.dart';
import '../../fixture/livescore/video_reaction/services/vimeo_api_service.dart';
import '../../fixture/livescore/video_reaction/bloc/video_reaction_bloc.dart';
import '../../fixture/livescore/video_reaction/interfaces/ivideo_reaction_api_service.dart';
import '../../fixture/livescore/video_reaction/services/video_reaction_api_service.dart';
import '../../fixture/livescore/video_reaction/services/video_reaction_service.dart';
import '../../team/bloc/team_bloc.dart';
import '../../team/interfaces/iteam_api_service.dart';
import '../../team/services/team_api_service.dart';
import '../../team/services/team_service.dart';
import '../services/subscription_tracker.dart';
import '../../fixture/livescore/discussion/bloc/discussion_bloc.dart';
import '../../fixture/livescore/discussion/interfaces/idiscussion_api_service.dart';
import '../../fixture/livescore/discussion/services/discussion_api_service.dart';
import '../../fixture/livescore/discussion/services/discussion_service.dart';
import '../../general/bloc/image_bloc.dart';
import '../../fixture/livescore/bloc/fixture_livescore_bloc.dart';
import '../../fixture/livescore/interfaces/ifixture_repository.dart';
import '../../fixture/livescore/persistence/repositories/fixture_repository.dart';
import '../../fixture/livescore/services/fixture_livescore_service.dart';
import '../interfaces/iimage_service.dart';
import '../../account/bloc/account_bloc.dart';
import '../../account/interfaces/iaccount_api_service.dart';
import '../../account/interfaces/iaccount_repository.dart';
import '../../account/persistence/repositories/account_repository.dart';
import '../../account/services/account_api_service.dart';
import '../../account/services/account_service.dart';
import '../../fixture/calendar/bloc/fixture_calendar_bloc.dart';
import '../../fixture/calendar/interfaces/ifixture_calendar_repository.dart';
import '../../fixture/calendar/persistence/repositories/fixture_calendar_repository.dart';
import '../../fixture/calendar/services/fixture_calendar_service.dart';
import '../../fixture/common/interfaces/ifixture_api_service.dart';
import '../../fixture/common/services/fixture_api_service.dart';
import '../in_memory/cache.dart';
import '../../team/interfaces/iteam_repository.dart';
import '../persistence/db_configurator.dart';
import '../../team/persistence/repositories/team_repository.dart';
import '../persistence/storage.dart';
import '../services/image_service.dart';
import '../services/server_connector.dart';

part 'injector.g.dart';

abstract class Injector {
  @Register.singleton(DbConfigurator)
  @Register.singleton(SubscriptionTracker)
  @Register.singleton(ServerConnector)
  @Register.singleton(Cache)
  @Register.singleton(Storage)
  @Register.singleton(NotificationService)
  @Register.singleton(NotificationBloc)
  void configureGeneral();

  @Register.singleton(IImageService, from: ImageService)
  @Register.singleton(ImageBloc)
  void configureImage();

  @Register.singleton(IAccountApiService, from: AccountApiService)
  @Register.singleton(IAccountRepository, from: AccountRepository)
  @Register.singleton(AccountService)
  @Register.singleton(AccountBloc)
  void configureAccount();

  @Register.singleton(IFixtureApiService, from: FixtureApiService)
  void configureFixtureCommon();

  @Register.singleton(
    IFixtureCalendarRepository,
    from: FixtureCalendarRepository,
  )
  @Register.singleton(FixtureCalendarService)
  @Register.singleton(FixtureCalendarBloc)
  void configureFixtureCalendar();

  @Register.singleton(IFixtureRepository, from: FixtureRepository)
  @Register.singleton(FixtureLivescoreService)
  @Register.factory(FixtureLivescoreBloc)
  void configureFixtureLivescore();

  // @Register.singleton(
  //   ILiveCommentaryFeedApiService,
  //   from: LiveCommentaryFeedApiService,
  // )
  // @Register.singleton(
  //   ILiveCommentaryFeedRepository,
  //   from: LiveCommentaryFeedRepository,
  // )
  // @Register.singleton(LiveCommentaryFeedService)
  // @Register.factory(LiveCommentaryFeedBloc)
  // void configureLiveCommentaryFeed();

  // @Register.singleton(
  //   ILiveCommentaryRecordingApiService,
  //   from: LiveCommentaryRecordingApiService,
  // )
  // @Register.singleton(
  //   ILiveCommentaryRecordingRepository,
  //   from: LiveCommentaryRecordingRepository,
  // )
  // @Register.singleton(LiveCommentaryRecordingService)
  // @Register.factory(LiveCommentaryRecordingBloc)
  // void configureLiveCommentaryRecording();

  @Register.singleton(IDiscussionApiService, from: DiscussionApiService)
  @Register.singleton(DiscussionService)
  @Register.factory(DiscussionBloc)
  void configureDiscussion();

  @Register.singleton(
    IPlayerRatingApiService,
    from: PlayerRatingApiService,
  )
  @Register.singleton(
    IPlayerRatingRepository,
    from: PlayerRatingRepository,
  )
  @Register.singleton(PlayerRatingService)
  @Register.singleton(PlayerRatingBloc)
  void configurePlayerRating();

  @Register.singleton(IVideoReactionApiService, from: VideoReactionApiService)
  @Register.singleton(IVimeoApiService, from: VimeoApiService)
  @Register.singleton(VideoReactionService)
  @Register.singleton(VideoReactionBloc)
  void configureVideoReaction();

  @Register.singleton(ITeamApiService, from: TeamApiService)
  @Register.singleton(ITeamRepository, from: TeamRepository)
  @Register.singleton(TeamService)
  @Register.singleton(TeamBloc)
  void configureTeam();

  @Register.singleton(IFeedApiService, from: FeedApiService)
  @Register.singleton(FeedService)
  @Register.singleton(FeedBloc)
  @Register.factory(CommentBloc)
  void configureFeed();

  @Register.singleton(
    IMatchPredictionsApiService,
    from: MatchPredictionsApiService,
  )
  @Register.singleton(MatchPredictionsService)
  @Register.singleton(MatchPredictionsBloc)
  void configureMatchPredictions();

  void configure() {
    configureGeneral();
    configureImage();
    configureAccount();
    configureFixtureCommon();
    configureFixtureCalendar();
    configureFixtureLivescore();
    configureDiscussion();
    configurePlayerRating();
    configureVideoReaction();
    configureTeam();
    configureFeed();
    configureMatchPredictions();
  }
}

void setup() {
  var injector = _$Injector();
  injector.configure();
}
