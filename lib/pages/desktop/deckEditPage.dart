import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:CodeOfFlow/bloc/attack_status/attack_status_bloc.dart';
import 'package:CodeOfFlow/bloc/attack_status/attack_status_event.dart';
import 'package:CodeOfFlow/components/draggableCardWidgetForDeckEditor.dart';
import 'package:CodeOfFlow/components/dragTargetWidget.dart';
import 'package:CodeOfFlow/components/deckCardInfo.dart';
import 'package:CodeOfFlow/components/deckButtons.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/responsive/dimensions.dart';
import 'package:CodeOfFlow/services/api_service.dart';

const envFlavor = String.fromEnvironment('flavor');

class DeckEditPage extends StatefulWidget {
  final bool enLocale;
  final bool isMobile;
  const DeckEditPage(
      {super.key, required this.enLocale, required this.isMobile});

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
  List<dynamic> playerDeck = [];
  int gameProgressStatus = 0;
  int? tappedCardId;
  dynamic cardInfos;
  BuildContext? loadingContext;

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

  void putCard(cardId) async {
    playerDeck.add(cardId.toString());
    setState(() => playerDeck = playerDeck);
  }

  void sort() async {
    playerDeck.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    setState(() => playerDeck = playerDeck);
  }

  void tapCard(message, cardId, index) {
    if (message == 'tapped') {
      attackStatusBloc.canAttackEventSink.add(ButtonTapepingEvent());
      setState(() {
        tappedCardId = cardId;
      });
    } else if (message == 'remove') {
      attackStatusBloc.canAttackEventSink.add(ButtonTapedEvent());
      playerDeck.removeAt(index);
      setState(() => playerDeck = playerDeck);
    }
  }

  @override
  void initState() {
    super.initState();
    listenBCGGameServerProcess();
  }

  void listenBCGGameServerProcess() async {
    await apiService.subscribeBCGGameServerProcess();
  }

  void setCardInfo(cardInfo) {
    setState(() => cardInfos = cardInfo);
  }

  void setPlayerDeck(dynamic userDeck) {
    setState(() => playerDeck = userDeck);
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
              // カード含むスクロールビュー
              Positioned(
                  left: r(340.0),
                  top: r(360.0),
                  child: Row(children: <Widget>[
                    SizedBox(
                        width: r(1040.0),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.only(top: r(5.0)),
                            child: Row(
                              children: [
                                for (int cardId = 1; cardId <= 29; cardId++)
                                  cardInfos == null || cardId == 12
                                      ? Container()
                                      : Row(children: [
                                          GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  tappedCardId = cardId;
                                                });
                                              },
                                              child: DragBoxForDeckEditor(
                                                  cardId,
                                                  putCard,
                                                  cardInfos[cardId.toString()],
                                                  playerDeck,
                                                  r)),
                                          Container(
                                            width: 8.0,
                                          ),
                                        ]),
                              ],
                            ))),
                  ])),
              // ドラッグ先
              Positioned(
                  left: r(20.0),
                  top: r(25.0),
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
                              null,
                              true,
                              attackStatusBloc.attack_stream,
                              playerDeck,
                              const [],
                              const [],
                              const [],
                              null,
                              '',
                              true,
                              false,
                              r,
                              widget.isMobile),
                        ),
                      ])),
            ]),
            // カード情報
            DeckCardInfo(gameObject, cardInfos, tappedCardId, 'deckEditor',
                widget.enLocale, r),
          ]),
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
          floatingActionButton:
              DeckButtons(gameProgressStatus, playerDeck, r, widget.isMobile,
                  (status, userDeck, cardInfo) {
            switch (status) {
              case 'player-deck':
                setPlayerDeck(userDeck);
                break;
              case 'card-info':
                setCardInfo(cardInfo);
                break;
              case 'sort':
                sort();
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
