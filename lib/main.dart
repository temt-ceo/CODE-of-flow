@JS()
library index;

import 'dart:js_util';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
// import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart';
// import 'amplifyconfiguration.dart';
// import 'models/ModelProvider.dart';
import 'package:CodeOfFlow/bloc/counter/counter_bloc.dart';
import 'package:CodeOfFlow/bloc/counter/counter_event.dart';
import 'package:CodeOfFlow/component/draggableCardWidget.dart';
import 'package:CodeOfFlow/component/dragTargetWidget.dart';
import 'package:js/js.dart';

@JS('authenticate')
external void authenticate();

@JS('unauthenticate')
external void unauthenticate();

@JS('subscribe')
external void subscribe(dynamic user);

@JS('createPlayer')
external void createPlayer(String? name);

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
    // return Authenticator(
    //   child: MaterialApp(
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      home: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('image/unit/bg-2.jpg'), fit: BoxFit.cover)),
        child: HomePage(
            title: '\\ Welcome to the Virtual Arcade! / | CODE-Of-Flow'),
      ),
    );
    // );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final CounterBloc _counterBloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    void setupWallet(map) {
      print(map?.addr);
    }

    subscribe(allowInterop(setupWallet));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.title, style: TextStyle(color: Color(0xFFFFFFFF))),
      ),
      body: Stack(children: <Widget>[
        Stack(fit: StackFit.expand, children: <Widget>[
          const Positioned(
              left: 10.0,
              top: 30.0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 130.0, 30.0, 10.0),
                      child: DragTargetWidget(
                          'trigger', 'image/trigger/trigger.png'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(30.0),
                      child: DragTargetWidget('unit', 'image/unit/bg-2.jpg'),
                    ),
                  ])),
          Positioned(
              left: 10.0,
              top: 480.0,
              child: Row(children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Container(
                      width: 280.0,
                      height: 160.0,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('image/unit/bg-2.jpg'),
                            fit: BoxFit.cover),
                      ),
                    )),
                DragBox('', 'image/unit/card_16.jpeg'),
                DragBox('', 'image/trigger/card_17.jpeg'),
                DragBox('', 'image/trigger/card_18.jpeg'),
                DragBox('', 'image/trigger/card_19.jpeg'),
                DragBox('', 'image/unit/card_1.jpeg'),
                DragBox('', 'image/unit/card_2.jpeg'),
                DragBox('', 'image/unit/card_3.jpeg'),
              ])),
        ]),
        const Positioned(
            left: 20.0,
            top: 10.0,
            child: Text('Opponent Life: 7 🔷🔷🔷🔷🔷🔷🔷',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 22.0,
                ))),
        const Positioned(
            left: 70.0,
            top: 50.0,
            child: Text('CP 04',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 22.0,
                ))),
        const Positioned(
            left: 70.0,
            top: 80.0,
            child: Text('Dead 0',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 22.0,
                ))),
        const Positioned(
            left: 400.0,
            top: 10.0,
            child: Text('Deck 22',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 22.0,
                ))),
        const Positioned(
            left: 320.0,
            top: 50.0,
            child: Text('Hand 5 🔶🔶🔶🔶🔶',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 22.0,
                ))),
        const Positioned(
            left: 320.0,
            top: 80.0,
            child: Text('Trigger Zone: 🔲🔲🔳🔳',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 22.0,
                ))),
        const Positioned(
            left: 20.0,
            top: 120.0,
            child: Text('You Life: 7 🔷🔷🔷🔷🔷🔷🔷',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 22.0,
                ))),
        const Positioned(
            left: 70.0,
            top: 160.0,
            child: Text('CP 04',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 22.0,
                ))),
        const Positioned(
            left: 1250.0,
            bottom: 140.0,
            child: Text('Deck 22',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 22.0,
                ))),
        const Positioned(
            left: 1250.0,
            bottom: 100.0,
            child: Text('Dead 0',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 22.0,
                ))),
        const Positioned(
            left: 30.0,
            bottom: 100.0,
            width: 270.0,
            child: Text('テキストテキストテキストテキストテキストテキストテキストテキスト',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 16.0,
                ))),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        StreamBuilder(
          stream: _counterBloc.counter,
          initialData: 0,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${snapshot.data}',
                    style: const TextStyle(color: Colors.white, fontSize: 30.0),
                  ),
                ]);
          },
        ),
        const SizedBox(width: 20),
        FloatingActionButton(
          onPressed: () => authenticate(),
          tooltip: 'Authenticate',
          child: const Icon(Icons.key_outlined),
        ),
        const SizedBox(width: 20),
        // FloatingActionButton(
        //   onPressed: () => () {
        //     final newEntry = Todo(
        //       name: "sample",
        //       description: "test",
        //     );
        //     final request = ModelMutations.create(newEntry);
        //     final response = await Amplify.API.mutate(request: request).response;
        //     Print('Create result: $response');
        //     Amplify.DataStore.save(newEntry);
        //   },
        //   tooltip: 'Authenticate',
        //   child: const Icon(Icons.key_outlined),
        // ),
        // const SizedBox(width: 20),
        FloatingActionButton(
          onPressed: () => createPlayer('test'),
          tooltip: 'CreatePlayer',
          child: const Icon(Icons.add),
        ),
        const SizedBox(width: 20),
        FloatingActionButton(
          onPressed: () => unauthenticate(),
          tooltip: 'Decrement',
          child: const Icon(Icons.logout),
        ),
      ]), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    super.dispose();
    _counterBloc.dispose();
  }
}
