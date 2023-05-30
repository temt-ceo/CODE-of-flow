@JS()
library index;

import 'dart:async';
import 'package:js/js.dart';
import 'package:flutter/material.dart';

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

@JS('isRegistered')
external dynamic isRegistered(String? address);

@JS('getPlayerUUId')
external String? getPlayerUUId(dynamic player);

@JS('getPlayerId')
external String? getPlayerId(dynamic player);

@JS('getPlayerName')
external String? getPlayerName(dynamic player);

typedef void StringCallback(String val);

class StartButtons extends StatefulWidget {
  final StringCallback callback;

  const StartButtons(this.callback);

  @override
  StartButtonsState createState() => StartButtonsState();
}

class WalletUser {
  late String addr;
  WalletUser(this.addr);
}

class PlayerResource {
  late String uuid;
  late String playerId;
  late String nickname;
  PlayerResource(this.uuid, this.playerId, this.nickname);
}

class StartButtonsState extends State<StartButtons> {
  // Offset position = const Offset(0.0, 0.0);
  final nameController = TextEditingController();
  WalletUser walletUser = WalletUser('');
  PlayerResource player = PlayerResource('', '', '');
  bool onTyping = false;
  bool onClickButton = false;

  @override
  void initState() {
    super.initState();
    // position = widget.initPos;
  }

  void setupWallet(user) {
    if (walletUser.addr == '') {
      String? addr = getAddr(user);
      if (addr == null) {
        setState(() => walletUser = WalletUser(''));
      } else {
        setState(() => walletUser = WalletUser(addr));
        if (player.uuid == '') {
          getPlayerInfo(addr);
          widget.callback('game-is-ready');
        }
      }
    }
  }

  void getPlayerInfo(addr) async {
    await isRegistered(addr).then((ret) {
      if (ret != null) {
        String? playerId = getPlayerId(ret);
        String? playerName = getPlayerName(ret);
        String? playerUUId = getPlayerUUId(ret);
        setState(
            () => player = PlayerResource(playerUUId!, playerId!, playerName!));
      }
    });
  }

  void signout() {
    unauthenticate();
    setState(() => walletUser = WalletUser(''));
    setState(() => player = PlayerResource('', '', ''));
  }

  @override
  Widget build(BuildContext context) {
    subscribe(allowInterop(setupWallet));
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            walletUser.addr == ''
                ? 'connect to wallet→'
                : (player.nickname == ''
                    ? walletUser.addr
                    : 'Player: ${player.nickname}'),
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
      Visibility(
          visible: walletUser.addr != '' && player.uuid == '',
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  backgroundColor: const Color.fromARGB(195, 54, 219, 244),
                  barrierColor: Colors.transparent,
                  builder: (context) {
                    return SizedBox(
                        child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
                            child: Column(children: <Widget>[
                              const Text(
                                  'プレイヤー名を入力して下さい。\n(Please input a Player Name.)',
                                  style: TextStyle(color: Color(0xFFFFFFFF))),
                              const SizedBox(height: 5.0),
                              SizedBox(
                                  width: 250.0,
                                  child: Focus(
                                    child: TextField(
                                      controller: nameController,
                                      style: const TextStyle(
                                          color: Color(0xFFFFFFFF)),
                                    ),
                                    onFocusChange: (hasFocus) {
                                      setState(() => onTyping = hasFocus);
                                    },
                                  )),
                              const SizedBox(height: 60.0),
                              Visibility(
                                visible: onClickButton == true,
                                child: const CircularProgressIndicator(),
                              ),
                              const SizedBox(height: 10.0),
                              Visibility(
                                  visible: onTyping == false &&
                                      nameController.text != '',
                                  child: Text(
                                    '${nameController.text}でよろしければ以下のボタンを押して下さい。',
                                    style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 16.0,
                                    ),
                                  )),
                              const SizedBox(height: 20.0),
                              Center(
                                  child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10), //丸み具合
                                    ),
                                  ),
                                ),
                                onPressed: onTyping == false &&
                                        nameController.text != ''
                                    ? () {
                                        setState(() => onClickButton = true);
                                        createPlayer(nameController.text);
                                        // setInterval by every 2 second
                                        Timer.periodic(
                                            const Duration(seconds: 2),
                                            (timer) {
                                          getPlayerInfo(walletUser.addr);
                                          debugPrint(timer.tick.toString());
                                          if (player.uuid != '') {
                                            timer.cancel();
                                            setState(
                                                () => onClickButton = false);
                                            Navigator.of(context).pop();
                                            widget.callback('game-is-ready');
                                          }
                                        });
                                      }
                                    : null,
                                child: const Text('Create a Player'),
                              )),
                              const SizedBox(height: 10.0),
                              Center(
                                  child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10), //丸み具合
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              )),
                            ])));
                  });
            },
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
    ]);
  }
}
