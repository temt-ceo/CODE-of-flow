import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:CodeOfFlow/bloc/attack_status/attack_status_bloc.dart';
import 'package:CodeOfFlow/components/draggableCardWidgetForDeckEditor.dart';
import 'package:CodeOfFlow/components/dragTargetWidget.dart';
import 'package:CodeOfFlow/components/deckCardInfo.dart';
import 'package:CodeOfFlow/components/deckButtons.dart';
import 'package:CodeOfFlow/components/timerComponent.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/responsive/dimensions.dart';
import 'package:CodeOfFlow/services/api_service.dart';

const envFlavor = String.fromEnvironment('flavor');

class DeckEditPage extends StatefulWidget {
  final bool enLocale;
  const DeckEditPage({super.key, required this.enLocale});

  @override
  State<DeckEditPage> createState() => DeckEditPageState();
}

class DeckEditPageState extends State<DeckEditPage> {
  double cardPosition = 0.0;
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  final AttackStatusBloc attackStatusBloc = AttackStatusBloc();
  APIService apiService = APIService();
  GameObject? gameObject;
  List<List<int>> mariganCardList = [];
  int mariganClickCount = 0;
  List<int> handCards = [];
  int gameProgressStatus = 0;
  int? tappedCardId;
  dynamic cardInfos;
  BuildContext? loadingContext;
  int? removedCardId;
  int? removedPosition;

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

  void putCard(cardId) async {}
  void tapCard(message, cardId, index) {
    if (message == 'tapped') {
      setState(() {
        tappedCardId = cardId;
        removedPosition = null;
      });
    } else if (message == 'remove') {
      setState(() {
        removedCardId = cardId;
        removedPosition = index;
      });
    }
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

  @override
  void initState() {
    super.initState();
    listenBCGGameServerProcess();
  }

  void listenBCGGameServerProcess() async {
    await apiService.subscribeBCGGameServerProcess();
  }

  String getCardInfo(int? cardId) {
    if (cardInfos != null) {
      if (cardInfos[cardId.toString()] != null) {
        String ret = L10n.of(context)!.cardDescription;
        return ret.split('|')[cardId! - 1];
      }
      return '';
    } else {
      return '';
    }
  }

  void setCardInfo(cardInfo) {
    setState(() => cardInfos = cardInfo);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (layoutContext, constraints) {
      final wRes = constraints.maxWidth / desktopWidth;
      double r(double val) {
        return val * wRes;
      }

      return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(children: <Widget>[
            Stack(fit: StackFit.expand, children: <Widget>[
              Positioned(
                  left: r(10.0),
                  top: r(430.0),
                  child: Row(children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: r(15.0)),
                        child: Container(
                          width: r(280.0),
                          height: r(160.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('${imagePath}unit/bg-2.jpg'),
                                fit: BoxFit.cover),
                          ),
                        )),
                    SizedBox(
                        width: r(1040.0),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(r(5)),
                            child: Row(
                              children: [
                                for (int cardId = 1; cardId <= 26; cardId++)
                                  cardInfos == null || cardId == 12
                                      ? Container()
                                      : GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              tappedCardId = cardId;
                                            });
                                          },
                                          child: DragBoxForDeckEditor(
                                              cardId,
                                              putCard,
                                              cardInfos[cardId.toString()],
                                              removedCardId,
                                              r)),
                              ],
                            ))),
                  ])),
              Positioned(
                  left: r(20.0),
                  top: r(40.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              r(0.0), r(20.0), r(30.0), r(0.0)),
                          child: DragTargetWidget(
                              'deck',
                              '${imagePath}unit/bg-2.jpg',
                              gameObject,
                              cardInfos,
                              tapCard,
                              removedPosition,
                              true,
                              attackStatusBloc.attack_stream,
                              r),
                        ),
                      ])),
            ]),
            DeckCardInfo(gameObject, getCardInfo(tappedCardId), 'deckEditor'),
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
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
