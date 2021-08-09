import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:tuple/tuple.dart';

import 'feed/pages/article_preview_compose_page.dart';
import 'feed/enums/article_type.dart';
import 'feed/pages/article_type_selection_page.dart';
import 'feed/pages/video_article_compose_page.dart';
import 'feed/pages/youtube_video_page.dart';
import 'account/pages/interrupted_confirmation_page.dart';
import 'feed/pages/article_compose_page.dart';
import 'general/bloc/notification_actions.dart';
import 'general/bloc/notification_bloc.dart';
import 'general/extensions/kiwi_extension.dart';
import 'fixture/livescore/pages/video_page.dart';
import 'fixture/livescore/video_reaction/pages/video_reaction_page.dart';
import 'account/pages/profile_page.dart';
import 'team/models/vm/team_member_vm.dart';
import 'team/pages/team_member_page.dart';
import 'team/pages/team_squad_page.dart';
import 'fixture/livescore/discussion/pages/discussion_page.dart';
import 'fixture/livescore/live_commentary_recording/pages/live_commentary_recording_page.dart';
import 'fixture/livescore/live_commentary_feed/pages/live_commentary_feed_page.dart';
import 'fixture/common/models/vm/fixture_summary_vm.dart';
import 'fixture/livescore/pages/fixture_livescore_page.dart';
import 'general/pages/welcome_page.dart';
import 'fixture/calendar/pages/fixture_calendar_page.dart';
import 'account/pages/auth_page.dart';
import 'account/pages/email_confirmation_page.dart';
import 'general/extensions/color_extension.dart';
import 'general/utils/injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterConfig.loadEnvVariables();

  if (FlutterConfig.get('ENVIRONMENT').toLowerCase() == 'development') {
    await DefaultCacheManager().emptyCache();
  }

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'video_reaction_channel',
        channelName: 'Video reactions',
        channelDescription:
            'Notifying users when their video reactions get successfully uploaded and processed',
        defaultColor: const Color.fromRGBO(39, 87, 203, 1.0),
        ledColor: Colors.white,
      )
    ],
    debug: true,
  );

  setup();

  runApp(Application());
}

class Application extends StatelessWidgetInjected<NotificationBloc> {
  @override
  Widget buildInjected(
    BuildContext context,
    NotificationBloc notificationBloc,
  ) {
    var scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    notificationBloc.dispatchAction(
      AddScaffoldMessengerKey(scaffoldMessengerKey: scaffoldMessengerKey),
    );

    return MaterialApp(
      title: 'Flutter Demo',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: generateMaterialColor(
          const Color.fromRGBO(39, 87, 203, 1.0),
        ),
        accentColor: Colors.grey[300],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AuthPage.routeName:
            return MaterialPageRoute(
              builder: (_) => AuthPage(
                goBackAfterAuth: settings.arguments != null
                    ? settings.arguments as bool
                    : false,
              ),
            );
          case EmailConfirmationPage.routeName:
            return MaterialPageRoute(
              builder: (_) => EmailConfirmationPage(
                goBackAfterConfirm: settings.arguments != null
                    ? settings.arguments as bool
                    : false,
              ),
            );
          case InterruptedConfirmationPage.routeName:
            return MaterialPageRoute(
              builder: (_) => InterruptedConfirmationPage(
                goBackAfterConfirm: settings.arguments as bool,
              ),
            );
          case FixtureCalendarPage.routeName:
            return MaterialPageRoute(
              builder: (_) => FixtureCalendarPage(),
            );
          case FixtureLivescorePage.routeName:
            return MaterialPageRoute(
              builder: (_) => FixtureLivescorePage(
                fixture: settings.arguments as FixtureSummaryVm,
              ),
            );
          case LiveCommentaryFeedPage.routeName:
            var args = settings.arguments as Tuple3<int, int, String>;
            return MaterialPageRoute(
              builder: (_) => LiveCommentaryFeedPage(
                fixtureId: args.item1,
                authorId: args.item2,
                authorUsername: args.item3,
              ),
            );
          case LiveCommentaryRecordingPage.routeName:
            var args = settings.arguments as Tuple2<int, int>;
            return MaterialPageRoute(
              builder: (_) => LiveCommentaryRecordingPage(
                fixtureId: args.item1,
                teamId: args.item2,
              ),
            );
          case DiscussionPage.routeName:
            var args = settings.arguments as Tuple2<int, String>;
            return MaterialPageRoute(
              builder: (_) => DiscussionPage(
                fixtureId: args.item1,
                discussionIdentifier: args.item2,
              ),
            );
          case TeamSquadPage.routeName:
            return MaterialPageRoute(
              builder: (_) => TeamSquadPage(),
            );
          case TeamMemberPage.routeName:
            return MaterialPageRoute(
              builder: (_) => TeamMemberPage(
                member: settings.arguments as TeamMemberVm,
              ),
            );
          case ProfilePage.routeName:
            return MaterialPageRoute(
              builder: (_) => ProfilePage(),
            );
          case VideoReactionPage.routeName:
            return MaterialPageRoute(
              builder: (_) => VideoReactionPage(
                fixtureId: settings.arguments as int,
              ),
            );
          case VideoPage.routeName:
            return MaterialPageRoute(
              builder: (_) => VideoPage(
                videoId: settings.arguments as String,
              ),
            );
          case ArticleTypeSelectionPage.routeName:
            return MaterialPageRoute(
              builder: (_) => ArticleTypeSelectionPage(),
            );
          case VideoArticleComposePage.routeName:
            return MaterialPageRoute(
              builder: (_) => VideoArticleComposePage(
                type: settings.arguments as ArticleType,
              ),
            );
          case YoutubeVideoPage.routeName:
            return MaterialPageRoute(
              builder: (_) => YoutubeVideoPage(
                videoUrl: settings.arguments as String,
              ),
            );
          case ArticlePreviewComposePage.routeName:
            return MaterialPageRoute(
              builder: (_) => ArticlePreviewComposePage(
                type: settings.arguments as ArticleType,
              ),
            );
          case ArticleComposePage.routeName:
            return MaterialPageRoute(
              builder: (_) => ArticleComposePage(
                type: settings.arguments as ArticleType,
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
