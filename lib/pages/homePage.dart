import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:CodeOfFlow/components/draggableCardWidget.dart';
import 'package:CodeOfFlow/components/dragTargetWidget.dart';
import 'package:CodeOfFlow/components/onGoingGameInfo.dart';
import 'package:CodeOfFlow/components/startButtons.dart';
import 'package:CodeOfFlow/components/timerComponent.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/models/putCardModel.dart';
import 'package:CodeOfFlow/services/api_service.dart';

const envFlavor = String.fromEnvironment('flavor');

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double cardPosition = 0.0;
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  APIService apiService = APIService();
  GameObject? gameObject;
  List<List<int>> mariganCardList = [];
  int mariganClickCount = 0;
  List<int> handCards = [];
  int gameProgressStatus = 0;
  int? tappedCardId;
  dynamic cardInfos;
  BuildContext? loadingContext;

  void doAnimation() {
    setState(() => cardPosition = 400.0);
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => cardPosition = 0.0);
    });
  }

  void showGameLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (buildContext) {
        loadingContext = buildContext;
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
    if (loadingContext != null) {
      Navigator.pop(loadingContext!);
    }
  }

  String getCardInfo(int? cardId) {
    if (cardInfos != null) {
      if (cardInfos[cardId.toString()] != null) {
        return cardInfos[cardId.toString()]['skill']['description'];
      }
      return '';
    } else {
      return '';
    }
  }

  void putCard(cardId) async {
    setState(() {
      gameObject!.yourCp =
          gameObject!.yourCp - int.parse(cardInfos[cardId.toString()]['cost']);
    });
    var fieldPosition = 0;
    var objStr = jsonToString(gameObject!.yourFieldUnit);
    var objJs = jsonDecode(objStr);

    for (int i = 1; i <= 5; i++) {
      if (objJs[i.toString()] == null) {
        fieldPosition = i;
        print('フィールド$iにカードを置きました!');
        break;
      }
    }
    Map<int, int> fieldUnit = {};
    fieldUnit[fieldPosition] = cardId;
    int enemySkillTarget = 0;
    Map<int, int> yourTriggerCards = {1: 0, 2: 0, 3: 0, 4: 0};
    List<int> usedInterceptCard = [];
    // showGameLoading();
    // Call GraphQL method.
    var message = PutCardModel(
        fieldUnit, enemySkillTarget, yourTriggerCards, usedInterceptCard);
    print(666);
    print(PutCardModel.convertToJson(message));
    // var ret = await apiService.saveGameServerProcess('put_card_on_the_field',
    //     jsonEncode(message), gameObject!.you.toString());
    // closeGameLoading();
    // debugPrint('transaction published');
    // if (ret != null) {
    //   debugPrint(ret.message);
    // }
  }

  void battleStart() async {
    gameProgressStatus = 2;
    // Call GraphQL method.
    if (gameObject != null) {
      showGameLoading();
      var ret = await apiService.saveGameServerProcess(
          'game_start', jsonEncode(handCards), gameObject!.you.toString());
      closeGameLoading();
      debugPrint('transaction published');
      if (ret != null) {
        debugPrint(ret.message);
      }
    }
  }

  final _timer = TimerComponent();
  void setDataAndMarigan(GameObject? data, List<List<int>>? mariganCards) {
    if (gameProgressStatus < 2) {
      setState(() => gameProgressStatus = 2); // リロードなどの対応
    }
    if (data != null) {
      if (gameObject != null) {
        if (data.yourCp > gameObject!.yourCp) {
          data.yourCp = gameObject!.yourCp;
        }
      }
      setState(() => gameObject = data);
    }

    // マリガン時のみこちらへ
    if (mariganCards != null) {
      setState(() => mariganCardList = mariganCards!);
      setState(() => mariganClickCount = 0);
      setState(() => handCards = mariganCards![mariganClickCount]);
      setState(() => gameProgressStatus = 1);
      // Start Marigan.
      _timer.countdownStart(8, battleStart);
    }

    // ハンドのブロックチェーンデータとの調整
    List<int> _hand = [];
    for (int i = 0; i < 7; i++) {
      var cardId = gameObject!.yourHand[i.toString()];
      if (cardId != null) {
        _hand.add(int.parse(cardId));
      }
    }
    setState(() => handCards = _hand);
  }

  void setCardInfo(cardInfo) {
    setState(() => cardInfos = cardInfo);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  gameProgressStatus >= 1
                      ? AnimatedContainer(
                          margin: EdgeInsetsDirectional.only(top: cardPosition),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.linear,
                          child: Row(
                            children: [
                              for (var cardId in handCards)
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tappedCardId = cardId;
                                      });
                                    },
                                    child: DragBox(cardId, putCard)),
                              const SizedBox(width: 5),
                            ],
                          ),
                        )
                      : AnimatedContainer(
                          margin: EdgeInsetsDirectional.only(top: cardPosition),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.linear,
                          child: Row(
                            children: [
                              DragBox(16, putCard),
                              DragBox(17, putCard),
                              DragBox(18, putCard),
                              DragBox(19, putCard),
                              DragBox(1, putCard),
                              DragBox(2, putCard),
                              DragBox(3, putCard),
                              const SizedBox(width: 5),
                            ],
                          ),
                        ),
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
                            const EdgeInsets.fromLTRB(150.0, 200.0, 30.0, 0.0),
                        child: DragTargetWidget(
                            'trigger',
                            '${imagePath}trigger/trigger.png',
                            gameObject,
                            cardInfos),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: DragTargetWidget('unit',
                            '${imagePath}unit/bg-2.jpg', gameObject, cardInfos),
                      ),
                    ])),
            Visibility(
                visible: gameProgressStatus == 1,
                child: Positioned(
                    left: 320,
                    top: 420,
                    child: SizedBox(
                        width: 120.0,
                        child: StreamBuilder<int>(
                            stream: _timer.events.stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<int> snapshot) {
                              return Center(
                                  child: Text(
                                '0:0${snapshot.data.toString()}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 46.0),
                              ));
                            })))),
            Visibility(
                visible: mariganClickCount < 5 && gameProgressStatus == 1,
                child: Positioned(
                    left: 500,
                    top: 420,
                    child: SizedBox(
                        width: 120.0,
                        child: FloatingActionButton(
                            backgroundColor: Colors.transparent,
                            onPressed: () {
                              if (mariganClickCount < 5) {
                                setState(() =>
                                    mariganClickCount = mariganClickCount + 1);
                                setState(() => handCards =
                                    mariganCardList[mariganClickCount]);
                              }
                            },
                            tooltip: 'Play',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                '${imagePath}button/redo.png',
                                fit: BoxFit.cover, //prefer cover over fill
                              ),
                            )))))
          ]),
          gameObject != null
              ? OnGoingGameInfo(gameObject, getCardInfo(tappedCardId))
              : Container(),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: StartButtons(gameProgressStatus,
            (status, data, mariganCards, cardInfo) {
          switch (status) {
            case 'game-is-ready':
              doAnimation();
              break;
            case 'matching-success':
              setDataAndMarigan(data, mariganCards);
              break;
            case 'started-game-info':
              setDataAndMarigan(data, null);
              break;
            case 'other-game-info':
              setDataAndMarigan(data, null);
              break;
            case 'card-info':
              setCardInfo(cardInfo);
              break;
          }
        }));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
