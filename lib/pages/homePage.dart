@JS()
library index;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:CodeOfFlow/components/draggableCardWidget.dart';
import 'package:CodeOfFlow/components/dragTargetWidget.dart';
import 'package:CodeOfFlow/components/battleInfo.dart';
import 'package:CodeOfFlow/bloc/counter/counter_bloc.dart';

@JS('authenticate')
external void authenticate();

@JS('unauthenticate')
external void unauthenticate();

@JS('subscribe')
external void subscribe(dynamic user);

@JS('createPlayer')
external void createPlayer(String? name);

@JS('getAddr')
external String? getAddr(dynamic user);

const env_flavor = String.fromEnvironment('flavor');

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class WalletUser {
  late String addr;
  WalletUser(this.addr);
}

class HomePageState extends State<HomePage> {
  final CounterBloc _counterBloc = CounterBloc();
  String imagePath = env_flavor == 'prod' ? 'assets/image/' : 'image/';
  WalletUser walletUser = WalletUser('');

  @override
  Widget build(BuildContext context) {
    void setupWallet(user) {
      String? addr = getAddr(user);
      if (addr == null) {
        setState(() => walletUser = WalletUser(''));
      } else {
        setState(() => walletUser = WalletUser(addr));
      }
    }

    void signout() {
      unauthenticate();
      setState(() => walletUser = WalletUser(''));
    }

    subscribe(allowInterop(setupWallet));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.title,
            style: const TextStyle(color: Color(0xFFFFFFFF))),
      ),
      body: Stack(children: <Widget>[
        Stack(fit: StackFit.expand, children: <Widget>[
          Positioned(
              left: 10.0,
              top: 480.0,
              child: Row(children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Container(
                      width: 280.0,
                      height: 160.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('${imagePath}unit/bg-2.jpg'),
                            fit: BoxFit.cover),
                      ),
                    )),
                DragBox('', '${imagePath}unit/card_16.jpeg'),
                DragBox('', '${imagePath}trigger/card_17.jpeg'),
                DragBox('', '${imagePath}trigger/card_18.jpeg'),
                DragBox('', '${imagePath}trigger/card_19.jpeg'),
                DragBox('', '${imagePath}unit/card_1.jpeg'),
                DragBox('', '${imagePath}unit/card_2.jpeg'),
                DragBox('', '${imagePath}unit/card_3.jpeg'),
              ])),
          Positioned(
              left: 10.0,
              top: 30.0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(30.0, 130.0, 30.0, 10.0),
                      child: DragTargetWidget(
                          'trigger', '${imagePath}trigger/trigger.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child:
                          DragTargetWidget('unit', '${imagePath}unit/bg-2.jpg'),
                    ),
                  ])),
        ]),
        const BattleInfo(''),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              walletUser.addr == '' ? 'connect to wallet→' : walletUser.addr,
              style: const TextStyle(color: Colors.white, fontSize: 26.0),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Visibility(
            visible: walletUser.addr == '',
            child: const FloatingActionButton(
              onPressed: authenticate,
              tooltip: 'Authenticate',
              child: Icon(Icons.key_outlined),
            )),
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
        Visibility(
            visible: walletUser.addr != '',
            child: FloatingActionButton(
              onPressed: () => createPlayer('test'),
              tooltip: 'Create Player',
              child: const Icon(Icons.add),
            )),
        const SizedBox(width: 20),
        Visibility(
            visible: walletUser.addr != '',
            child: FloatingActionButton(
              onPressed: () => signout(),
              tooltip: 'Sign Out',
              child: const Icon(Icons.logout),
            )),
      ]), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    super.dispose();
    _counterBloc.dispose();
  }
}
