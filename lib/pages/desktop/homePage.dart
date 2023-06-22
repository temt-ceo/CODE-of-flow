import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import 'package:amplify_api/amplify_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flash/flash.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:getwidget/getwidget.dart';
import 'package:quickalert/quickalert.dart';

import 'package:CodeOfFlow/bloc/attack_status/attack_status_bloc.dart';
import 'package:CodeOfFlow/bloc/attack_status/attack_status_event.dart';
import 'package:CodeOfFlow/components/draggableCardWidget.dart';
import 'package:CodeOfFlow/components/dragTargetWidget.dart';
import 'package:CodeOfFlow/components/onGoingGameInfo.dart';
import 'package:CodeOfFlow/components/startButtons.dart';
import 'package:CodeOfFlow/components/timerComponent.dart';
import 'package:CodeOfFlow/components/deckCardInfo.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/models/putCardModel.dart';
import 'package:CodeOfFlow/models/GameServerProcess.dart';
import 'package:CodeOfFlow/models/defenceActionModel.dart';
import 'package:CodeOfFlow/services/api_service.dart';
import 'package:CodeOfFlow/responsive/dimensions.dart';

const envFlavor = String.fromEnvironment('flavor');

class HomePage extends StatefulWidget {
  final bool enLocale;
  const HomePage({super.key, required this.enLocale});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double cardPosition = 0.0;
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  String videoPath = envFlavor == 'prod' ? 'assets/video/' : 'video/';
  APIService apiService = APIService();
  List<int> savedGraphQLIds = [];
  final AttackStatusBloc attackStatusBloc = AttackStatusBloc();
  bool gameStarted = false;
  GameObject? gameObject;
  List<List<int>> mariganCardIdList = [];
  int mariganClickCount = 0;
  int gameProgressStatus = 0;
  int? tappedCardId;
  dynamic cardInfos;
  List<dynamic> onChainYourFieldUnit = [];
  List<dynamic> defaultDropedList = [];
  List<int> handCards = [];
  List<int?> onChainYourTriggerCards = [];
  List<int?> yourTriggerCards = [];
  dynamic onChainHandCards;
  BuildContext? loadingContext;
  int? actedCardPosition;
  int? attackSignalPosition;
  String playerId = '';
  bool canOperate = true;
  final cController = CarouselController();
  int activeIndex = 0;
  bool showDefenceUnitsCarousel = false;
  int? opponentDefendPosition;
  List<int>? yourUsedInterceptCard;
  List<int>? opponentUsedInterceptCard;
  List<int> attackerUsedCardIds = [];
  List<int> defenderUsedCardIds = [];
  VideoPlayerController? vController;
  bool showVideo = true;
  int? onBattlePosition;
  bool? isEnemyAttack;
  bool canUseIntercept = false;

  @override
  void initState() {
    super.initState();
    // GraphQL Subscription
    listenBCGGameServerProcess();
    // _initVideoPlayer();
  }

  /*
  **  GraphQL Subscription
  */
  void listenBCGGameServerProcess() async {
    Stream<GraphQLResponse<GameServerProcess>> operation =
        apiService.subscribeBCGGameServerProcess();
    operation.listen(
      (event) {
        print('*** Subscription event data received: ${event.data}');
        var ret = event.data;
        if (ret != null) {
          print('No. ${ret.playerId} : ${ret.type}');
          print(ret.message);
          if (!savedGraphQLIds.any((element) => element == int.parse(ret.id))) {
            savedGraphQLIds.add(int.parse(ret.id));
            print('savedGraphQLIds Check : $savedGraphQLIds'); // DEBUG
            print('savedGraphQLIds ID Check : ${ret.id}'); // DEBUG
            if (ret.type == 'player_matching' && playerId == ret.playerId) {
              String transactionId = ret.message.split(',TransactionID:')[1];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showFlash(
                    context: context,
                    duration: const Duration(seconds: 4),
                    builder: (context, controller) {
                      return Flash(
                        controller: controller,
                        position: FlashPosition.bottom,
                        child: FlashBar(
                          controller: controller,
                          title: const Text('Player Matching is in progress.'),
                          content: Text('Transaction ID: $transactionId'),
                          indicatorColor: Colors.blue,
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    });
              });
            } else if (ret.type == 'player_matching' && gameObject == null) {
              showToast("No. ${ret.playerId} has entered in Alcana.");
            } else if (ret.type == 'turn_change' &&
                gameObject != null &&
                (gameObject!.you.toString() == ret.playerId ||
                    gameObject!.opponent.toString() == ret.playerId)) {
              if (attackSignalPosition == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showFlash(
                      context: context,
                      duration: const Duration(seconds: 7),
                      builder: (context, controller) {
                        return Flash(
                          controller: controller,
                          position: FlashPosition.bottom,
                          child: FlashBar(
                            controller: controller,
                            content: const Text('Turn Change!',
                                style: TextStyle(fontSize: 24.0)),
                            indicatorColor: Colors.blue,
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.blue,
                            ),
                          ),
                        );
                      });
                });
              }
              // あなたの攻撃
            } else if (ret.type == 'attack' &&
                gameObject != null &&
                (gameObject!.you.toString() == ret.playerId)) {
              var msg = jsonDecode(ret.message.split(',TransactionID:')[0]);
              var usedInterceptPositions = msg['arg4'];
              // 攻撃時に使用したトリガーカード
              List<int> _yourUsedInterceptCard = [];
              for (var i in usedInterceptPositions) {
                _yourUsedInterceptCard.add(int.parse(i));
              }
              setState(() => yourUsedInterceptCard = _yourUsedInterceptCard);
              attackStatusBloc.canAttackEventSink.add(BattlingEvent());
              // トリガーカードが発動したことを攻撃者に伝える
              if (yourUsedInterceptCard!.isNotEmpty) {
                String toastMsg = L10n.of(context)!
                    .yourAttackTrigger(yourUsedInterceptCard!.length);
                showFlash(
                    context: context,
                    duration: const Duration(seconds: 4),
                    builder: (context, controller) {
                      return Flash(
                        controller: controller,
                        position: FlashPosition.bottom,
                        child: FlashBar(
                          controller: controller,
                          content: Text(toastMsg,
                              style: const TextStyle(fontSize: 24.0)),
                          indicatorColor: Colors.blue,
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    });
              }
              // 敵の攻撃
            } else if (ret.type == 'attack' &&
                gameObject != null &&
                (gameObject!.opponent.toString() == ret.playerId)) {
              showDefenceUnitsCarousel = true;
              var msg = jsonDecode(ret.message.split(',TransactionID:')[0]);
              onBattlePosition = msg['arg1'];
              var usedInterceptPositions = msg['arg4'];
              // 攻撃時に使用したトリガーカード
              List<int> _yourUsedInterceptCard = [];
              for (var i in usedInterceptPositions) {
                _yourUsedInterceptCard.add(int.parse(i));
              }
              setState(() => yourUsedInterceptCard = _yourUsedInterceptCard);
              isEnemyAttack = true;
              attackStatusBloc.canAttackEventSink.add(BattlingEvent());
              String toastMsg = L10n.of(context)!.opponentAttack;
              if (yourUsedInterceptCard!.isNotEmpty) {
                toastMsg =
                    '$toastMsg ${L10n.of(context)!.opponentAttackTrigger(yourUsedInterceptCard!.length)}';
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showFlash(
                    context: context,
                    duration: const Duration(seconds: 4),
                    builder: (context, controller) {
                      return Flash(
                        controller: controller,
                        position: FlashPosition.bottom,
                        child: FlashBar(
                          controller: controller,
                          content: Text(toastMsg,
                              style: const TextStyle(fontSize: 24.0)),
                          indicatorColor: Colors.blue,
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    });
              });
              // バトルの相手側の対応
            } else if (ret.type == 'battle_reaction' &&
                gameObject != null &&
                gameObject!.opponent.toString() == ret.playerId) {
              attackStatusBloc.canAttackEventSink.add(BattlingEvent());
              var msg = jsonDecode(ret.message.split(',TransactionID:')[0]);
              onBattlePosition = msg['arg1'];
              // isEnemyAttackがnullの場合はfalseをセットする。
              isEnemyAttack ??= false;
              // 攻撃側が使用中のトリガー/インターセプトカードをセット
              List<int> _attackerUsedCardIds = [];
              for (var i in msg['attackerUsedCardIds']) {
                _attackerUsedCardIds.add(int.parse(i));
              }
              setState(() => attackerUsedCardIds = _attackerUsedCardIds);
              // 防御側が使用中のトリガー/インターセプトカードをセット
              List<int> _defenderUsedCardIds = [];
              for (var i in msg['defenderUsedCardIds']) {
                _defenderUsedCardIds.add(int.parse(i));
              }
              setState(() => defenderUsedCardIds = _defenderUsedCardIds);

              /////////////////
              //// Ability ////
              /////////////////
              // トリガーゾーンのカードはバトル時に発動可能なインターセプトか?
              if (onChainYourTriggerCards.isNotEmpty &&
                  onChainYourTriggerCards[0] == 26) {
                // 無色か同色のカードがフィールドにあるので選択可能
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex1Event());
                canUseIntercept = true;
              } else if (onChainYourTriggerCards.isNotEmpty &&
                  onChainYourTriggerCards[1] == 26) {
                // 無色か同色のカードがフィールドにあるので選択可能
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex2Event());
                canUseIntercept = true;
              } else if (onChainYourTriggerCards.isNotEmpty &&
                  onChainYourTriggerCards[2] == 26) {
                // 無色か同色のカードがフィールドにあるので選択可能
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex3Event());
                canUseIntercept = true;
              } else if (onChainYourTriggerCards.isNotEmpty &&
                  onChainYourTriggerCards[3] == 26) {
                // 無色か同色のカードがフィールドにあるので選択可能
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex4Event());
                canUseIntercept = true;
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                showFlash(
                    context: context,
                    duration: const Duration(seconds: 4),
                    builder: (context, controller) {
                      return Flash(
                        controller: controller,
                        position: FlashPosition.bottom,
                        child: FlashBar(
                          controller: controller,
                          content: Text(L10n.of(context)!.opponentBlocking,
                              style: const TextStyle(fontSize: 24.0)),
                          indicatorColor: Colors.blue,
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    });
              });
            } else if (ret.type == 'defence_action' &&
                gameObject != null &&
                (gameObject!.you.toString() == ret.playerId ||
                    gameObject!.opponent.toString() == ret.playerId)) {
              // バトルパラメータをnullにする
              setState(() {
                onBattlePosition = null;
                isEnemyAttack = null;
                showDefenceUnitsCarousel = false;
                opponentDefendPosition = null;
                yourUsedInterceptCard = null;
                opponentUsedInterceptCard = null;
                attackerUsedCardIds = [];
                defenderUsedCardIds = [];
                actedCardPosition = null;
                canUseIntercept = false;
              });

              attackStatusBloc.canAttackEventSink.add(BattleFinishedEvent());
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    attackSignalPosition = null;
                  });
                }
              });
            }
          }
        }
      },
      onError: (Object e) => debugPrint('Error in subscription stream: $e'),
    );
  }

  // 動画AutoPlay(但し、ブラウザ制約がありOmit)
  // void _initVideoPlayer() async {
  //   vController = VideoPlayerController.asset('${videoPath}sample-5s.mp4');
  //   Future.delayed(const Duration(seconds: 1), () async {
  //     // await vController!.initialize();
  //     // // Ensuring the first frame is shown after the video is initialized.
  //     // setState(() {});
  //     // vController!.setVolume(0);
  //     // vController!.play();
  //     Future.delayed(const Duration(seconds: 5), () async {
  //       setState(() => showVideo = false);
  //     });
  //   });
  // }

  /*
  **  ブロック処理
  */
  void block(int activeIndex) async {
    setState(() {
      showDefenceUnitsCarousel = false;
      opponentDefendPosition = activeIndex + 1;
      opponentUsedInterceptCard = [];
      canUseIntercept = false;
      attackerUsedCardIds =
          []; // これはブロックチェーンから取ってくるしかない。相手のトリガーゾーンに何が入っているかは相手の攻撃アクション時にはわからない。
      defenderUsedCardIds = [];
    });
    // Battle Reaction
    showGameLoading();
    var message = DefenceActionModel(
        opponentDefendPosition!,
        yourUsedInterceptCard!,
        opponentUsedInterceptCard!,
        attackerUsedCardIds,
        defenderUsedCardIds);
    var ret = await apiService.saveGameServerProcess(
        'battle_reaction', jsonEncode(message), gameObject!.you.toString());
    closeGameLoading();
    debugPrint('== transaction published ==');
    debugPrint('== ${ret.toString()} ==');
    if (ret != null) {
      debugPrint(ret.message);
    }
  }

  /*
  **  インターセプトカード使用処理
  */
  void useInterceptCard(int cardId, int activeIndex) async {
    if (isEnemyAttack != null) {
      if (isEnemyAttack == true) {
        setState(() {
          opponentUsedInterceptCard!.add(activeIndex);
          defenderUsedCardIds.add(cardId);
        });
      } else {
        setState(() {
          yourUsedInterceptCard!.add(activeIndex);
          attackerUsedCardIds.add(cardId);
        });
      }
      // Battle Reaction
      showGameLoading();
      var message = DefenceActionModel(
          opponentDefendPosition!,
          yourUsedInterceptCard!,
          opponentUsedInterceptCard!,
          attackerUsedCardIds,
          defenderUsedCardIds);
      var ret = await apiService.saveGameServerProcess(
          'battle_reaction', jsonEncode(message), gameObject!.you.toString());
      closeGameLoading();
      debugPrint('== transaction published ==');
      debugPrint('== ${ret.toString()} ==');
      if (ret != null) {
        debugPrint(ret.message);
      }
    }
  }

  /*
  **  startButtonsで1秒おきにデータ取得した後の処理
  */
  final _timer = TimerComponent();
  void setDataAndMarigan(GameObject? data, List<List<int>>? mariganCardIds) {
    bool turnChanged = false;
    if (gameProgressStatus < 2) {
      setState(() => gameProgressStatus = 2); // リロードなどの対応
    }
    if (data != null) {
      if (gameObject != null) {
        // CP使用済みなら、使用済みの方を使用する
        if (data.yourCp > gameObject!.yourCp) {
          data.yourCp = gameObject!.yourCp;
        }
        // ターンの変わり目を察知
        if (gameObject!.turn != data.turn ||
            gameObject!.isFirstTurn != data.isFirstTurn) {
          turnChanged = true;
        }
      }
    }
    setState(() => gameObject = data);

    // マリガン時のみこちらへ
    if (mariganCardIds != null) {
      setState(() => mariganCardIdList = mariganCardIds);
      setState(() => mariganClickCount = 0);
      setState(() => handCards = mariganCardIdList[mariganClickCount]);
      setState(() => gameProgressStatus = 1);
      // Start Marigan.
      _timer.countdownStart(8, battleStart);
    } else {
      if (turnChanged || onChainHandCards == null) {
        // ハンドのブロックチェーンデータとの調整
        List<int> _hand = [];
        for (int i = 1; i <= 7; i++) {
          var cardId = gameObject!.yourHand[i.toString()];
          if (cardId != null) {
            _hand.add(int.parse(cardId));
          }
        }
        // フイールドユニットのブロックチェーンデータとの調整
        List<dynamic> _units = [];
        for (int i = 1; i <= 5; i++) {
          _units.add(gameObject!.yourFieldUnit[i.toString()]);
        }
        // トリガーのブロックチェーンデータとの調整
        List<int?> _triggerCards = [];
        for (int i = 1; i <= 4; i++) {
          var cardId = gameObject!.yourTriggerCards[i.toString()];
          if (cardId != null) {
            _triggerCards.add(int.parse(cardId));
          } else {
            _triggerCards.add(null);
          }
        }
        if (gameObject!.yourLife == 0) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'You Lose...',
            text: 'Try Again!',
          );
        } else if (gameObject!.turn == 10) {
          if (gameObject!.yourLife < gameObject!.opponentLife ||
              (gameObject!.isFirst &&
                  gameObject!.yourLife == gameObject!.opponentLife)) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'You Lose...',
              text: 'Try Again!',
            );
          }
        }
        setState(() {
          handCards = _hand;
          onChainHandCards = gameObject!.yourHand;
          onChainYourFieldUnit = _units;
          onChainYourTriggerCards = _triggerCards;
          defaultDropedList = _units;
          yourTriggerCards = _triggerCards;
        });
      } else {
        setState(() {
          // フイールドユニットのブロックチェーンデータとの調整
          defaultDropedList = [];
          yourTriggerCards = [];
        });
      }

      // 攻撃可能かどうかをコンポーネントに通知
      if (gameObject!.isFirst == gameObject!.isFirstTurn) {
        if (gameObject!.lastTimeTurnend != null) {
          DateTime lastTurnEndTime = DateTime.fromMillisecondsSinceEpoch(
              double.parse(gameObject!.lastTimeTurnend!).toInt() * 1000);
          final turnEndTime = lastTurnEndTime.add(const Duration(seconds: 65));
          final now = DateTime.now();

          if (turnEndTime.difference(now).inSeconds > 0) {
            attackStatusBloc.canAttackEventSink.add(AttackAllowedEvent());
          } else {
            attackStatusBloc.canAttackEventSink.add(AttackAllowedEvent());
          }
        }
      } else {
        attackStatusBloc.canAttackEventSink.add(AttackAllowedEvent());
      }
    }
  }

  // ドラッグ&ドロップ後の処理
  void putCard(cardId) async {
    if (gameObject == null) return;
    int position = 0;
    // Trigger case
    if (cardId > 16) {
      for (int i = 0; i < 4; i++) {
        if (onChainYourTriggerCards[i] == null) {
          onChainYourTriggerCards[i] = cardId;
          break;
        }
      }
      return;
      // Unit case
    } else {
      for (int i = 0; i < 5; i++) {
        if (onChainYourFieldUnit[i] == null) {
          onChainYourFieldUnit[i] = cardId;
          position = i;
          break;
        }
      }
    }
    if (mounted) {
      setState(() {
        gameObject!.yourCp = gameObject!.yourCp -
            int.parse(cardInfos[cardId.toString()]['cost']);
      });
    }

    List<int?> unitPositions = [null, null, null, null, null];
    unitPositions[position] = cardId;

    FieldUnits fieldUnit = FieldUnits(unitPositions[0], unitPositions[1],
        unitPositions[2], unitPositions[3], unitPositions[4]);
    int enemySkillTarget = 0;
    TriggerCards triggerCards = TriggerCards(
        onChainYourTriggerCards[0],
        onChainYourTriggerCards[1],
        onChainYourTriggerCards[2],
        onChainYourTriggerCards[3]);
    List<int> usedInterceptCard = [];
    // 使用可能なインターセプトを初期化
    canUseIntercept = false;

    /////////////////
    //// Ability ////
    /////////////////
    // トリガーゾーン１はカードを置いたとき発動可能なインターセプトか?
    if (onChainYourTriggerCards.isNotEmpty &&
        onChainYourTriggerCards[0] != null) {
      int cardId = onChainYourTriggerCards[0]!;
      var skill = getCardSkill(cardId.toString());
      if (skill != null) {
        if (skill['trigger_1'] == '1') {
          if (getCardCategory(cardId.toString()) == '2') {
            // インターセプト
            for (String position in ['1', '2', '3', '4']) {
              if (getCardType(gameObject!.yourFieldUnit[position]) ==
                  getCardType(cardId.toString())) {
                // 同色のカードがフィールドにあるので選択可能
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex1Event());
                canUseIntercept = true;
              }
            }
          } else if (getCardCategory(cardId.toString()) == '1') {
            // トリガー
            usedInterceptCard.add(1);
          }
        }
      }
    }
    // トリガーゾーン2はカードを置いたとき発動可能なインターセプトか?
    if (onChainYourTriggerCards.isNotEmpty &&
        onChainYourTriggerCards[1] != null) {
      int cardId = onChainYourTriggerCards[1]!;
      var skill = getCardSkill(cardId.toString());
      if (skill != null) {
        if (skill['trigger_2'] == '1') {
          if (getCardCategory(cardId.toString()) == '2') {
            // インターセプト
            for (String position in ['1', '2', '3', '4']) {
              if (getCardType(gameObject!.yourFieldUnit[position]) ==
                  getCardType(cardId.toString())) {
                // 同色のカードがフィールドにあるので選択可能
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex2Event());
                canUseIntercept = true;
              }
            }
          } else if (getCardCategory(cardId.toString()) == '1') {
            // トリガー
            usedInterceptCard.add(2);
          }
        }
      }
    }
    // トリガーゾーン3はカードを置いたとき発動可能なインターセプトか?
    if (onChainYourTriggerCards.isNotEmpty &&
        onChainYourTriggerCards[2] != null) {
      int cardId = onChainYourTriggerCards[2]!;
      var skill = getCardSkill(cardId.toString());
      if (skill != null) {
        if (skill['trigger_3'] == '1') {
          if (getCardCategory(cardId.toString()) == '2') {
            // インターセプト
            for (String position in ['1', '2', '3', '4']) {
              if (getCardType(gameObject!.yourFieldUnit[position]) ==
                  getCardType(cardId.toString())) {
                // 同色のカードがフィールドにあるので選択可能
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex3Event());
                canUseIntercept = true;
              }
            }
          } else if (getCardCategory(cardId.toString()) == '1') {
            // トリガー
            usedInterceptCard.add(3);
          }
        }
      }
    }
    // トリガーゾーン4はカードを置いたとき発動可能なインターセプトか?
    if (onChainYourTriggerCards.isNotEmpty &&
        onChainYourTriggerCards[3] != null) {
      int cardId = onChainYourTriggerCards[3]!;
      var skill = getCardSkill(cardId.toString());
      if (skill != null) {
        if (skill['trigger_4'] == '1') {
          if (getCardCategory(cardId.toString()) == '2') {
            // インターセプト
            for (String position in ['1', '2', '3', '4']) {
              if (getCardType(gameObject!.yourFieldUnit[position]) ==
                  getCardType(cardId.toString())) {
                // 同色のカードがフィールドにあるので選択可能
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex4Event());
                canUseIntercept = true;
              }
            }
          } else if (getCardCategory(cardId.toString()) == '1') {
            // トリガー
            usedInterceptCard.add(4);
          }
        }
      }
    }

    if (canUseIntercept) {
      Future.delayed(const Duration(milliseconds: 4000), () async {
        showGameLoading();
        // 使用可能なインターセプトを初期化
        canUseIntercept = false;
        // Call GraphQL method.
        var message = PutCardModel(
            fieldUnit, enemySkillTarget, triggerCards, usedInterceptCard);
        var ret = await apiService.saveGameServerProcess(
            'put_card_on_the_field',
            jsonEncode(message),
            gameObject!.you.toString());
        closeGameLoading();
        debugPrint('transaction published');
        if (ret != null) {
          debugPrint(ret.message);
        }
      });
    } else {
      showGameLoading();
      // Call GraphQL method.
      var message = PutCardModel(
          fieldUnit, enemySkillTarget, triggerCards, usedInterceptCard);
      var ret = await apiService.saveGameServerProcess('put_card_on_the_field',
          jsonEncode(message), gameObject!.you.toString());
      closeGameLoading();
      debugPrint('transaction published');
      if (ret != null) {
        debugPrint(ret.message);
      }
    }
  }

  // カードのタップ時処理
  void tapCard(message, cardId, index) {
    if (message == 'tapped') {
      if (gameObject != null) {
        if (gameObject!.yourAttackingCard == null) {
          setState(() {
            tappedCardId = cardId;
          });
        }
      } else {
        setState(() {
          tappedCardId = cardId;
        });
      }
    } else if (message == 'attack') {
      setState(() {
        attackSignalPosition = index;
        actedCardPosition = index;
      });
    } else if (message == 'use') {
      useInterceptCard(cardId, index);
    }
  }

  // setState カードリスト
  void setCardInfo(cardInfo) {
    setState(() => cardInfos = cardInfo);
  }

  // setState 時間切れによる操作可否
  void setCanOperate(flg) {
    setState(() {
      canOperate = flg;
    });
  }

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

  // カード情報
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

  // カード名
  String getCardName(String cardId) {
    if (cardInfos != null) {
      var cardInfo = cardInfos[cardId];
      return cardInfo['name'];
    } else {
      return '';
    }
  }

  // カードBP
  String getCardBP(String cardId) {
    if (cardInfos != null) {
      var cardInfo = cardInfos[cardId];
      return cardInfo['bp'];
    } else {
      return '';
    }
  }

  // カードタイプ
  String getCardType(String cardId) {
    if (cardInfos != null) {
      var cardInfo = cardInfos[cardId];
      return cardInfo['type'];
    } else {
      return '';
    }
  }

  // カードカテゴリ
  String getCardCategory(String cardId) {
    if (cardInfos != null) {
      var cardInfo = cardInfos[cardId];
      return cardInfo['category'];
    } else {
      return '';
    }
  }

  // カード能力
  dynamic getCardSkill(String cardId) {
    if (cardInfos != null) {
      var cardInfo = cardInfos[cardId];
      return cardInfo['skill'];
    } else {
      return null;
    }
  }

  // Game Startのトランザクション処理
  void battleStart() async {
    gameProgressStatus = 2;
    // Call GraphQL method.
    if (gameObject != null) {
      showGameLoading();
      var ret = await apiService.saveGameServerProcess(
          'game_start', jsonEncode(handCards), gameObject!.you.toString());
      closeGameLoading();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showFlash(
            context: context,
            duration: const Duration(seconds: 7),
            builder: (context, controller) {
              return Flash(
                controller: controller,
                position: FlashPosition.bottom,
                child: FlashBar(
                  controller: controller,
                  content: const Text('Game Start.',
                      style: TextStyle(fontSize: 24.0)),
                  indicatorColor: Colors.blue,
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                  ),
                ),
              );
            });
      });
      debugPrint('transaction published');
      if (ret != null) {
        debugPrint(ret.message);
      }
    }
  }

  ////////////////////////////
  ///////    build     ///////
  ////////////////////////////
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (layoutContext, constraints) {
      final wRes = constraints.maxWidth / desktopWidth;
      double r(double val) {
        return val * wRes;
      }

      return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(fit: StackFit.expand, children: <Widget>[
            Positioned(
                left: r(340.0),
                top: r(450.0),
                child: Row(children: <Widget>[
                  gameProgressStatus >= 1 && gameStarted
                      ? AnimatedContainer(
                          margin: EdgeInsetsDirectional.only(top: cardPosition),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.linear,
                          child: Row(
                            children: [
                              for (var i = 0; i < handCards.length; i++)
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tappedCardId = handCards[i];
                                      });
                                    },
                                    child: DragBox(i, handCards[i], putCard,
                                        cardInfos[handCards[i].toString()], r)),
                            ],
                          ),
                        )
                      : AnimatedContainer(
                          margin: EdgeInsetsDirectional.only(top: cardPosition),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.linear,
                          child: Row(
                            children: [
                              for (var cardId in [16, 13, 4, 3, 25, 20, 26])
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tappedCardId = cardId;
                                      });
                                    },
                                    child: DragBox(
                                        null,
                                        cardId,
                                        putCard,
                                        cardInfos != null
                                            ? cardInfos[cardId.toString()]
                                            : null,
                                        r)),
                            ],
                          ),
                        ),
                ])),
            gameObject != null && gameStarted == true
                ? OnGoingGameInfo(
                    gameObject,
                    getCardInfo(tappedCardId),
                    setCanOperate,
                    attackStatusBloc.attack_stream,
                    opponentDefendPosition,
                    yourUsedInterceptCard,
                    opponentUsedInterceptCard,
                    actedCardPosition,
                    cardInfos,
                    onChainYourTriggerCards,
                    r)
                : Container(),
            DeckCardInfo(gameObject, cardInfos, tappedCardId, 'home',
                widget.enLocale, r),
            Positioned(
                left: r(35.0),
                top: r(40.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            r(150.0), r(200.0), r(30.0), r(5.0)),
                        child: DragTargetWidget(
                            'trigger',
                            '${imagePath}trigger/trigger.png',
                            gameObject,
                            cardInfos,
                            tapCard,
                            actedCardPosition,
                            canOperate,
                            attackStatusBloc.attack_stream,
                            yourTriggerCards,
                            yourTriggerCards,
                            r),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            r(30.0), r(20.0), r(130.0), r(85.0)),
                        child: DragTargetWidget(
                            'unit',
                            '${imagePath}unit/bg-2.jpg',
                            gameObject,
                            cardInfos,
                            tapCard,
                            actedCardPosition,
                            canOperate,
                            attackStatusBloc.attack_stream,
                            defaultDropedList,
                            yourTriggerCards,
                            r),
                      ),
                    ])),
            Visibility(
                visible: gameProgressStatus == 1,
                child: Positioned(
                    left: r(800),
                    top: r(500),
                    child: SizedBox(
                        width: r(100.0),
                        child: StreamBuilder<int>(
                            stream: _timer.events.stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<int> snapshot) {
                              return Center(
                                  child: Text(
                                '0:0${snapshot.data.toString()}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(42.0)),
                              ));
                            })))),
            Visibility(
                visible: mariganClickCount < 5 && gameProgressStatus == 1,
                child: Positioned(
                    left: r(900),
                    top: r(500),
                    child: SizedBox(
                        width: r(100.0),
                        child: FloatingActionButton(
                            backgroundColor: Colors.transparent,
                            onPressed: () {
                              if (mariganClickCount < 5) {
                                setState(() =>
                                    mariganClickCount = mariganClickCount + 1);
                                setState(() => handCards =
                                    mariganCardIdList[mariganClickCount]);
                              }
                            },
                            tooltip: 'Redraw',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                '${imagePath}button/redo.png',
                                fit: BoxFit.cover, //prefer cover over fill
                              ),
                            ))))),
            Visibility(
                visible: attackSignalPosition != null,
                child: Positioned(
                  left: r(attackSignalPosition != null &&
                          (attackSignalPosition! == 2 ||
                              attackSignalPosition! == 0)
                      ? 760.0
                      : 850.0),
                  top: r(-2.0),
                  child: Container(
                    width: r(75.0),
                    height: r(75.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                          opacity: 0.7,
                          image:
                              AssetImage('${imagePath}unit/attackTarget.png'),
                          fit: BoxFit.cover),
                    ),
                  ),
                )),
            Positioned(
              left: r(648.0),
              top: r(154.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Enemy's 1st Unit Name
            Positioned(
                left: r(650.0),
                top: r(157.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['1'] != null
                        ? (gameObject!.opponentFieldUnitAction['1'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.opponentFieldUnit['1'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Enemy's 1st Unit BP
            Positioned(
                left: r(650.0),
                top: r(179.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['1'] != null
                        ? (gameObject!.opponentFieldUnitAction['1'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['1'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.opponentFieldUnit['1'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(783.0),
              top: r(154.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Enemy's 2st Unit Name
            Positioned(
                left: r(785.0),
                top: r(157.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['2'] != null
                        ? (gameObject!.opponentFieldUnitAction['2'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.opponentFieldUnit['2'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Enemy's 2st Unit BP
            Positioned(
                left: r(785.0),
                top: r(179.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['2'] != null
                        ? (gameObject!.opponentFieldUnitAction['2'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['2'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.opponentFieldUnit['2'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(918.0),
              top: r(154.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Enemy's 3st Unit Name
            Positioned(
                left: r(920.0),
                top: r(157.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['3'] != null
                        ? (gameObject!.opponentFieldUnitAction['3'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.opponentFieldUnit['3'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Enemy's 3st Unit BP
            Positioned(
                left: r(920.0),
                top: r(179.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['3'] != null
                        ? (gameObject!.opponentFieldUnitAction['3'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['3'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.opponentFieldUnit['3'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1053.0),
              top: r(154.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Enemy's 4st Unit Name
            Positioned(
                left: r(1055.0),
                top: r(157.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['4'] != null
                        ? (gameObject!.opponentFieldUnitAction['4'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.opponentFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Enemy's 4st Unit BP
            Positioned(
                left: r(1055.0),
                top: r(179.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['4'] != null
                        ? (gameObject!.opponentFieldUnitAction['4'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['4'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.opponentFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1188.0),
              top: r(154.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Enemy's 5st Unit Name
            Positioned(
                left: r(1190.0),
                top: r(157.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['5'] != null
                        ? (gameObject!.opponentFieldUnitAction['5'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.opponentFieldUnit['5'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Enemy's 5st Unit BP
            Positioned(
                left: r(1190.0),
                top: r(179.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['5'] != null
                        ? (gameObject!.opponentFieldUnitAction['5'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['5'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.opponentFieldUnit['5'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(648.0),
              top: r(380.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Your 1st Unit Name
            Positioned(
                left: r(650.0),
                top: r(383.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['1'] != null
                        ? (gameObject!.yourFieldUnitAction['1'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.yourFieldUnit['1'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Your 1st Unit BP
            Positioned(
                left: r(650.0),
                top: r(405.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['1'] != null
                        ? (gameObject!.yourFieldUnitAction['1'] == '1' ||
                                    gameObject!.yourFieldUnitAction['1'] == '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.yourFieldUnit['1'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(783.0),
              top: r(380.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Your 2st Unit Name
            Positioned(
                left: r(785.0),
                top: r(383.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['2'] != null
                        ? (gameObject!.yourFieldUnitAction['2'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.yourFieldUnit['2'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Your 2st Unit BP
            Positioned(
                left: r(785.0),
                top: r(405.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['2'] != null
                        ? (gameObject!.yourFieldUnitAction['2'] == '1' ||
                                    gameObject!.yourFieldUnitAction['2'] == '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.yourFieldUnit['2'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(918.0),
              top: r(380.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Your 3st Unit Name
            Positioned(
                left: r(920.0),
                top: r(383.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['3'] != null
                        ? (gameObject!.yourFieldUnitAction['3'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.yourFieldUnit['3'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Your 3st Unit BP
            Positioned(
                left: r(920.0),
                top: r(405.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['3'] != null
                        ? (gameObject!.yourFieldUnitAction['3'] == '1' ||
                                    gameObject!.yourFieldUnitAction['3'] == '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.yourFieldUnit['3'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1053.0),
              top: r(380.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Your 4st Unit Name
            Positioned(
                left: r(1055.0),
                top: r(383.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['4'] != null
                        ? (gameObject!.yourFieldUnitAction['4'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.yourFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Your 4st Unit BP
            Positioned(
                left: r(1055.0),
                top: r(405.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['4'] != null
                        ? (gameObject!.yourFieldUnitAction['4'] == '1' ||
                                    gameObject!.yourFieldUnitAction['4'] == '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.yourFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1188.0),
              top: r(380.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Your 5st Unit Name
            Positioned(
                left: r(1190.0),
                top: r(383.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['4'] != null
                        ? (gameObject!.yourFieldUnitAction['5'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.yourFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Your 5st Unit BP
            Positioned(
                left: r(1190.0),
                top: r(405.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['4'] != null
                        ? (gameObject!.yourFieldUnitAction['5'] == '1' ||
                                    gameObject!.yourFieldUnitAction['5x'] == '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.yourFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Visibility(
                visible: showDefenceUnitsCarousel == true,
                child: Column(children: <Widget>[
                  CarouselSlider.builder(
                    carouselController: cController,
                    options: CarouselOptions(
                        height: r(400),
                        // aspectRatio: 9 / 9,
                        viewportFraction: 1, // 1.0:1つが全体に出る
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index, reason) {
                          setState(() {
                            activeIndex = index;
                          });
                        }),
                    itemCount: gameObject == null
                        ? 0
                        : gameObject!.yourDefendableUnitLength,
                    itemBuilder: (context, index, realIndex) {
                      var cardId =
                          gameObject!.yourFieldUnit[(index + 1).toString()];
                      return Image.asset(
                        '${imagePath}unit/card_$cardId.jpeg',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  SizedBox(height: r(32.0)),
                  buildIndicator(),
                  ElevatedButton(
                    onPressed: () => block(activeIndex),
                    child: const Text('Block'),
                  ),
                ])),
            // Visibility(
            //     visible: showVideo == true,
            //     child: Center(
            //       child: vController != null && vController!.value.isInitialized
            //           ? Padding(
            //               padding: EdgeInsets.all(r(60.0)),
            //               child: AspectRatio(
            //                 aspectRatio: vController!.value.aspectRatio,
            //                 child: VideoPlayer(vController!),
            //               ))
            //           : Container(),
            //     )),
            // 敵のバトルカード
            Visibility(
              visible: gameObject != null && onBattlePosition != null,
              child: Positioned(
                right: r(80.0),
                top: r(90.0),
                child: GFImageOverlay(
                  width: r(200.0),
                  height: r(300.0),
                  image: AssetImage(gameObject == null
                      ? ''
                      : isEnemyAttack == true
                          ? gameObject!.opponentFieldUnit[
                                      onBattlePosition.toString()] !=
                                  null
                              ? '${imagePath}unit/card_${gameObject!.opponentFieldUnit[onBattlePosition.toString()]}.jpeg'
                              : '${imagePath}unit/bg-2.jpg'
                          : gameObject!.opponentFieldUnit[
                                      onBattlePosition.toString()] !=
                                  null
                              ? '${imagePath}unit/card_${gameObject!.opponentFieldUnit[onBattlePosition.toString()]}.jpeg'
                              : '${imagePath}unit/bg-2.jpg'),
                ),
              ),
            ),
            // あなたのバトルカード
            Visibility(
              visible: gameObject != null &&
                  ((isEnemyAttack == true && opponentDefendPosition != null) ||
                      (isEnemyAttack == false && actedCardPosition != null)),
              child: Positioned(
                  right: r(400.0),
                  top: r(90.0),
                  child: GFImageOverlay(
                    width: r(200.0),
                    height: r(300.0),
                    shape: BoxShape.rectangle,
                    image: AssetImage(gameObject == null
                        ? ''
                        : isEnemyAttack == true
                            ? gameObject!.yourFieldUnit[
                                        opponentDefendPosition.toString()] !=
                                    null
                                ? '${imagePath}unit/card_${gameObject!.yourFieldUnit[opponentDefendPosition.toString()]}.jpeg'
                                : '${imagePath}unit/bg-2.jpg'
                            : actedCardPosition != null &&
                                    gameObject!.yourFieldUnit[
                                            (actedCardPosition! + 1)
                                                .toString()] !=
                                        null
                                ? '${imagePath}unit/card_${gameObject!.yourFieldUnit[(actedCardPosition! + 1).toString()]}.jpeg'
                                : '${imagePath}unit/bg-2.jpg'),
                  )),
            ),
            // 攻撃側の使用したトリガー・インターセプトカード
            Visibility(
                visible: gameObject != null &&
                    attackerUsedCardIds.isNotEmpty &&
                    isEnemyAttack == true,
                child: Positioned(
                    right: isEnemyAttack == true ? r(80.0) : r(400.0),
                    top: r(350.0),
                    child: Row(
                      children: [
                        for (var cardId in attackerUsedCardIds)
                          GFImageOverlay(
                            width: r(67.0),
                            height: r(100.0),
                            image: AssetImage(gameObject == null
                                ? ''
                                : '${imagePath}unit/card_${cardId.toString()}.jpeg'),
                          ),
                        SizedBox(width: r(2)),
                      ],
                    ))),
            // 防御側の使用したトリガー・インターセプトカード
            Visibility(
                visible: gameObject != null &&
                    defenderUsedCardIds.isNotEmpty &&
                    isEnemyAttack == true,
                child: Positioned(
                    right: isEnemyAttack == true ? r(400.0) : r(80.0),
                    top: r(350.0),
                    child: Row(
                      children: [
                        for (var cardId in defenderUsedCardIds)
                          GFImageOverlay(
                            width: r(67.0),
                            height: r(100.0),
                            image: AssetImage(gameObject == null
                                ? ''
                                : '${imagePath}unit/card_${cardId.toString()}.jpeg'),
                          ),
                        SizedBox(width: r(2)),
                      ],
                    ))),
          ]),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: SizedBox(
              height: r(1000),
              child: StartButtons(gameProgressStatus,
                  (status, _playerId, data, mariganCardIds, cardInfo) {
                if (playerId != _playerId) {
                  setState(() {
                    playerId = _playerId;
                  });
                }
                switch (status) {
                  case 'game-is-ready':
                    doAnimation();
                    break;
                  case 'matching-success':
                    setState(() => gameStarted = true);
                    debugPrint('playerId: $playerId $status');
                    setDataAndMarigan(data, mariganCardIds);
                    break;
                  case 'started-game-info':
                    setState(() => gameStarted = true);
                    setDataAndMarigan(data, null);
                    break;
                  case 'not-game-starting':
                    print('not-game-starting');
                    setState(() {
                      gameStarted = false;
                      gameObject = null;
                    });
                    // setDataAndMarigan(data, null);
                    break;
                  case 'card-info':
                    setCardInfo(cardInfo);
                    break;
                }
              }, widget.enLocale, r)));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 22.0,
        webPosition: 'left');
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: gameObject == null ? 0 : gameObject!.yourDefendableUnitLength,
        onDotClicked: (index) {
          cController.animateToPage(index);
        },
        effect: const JumpingDotEffect(
          verticalOffset: 4.0,
          activeDotColor: Colors.orange,
          // dotColor: Colors.black12,
        ),
      );
}
