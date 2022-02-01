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
        c<IPlayerRatingRepository>()));
    container.registerSingleton((c) => NotificationService());
    container
        .registerSingleton((c) => NotificationBloc(c<NotificationService>()));
  }

  @override
  void configureImage() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IImageService>(
        (c) => ImageService(c<IVimeoApiService>()));
    container.registerSingleton((c) => ImageBloc(c<IImageService>()));
  }

  @override
  void configureAccount() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IAccountApiService>(
        (c) => AccountApiService(c<ServerConnector>()));
    container.registerSingleton<IAccountRepository>(
        (c) => AccountRepository(c<DbConfigurator>()));
    container.registerSingleton((c) => AccountService(
        c<Storage>(),
        c<ServerConnector>(),
        c<IAccountApiService>(),
        c<IImageService>(),
        c<NotificationService>()));
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
  void configureDiscussion() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IDiscussionApiService>((c) =>
        DiscussionApiService(c<ServerConnector>(), c<SubscriptionTracker>()));
    container.registerSingleton((c) => DiscussionService(
        c<Storage>(),
        c<IDiscussionApiService>(),
        c<AccountService>(),
        c<NotificationService>()));
    container.registerFactory((c) => DiscussionBloc(c<DiscussionService>()));
  }

  @override
  void configurePlayerRating() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IPlayerRatingApiService>(
        (c) => PlayerRatingApiService(c<ServerConnector>()));
    container.registerSingleton<IPlayerRatingRepository>(
        (c) => PlayerRatingRepository(c<DbConfigurator>()));
    container.registerSingleton((c) => PlayerRatingService(
        c<Storage>(),
        c<AccountService>(),
        c<IPlayerRatingApiService>(),
        c<NotificationService>()));
    container
        .registerSingleton((c) => PlayerRatingBloc(c<PlayerRatingService>()));
  }

  @override
  void configureVideoReaction() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IVideoReactionApiService>(
        (c) => VideoReactionApiService(c<ServerConnector>()));
    container.registerSingleton<IVimeoApiService>(
        (c) => VimeoApiService(c<ServerConnector>()));
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
    container.registerSingleton((c) => TeamService(
        c<Storage>(), c<ITeamApiService>(), c<NotificationService>()));
    container.registerSingleton((c) => TeamBloc(c<TeamService>()));
  }

  @override
  void configureFeed() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IFeedApiService>(
        (c) => FeedApiService(c<ServerConnector>()));
    container.registerSingleton((c) => FeedService(
        c<Storage>(),
        c<NotificationService>(),
        c<IFeedApiService>(),
        c<AccountService>(),
        c<IImageService>()));
    container.registerSingleton((c) => FeedBloc(c<FeedService>()));
    container.registerFactory((c) => CommentBloc(c<FeedService>()));
  }

  @override
  void configureMatchPredictions() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton<IMatchPredictionsApiService>(
        (c) => MatchPredictionsApiService(c<ServerConnector>()));
    container.registerSingleton((c) => MatchPredictionsService(
        c<Storage>(),
        c<IMatchPredictionsApiService>(),
        c<AccountService>(),
        c<NotificationService>()));
    container.registerSingleton(
        (c) => MatchPredictionsBloc(c<MatchPredictionsService>()));
  }
}
