// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injector.dart';

// **************************************************************************
// KiwiInjectorGenerator
// **************************************************************************

class _$Injector extends Injector {
  @override
  void configureGeneral() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton((c) => DbConfigurator());
    container.registerSingleton((c) => SubscriptionTracker());
    container
        .registerSingleton((c) => ServerConnector(c<SubscriptionTracker>()));
    container.registerSingleton((c) => Cache());
    container.registerSingleton((c) => Storage(
        c<Cache>(),
        c<IAccountRepository>(),
        c<ITeamRepository>(),
        c<IFixtureCalendarRepository>(),
        c<IFixtureRepository>(),
        c<ILiveCommentaryFeedRepository>(),
        c<ILiveCommentaryRecordingRepository>(),
        c<IPerformanceRatingRepository>()));
    container.registerSingleton((c) => NotificationService());
    container
        .registerSingleton((c) => NotificationBloc(c<NotificationService>()));
  }

  @override
  void configureImage() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IImageService>((c) => ImageService());
    container.registerSingleton((c) => ImageBloc(c<IImageService>()));
  }

  @override
  void configureAccount() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IAccountApiService>(
        (c) => AccountApiService(c<ServerConnector>()));
    container.registerSingleton<IAccountRepository>(
        (c) => AccountRepository(c<DbConfigurator>()));
    container.registerSingleton((c) => AccountService(c<Storage>(),
        c<ServerConnector>(), c<IAccountApiService>(), c<IImageService>()));
    container.registerSingleton((c) => AccountBloc(c<AccountService>()));
  }

  @override
  void configureFixtureCommon() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IFixtureApiService>((c) =>
        FixtureApiService(c<ServerConnector>(), c<SubscriptionTracker>()));
  }

  @override
  void configureFixtureCalendar() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IFixtureCalendarRepository>(
        (c) => FixtureCalendarRepository(c<DbConfigurator>()));
    container.registerSingleton(
        (c) => FixtureCalendarService(c<Storage>(), c<IFixtureApiService>()));
    container.registerSingleton(
        (c) => FixtureCalendarBloc(c<FixtureCalendarService>()));
  }

  @override
  void configureFixtureLivescore() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IFixtureRepository>(
        (c) => FixtureRepository(c<DbConfigurator>()));
    container.registerSingleton((c) => FixtureLivescoreService(
        c<Storage>(), c<IFixtureApiService>(), c<NotificationService>()));
    container.registerFactory(
        (c) => FixtureLivescoreBloc(c<FixtureLivescoreService>()));
  }

  @override
  void configureLiveCommentaryFeed() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<ILiveCommentaryFeedApiService>((c) =>
        LiveCommentaryFeedApiService(
            c<ServerConnector>(), c<SubscriptionTracker>()));
    container.registerSingleton<ILiveCommentaryFeedRepository>(
        (c) => LiveCommentaryFeedRepository(c<DbConfigurator>()));
    container.registerSingleton((c) => LiveCommentaryFeedService(
        c<Storage>(), c<ILiveCommentaryFeedApiService>(), c<AccountService>()));
    container.registerFactory(
        (c) => LiveCommentaryFeedBloc(c<LiveCommentaryFeedService>()));
  }

  @override
  void configureLiveCommentaryRecording() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<ILiveCommentaryRecordingApiService>(
        (c) => LiveCommentaryRecordingApiService(c<ServerConnector>()));
    container.registerSingleton<ILiveCommentaryRecordingRepository>(
        (c) => LiveCommentaryRecordingRepository(c<DbConfigurator>()));
    container.registerSingleton((c) => LiveCommentaryRecordingService(
        c<Storage>(),
        c<ILiveCommentaryRecordingApiService>(),
        c<IImageService>(),
        c<AccountService>()));
    container.registerFactory((c) =>
        LiveCommentaryRecordingBloc(c<LiveCommentaryRecordingService>()));
  }

  @override
  void configureDiscussion() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IDiscussionApiService>((c) =>
        DiscussionApiService(c<ServerConnector>(), c<SubscriptionTracker>()));
    container.registerSingleton((c) => DiscussionService(
        c<Storage>(), c<IDiscussionApiService>(), c<AccountService>()));
    container.registerFactory((c) => DiscussionBloc(c<DiscussionService>()));
  }

  @override
  void configurePerformanceRating() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IPerformanceRatingApiService>(
        (c) => PerformanceRatingApiService(c<ServerConnector>()));
    container.registerSingleton<IPerformanceRatingRepository>(
        (c) => PerformanceRatingRepository(c<DbConfigurator>()));
    container.registerSingleton((c) => PerformanceRatingService(
        c<Storage>(),
        c<AccountService>(),
        c<IPerformanceRatingApiService>(),
        c<NotificationService>()));
    container.registerSingleton(
        (c) => PerformanceRatingBloc(c<PerformanceRatingService>()));
  }

  @override
  void configureVideoReaction() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IVideoReactionApiService>(
        (c) => VideoReactionApiService(c<ServerConnector>()));
    container.registerSingleton<IVimeoApiService>((c) => VimeoApiService());
    container.registerSingleton((c) => VideoReactionService(
        c<Storage>(),
        c<IVideoReactionApiService>(),
        c<IVimeoApiService>(),
        c<AccountService>(),
        c<NotificationService>()));
    container
        .registerSingleton((c) => VideoReactionBloc(c<VideoReactionService>()));
  }

  @override
  void configureTeam() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<ITeamApiService>(
        (c) => TeamApiService(c<ServerConnector>()));
    container.registerSingleton<ITeamRepository>(
        (c) => TeamRepository(c<DbConfigurator>()));
    container.registerSingleton(
        (c) => TeamService(c<Storage>(), c<ITeamApiService>()));
    container.registerSingleton((c) => TeamBloc(c<TeamService>()));
  }

  @override
  void configureFeed() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IFeedApiService>(
        (c) => FeedApiService(c<ServerConnector>(), c<SubscriptionTracker>()));
    container.registerSingleton(
        (c) => FeedService(c<Storage>(), c<IFeedApiService>()));
    container.registerSingleton((c) => FeedBloc(c<FeedService>()));
  }
}
