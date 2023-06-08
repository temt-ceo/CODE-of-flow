import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_api/amplify_api.dart';
import 'amplifyconfiguration.dart';
import 'package:CodeOfFlow/models/ModelProvider.dart';
import 'package:CodeOfFlow/pages/homePage.dart';
import 'package:CodeOfFlow/pages/deckEditPage.dart';

const envFlavor = String.fromEnvironment('flavor');

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const App());
}

Future<void> _configureAmplify() async {
  try {
    // final auth = AmplifyAuthCognito();
    // final datastore = AmplifyDataStore(modelProvider: ModelProvider.instance);
    final api = AmplifyAPI(modelProvider: ModelProvider.instance);
    await Amplify.addPlugins([api]);
    // await Amplify.addPlugins([api, auth]);

    await Amplify.configure(amplifyconfig);
  } catch (e) {
    debugPrint('Amplify Configure error: $e');
  }
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  Locale _locale = ui.window.locale;
  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';

    return MaterialApp(
      locale: _locale,
      title: 'Code Of Flow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        textTheme: GoogleFonts.robotoTextTheme(),
        scaffoldBackgroundColor: Colors.blue,
        iconTheme: IconThemeData(size: 15.0),
        useMaterial3: true,
      ),
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,
      routes: {
        '/': (context) => Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('${imagePath}unit/bg-2.jpg'),
                      fit: BoxFit.cover)),
              child: HomePage(
                  title: L10n.of(context)!.homePageTitle,
                  localeCallback: setLocale),
            ),
        '/deck_edit': (context) => Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('${imagePath}unit/bg-2.jpg'),
                      fit: BoxFit.cover)),
              child: DeckEditPage(
                  title: L10n.of(context)!.deckEditPageTitle,
                  localeCallback: setLocale),
            ),
      },
    );
    // );
  }
}
