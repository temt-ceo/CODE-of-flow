import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:CodeOfFlow/components/draggableCardWidgetForDeckEditor.dart';
import 'package:CodeOfFlow/components/dragTargetWidget.dart';
import 'package:CodeOfFlow/components/deckCardInfo.dart';
import 'package:CodeOfFlow/components/deckButtons.dart';
import 'package:CodeOfFlow/components/timerComponent.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/models/put_card_model.dart';
import 'package:CodeOfFlow/services/api_service.dart';

const envFlavor = String.fromEnvironment('flavor');

class DeckEditPage extends StatefulWidget {
  DeckEditPage({super.key, required this.title});
  final String title;

  @override
  State<DeckEditPage> createState() => DeckEditPageState();
}

class DeckEditPageState extends State<DeckEditPage> {
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
    // // Unit case
    // if (cardId > 16) {
    //   return;
    // }

    // setState(() {
    //   gameObject!.yourCp =
    //       gameObject!.yourCp - int.parse(cardInfos[cardId.toString()]['cost']);
    // });
    // var objStr = jsonToString(gameObject!.yourFieldUnit);
    // var objJs = jsonDecode(objStr);

    // List<int?> unitPositions = [null, null, null, null, null];
    // for (int i = 1; i <= 5; i++) {
    //   if (objJs[i.toString()] == null) {
    //     unitPositions[i - 1] = cardId;
    //     print('フィールド$iにカードを置きました!');
    //     break;
    //   } else {
    //     unitPositions[i - 1] = objJs[i.toString()];
    //   }
    // }

    // var objStr2 = jsonToString(gameObject!.yourTriggerCards);
    // var objJs2 = jsonDecode(objStr2);
    // List<int?> triggerPositions = [null, null, null, null];
    // for (int i = 1; i <= 4; i++) {
    //   if (objJs2[i.toString()] != null) {
    //     triggerPositions[i - 1] = objJs2[i.toString()];
    //   }
    // }

    // FieldUnits fieldUnit = FieldUnits(unitPositions[0], unitPositions[1],
    //     unitPositions[2], unitPositions[3], unitPositions[4]);
    // int enemySkillTarget = 0;
    // TriggerCards triggerCards = TriggerCards(triggerPositions[0],
    //     triggerPositions[1], triggerPositions[2], triggerPositions[3]);
    // List<int> usedInterceptCard = [];
    // showGameLoading();
    // // Call GraphQL method.
    // var message = PutCardModel(
    //     fieldUnit, enemySkillTarget, triggerCards, usedInterceptCard);
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
    listenBCGGameServerProcess();
  }

  void listenBCGGameServerProcess() async {
    await apiService.subscribeBCGGameServerProcess();
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
                top: 430.0,
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
                  SizedBox(
                      width: 1050.0,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            children: [
                              for (int cardId = 1; cardId <= 16; cardId++)
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tappedCardId = cardId;
                                      });
                                    },
                                    child:
                                        DragBoxForDeckEditor(cardId, putCard)),
                            ],
                          ))),
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
                            const EdgeInsets.fromLTRB(0.0, 20.0, 30.0, 0.0),
                        child: DragTargetWidget('deck',
                            '${imagePath}unit/bg-2.jpg', gameObject, cardInfos),
                      ),
                    ])),
          ]),
          gameObject != null
              ? DeckCardInfo(gameObject, getCardInfo(tappedCardId))
              : Container(),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: DeckButtons(gameProgressStatus,
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
