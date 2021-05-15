import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:tuple/tuple.dart';

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
  await DefaultCacheManager().emptyCache();
  setup();
  runApp(Application());
}

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: generateMaterialColor(Color.fromRGBO(39, 87, 203, 1.0)),
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
          default:
            return null;
        }
      },
    );
  }
}
