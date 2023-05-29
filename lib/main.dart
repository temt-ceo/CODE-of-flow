import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
// import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart';
// import 'amplifyconfiguration.dart';
import 'package:CodeOfFlow/pages/homePage.dart';
import 'package:js/js.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const App());
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    // final datastore = AmplifyDataStore(modelProvider: ModelProvider.instance);
    // final api = AmplifyAPI(modelProvider: ModelProvider.instance);
    await Amplify.addPlugins([auth]);
    // await Amplify.addPlugins([api]);
    // await Amplify.addPlugins([api, auth]);

    // await Amplify.configure(amplifyconfig)
  } catch (e) {
    print('Amplify Configure error: $e');
  }
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String imagePath = env_flavor == 'prod' ? 'assets/image/' : 'image/';
    // return Authenticator(
    //   child: MaterialApp(
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('${imagePath}unit/bg-2.jpg'),
                fit: BoxFit.cover)),
        child: HomePage(
            title: '\\ Welcome to the Virtual Arcade! / | CODE-Of-Flow'),
      ),
    );
    // );
  }
}
