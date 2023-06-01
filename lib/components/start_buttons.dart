@JS()
library index;

import 'dart:async';
import 'dart:convert';
import 'dart:js_util';
import 'package:js/js.dart';
import 'package:flutter/material.dart';
import 'package:CodeOfFlow/services/api_service.dart';
import 'package:CodeOfFlow/models/on_going_info_model.dart';
import 'package:CodeOfFlow/components/timerComponent.dart';

const envFlavor = String.fromEnvironment('flavor');

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

@JS('getCurrentStatus')
external dynamic getCurrentStatus(String? address);

@JS('getMariganCards')
external dynamic getMariganCards(String? address, int playerId);

@JS('getPlayerUUId')
external String? getPlayerUUId(dynamic player);

@JS('getPlayerId')
external String? getPlayerId(dynamic player);

@JS('getPlayerName')
external String? getPlayerName(dynamic player);

typedef void StringCallback(
    String val, GameObject? data, List<List<int>>? mariganCards);

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
  final nameController = TextEditingController();
  APIService apiService = APIService();
  WalletUser walletUser = WalletUser('');
  PlayerResource player = PlayerResource('', '', '');
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  bool onTyping = false;
  bool onClickButton = false;
  double imagePosition = 0.0;
  late StreamController<bool> _wait;

  @override
  void initState() {
    super.initState();
    _wait = StreamController<bool>();
  }

  void setupWallet(user) {
    if (walletUser.addr == '') {
      String? addr = getAddr(user);
      if (addr == null) {
        setState(() => walletUser = WalletUser(''));
      } else {
        setState(() => walletUser = WalletUser(addr));
        if (player.uuid == '') {
          getPlayerInfo();
          widget.callback('game-is-ready', null, null);
        }
      }
    }
  }

  void getPlayerInfo() async {
    var ret = await promiseToFuture(isRegistered(walletUser.addr));
    if (ret != null) {
      String? playerId = getPlayerId(ret);
      String? playerName = getPlayerName(ret);
      String? playerUUId = getPlayerUUId(ret);
      debugPrint('PlayerId: $playerId');
      setState(
          () => player = PlayerResource(playerUUId!, playerId!, playerName!));
    }
  }

  void showGameLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Container(
          color: Colors.transparent,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void closeGameLoading() {
    Navigator.pop(context);
  }

  Future<void> gameStart() async {
    showGameLoading();
    // Call GraphQL method.
    var ret = await apiService.saveGameServerProcess(
        'player_matching', '', player.playerId);
    closeGameLoading();
    debugPrint('transaction published');
    if (ret != null) {
      debugPrint(ret.message);
    }
  }

  void countdown() {
    var timer = TimerComponent();
    timer.countdownStart(60, null);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StreamBuilder<int>(
              stream: timer.events.stream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                return Container(
                    width: 200.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('${imagePath}unit/bg-2.jpg'),
                          fit: BoxFit.contain),
                      boxShadow: [
                        BoxShadow(
                          color: Color(snapshot.data ?? 0xFFFFFFFF),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(2, 5), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                        child: Text(
                      '00:${snapshot.data.toString()}',
                      style:
                          const TextStyle(color: Colors.black, fontSize: 46.0),
                    )));
              });
        });
  }

  void battleStartAnimation() {
    _wait.add(true);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StreamBuilder<bool>(
              stream: _wait.stream,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return AnimatedContainer(
                    margin: EdgeInsetsDirectional.only(top: imagePosition),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInQuart,
                    child: Container(
                      width: 200.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                snapshot.data != null && snapshot.data == true
                                    ? '${imagePath}unit/battleStart.png'
                                    : '${imagePath}unit/battleStart2.png'),
                            fit: BoxFit.cover),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFFFFFFF),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(2, 5), // changes position of shadow
                          ),
                        ],
                      ),
                    ));
              });
        });
    setState(() => imagePosition = 80.0);
    Future.delayed(const Duration(milliseconds: 1800), () {
      setState(() => imagePosition = 0.0);
      _wait.add(false);
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      closeGameLoading();
    });
  }

  GameObject setGameInfo(obj) {
    return GameObject(
      int.parse(obj.turn),
      obj.is_first,
      obj.is_first_turn,
      obj.matched_time,
      obj.game_started,
      obj.last_time_turnend,
      obj.enemy_attacking_cards,
      int.parse(player.playerId),
      int.parse(obj.your_cp),
      obj.your_field_unit,
      obj.your_field_unit_action,
      obj.your_field_unit_bp_amount_of_change,
      obj.your_hand,
      int.parse(obj.your_life),
      obj.your_remain_deck,
      obj.your_trigger_cards,
      int.parse(obj.opponent),
      int.parse(obj.opponent_cp),
      obj.opponent_field_unit,
      obj.opponent_field_unit_action,
      obj.opponent_field_unit_bp_amount_of_change,
      int.parse(obj.opponent_hand),
      int.parse(obj.opponent_life),
      int.parse(obj.opponent_remain_deck),
      int.parse(obj.opponent_trigger_cards),
    );
  }

  List<List<int>> setMariganCards(arr) {
    final List<List<int>> retArr = [];
    for (int i = 0; i < 5; i++) {
      retArr.add([]);
      for (int j = 0; j < 4; j++) {
        retArr[i].add(int.parse(arr[i][j]));
      }
    }
    return retArr;
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
      Visibility(
          visible: walletUser.addr == '', child: const SizedBox(width: 20)),
      Visibility(
          visible: walletUser.addr == '',
          child: const FloatingActionButton(
            onPressed: authenticate,
            tooltip: 'Authenticate',
            child: Icon(Icons.key_outlined),
          )),
      Visibility(
          visible: walletUser.addr != '' && player.uuid == '',
          child: const SizedBox(width: 20)),
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
                                          getPlayerInfo();
                                          debugPrint(timer.tick.toString());
                                          if (player.uuid != '') {
                                            timer.cancel();
                                            setState(
                                                () => onClickButton = false);
                                            Navigator.of(context).pop();
                                            widget.callback(
                                                'game-is-ready', null, null);
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
      const SizedBox(width: 10),
      Visibility(
          visible: walletUser.addr != '' && player.uuid != '',
          child: SizedBox(
              width: 150.0,
              child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  onPressed: () async {
                    //GraphQL:player_matching
                    await gameStart();
                    countdown();
                    // setInterval by every 2 second
                    Timer.periodic(const Duration(seconds: 2), (timer) async {
                      dynamic ret = await promiseToFuture(
                          getCurrentStatus(walletUser.addr));
                      if (ret.game_started == true ||
                          ret.game_started == false) {
                        dynamic data = await promiseToFuture(getMariganCards(
                            walletUser.addr, int.parse(player.playerId)));
                        widget.callback('matching-success', setGameInfo(ret),
                            setMariganCards(data));
                        timer.cancel();
                        closeGameLoading();
                        battleStartAnimation();
                      } else {
                        double num = double.parse(ret);
                        if (num > 1685510325) {
                          // debugPrint(
                          //     'matching.. ${(timer.tick * 2).toString()}s');
                        }
                      }
                    });
                  },
                  tooltip: 'Play',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      '${imagePath}button/playButton.png',
                      fit: BoxFit.cover, //prefer cover over fill
                    ),
                  )))),
      const SizedBox(width: 5),
      Visibility(
          visible: walletUser.addr != '',
          child: FloatingActionButton(
            onPressed: signout,
            tooltip: 'Sign Out',
            child: const Icon(Icons.logout),
          )),
    ]);
  }
}
