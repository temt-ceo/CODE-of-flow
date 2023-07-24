import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import 'package:amplify_api/amplify_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flash/flash.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:getwidget/getwidget.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:html' as html;

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
  final bool isMobile;
  final bool needEyeCatch;
  const HomePage(
      {super.key,
      required this.enLocale,
      required this.isMobile,
      required this.needEyeCatch});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double cardPosition = 0.0;
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  String lottiePath =
      envFlavor == 'prod' ? 'assets/lottieFiles/' : 'lottieFiles/';
  APIService apiService = APIService();
  String savedGraphQLId = '';
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
  List<int?> onChainYourTriggerCardsDisplay = [];
  List<dynamic> defaultTriggerCards = [];
  dynamic onChainHandCards;
  BuildContext? loadingContext;
  int? actedCardPosition;
  int? attackSignalPosition;
  String playerId = '';
  bool canOperate = true;
  bool canOperateTmp = true;
  final cController = CarouselController();
  int activeIndex = 0;
  bool showDefenceUnitsCarousel = false;
  bool showUnitTargetCarousel = false;
  int? opponentDefendPosition;
  List<int> attackerUsedInterceptCard = [];
  List<int> defenderUsedInterceptCard = [];
  List<int> attackerUsedCardIds = [];
  List<int> defenderUsedCardIds = [];
  bool isBattling = false;
  int? onBattlePosition;
  bool? isEnemyAttack;
  bool canUseIntercept = false;
  final _timer = TimerComponent();
  List<int?> unitPositions = [null, null, null, null, null];
  FieldUnits fieldUnit = FieldUnits(null, null, null, null, null);
  int enemySkillTarget = 0;
  int enemySkillTargetPosition = 0; // こちらはattack()時のみ使う
  TriggerCards triggerCards = TriggerCards(null, null, null, null);
  List<int> usedInterceptCardPosition = [];
  String skillMessage = '';
  List<int> usedTriggers = [];
  List<int> cannotDefendUnitPositions = [];
  List<int> opponentFieldUnitPositions = [];
  List<int> yourDefendableUnitPositions = [];
  bool selectTargetFlg = false;
  int reviewingTriggerCardPosition = 0;
  int? cardTriggerAbilityCase;
  bool? calledFieldUnitActionTrans;
  int? tapCardIndex;
  String? putCardOnFieldType;
  double _r = 1.0;
  bool attackIsReady = false;
  bool possibleUnitLost = false;
  bool isMainWindow = false;
  int eyeCatchSequence = 0;

  @override
  void initState() {
    super.initState();
    // GraphQL Subscription
    listenBCGGameServerProcess();
    showMainWindow();
  }

  void showMainWindow() async {
    if (widget.needEyeCatch == false) {
      setState(() => isMainWindow = true);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 3300));
    // setState(() => eyeCatchSequence = 1);
    // await Future.delayed(const Duration(milliseconds: 1700));
    setState(() => eyeCatchSequence = 2);
    await Future.delayed(const Duration(milliseconds: 1700));
    setState(() => isMainWindow = true);
  }

  /*
  **  GraphQL Subscription
  */
  void listenBCGGameServerProcess() async {
    Stream<GraphQLResponse<GameServerProcess>> operation =
        apiService.subscribeBCGGameServerProcess();
    operation.listen(
      (event) {
        var ret = event.data;
        if (ret != null && savedGraphQLId != ret.id) {
          savedGraphQLId = ret.id;
          if (ret.type == 'attack' || ret.type == 'battle_reaction'
              // ret.type == 'put_card_on_the_field' ||
              // ret.type == 'defence_action'
              ) {
            debugPrint('Player No. ${ret.playerId} => ${ret.type}');
            debugPrint(
                '*** Subscription event data received: (${ret.id}) ${event.data}');
          }
          if (ret.type == 'player_matching' && playerId == ret.playerId) {
            String transactionId = ret.message.split(',TransactionID:')[1];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showMessage(5, 'Transaction ID: $transactionId',
                  'Player Matching is in progress.');
            });
          } else if (ret.type == 'player_matching' &&
              gameObject == null &&
              ret.playerId != playerId) {
            showToast("No. ${ret.playerId} has entered in Alcana.");
          }
          if (gameObject == null) {
            return;
          }
          if (gameObject!.you.toString() != ret.playerId &&
              gameObject!.opponent.toString() != ret.playerId) {
            return;
          }
          if (ret.type == 'put_card_on_the_field') {
            var msg = jsonDecode(ret.message.split(',TransactionID:')[0]);
            if (gameObject != null &&
                gameObject!.you.toString() == ret.playerId) {
              setState(() {
                defaultTriggerCards = onChainYourTriggerCards;
              });
            }

            if (msg['skillMessage'] != '') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showMessage(7, msg['skillMessage'], null);
              });
            }
          } else if (ret.type == 'turn_change') {
            isBattling = false;
            if (attackSignalPosition == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Limaru
                var enemyAbility = '';
                for (int i = 1; i <= 5; i++) {
                  if (gameObject!.opponentFieldUnit[i.toString()] == '14' &&
                      gameObject!.opponentFieldUnitAction[i.toString()] ==
                          '0') {
                    enemyAbility =
                        '\nLimaru ${L10n.of(context)!.activatedAbility} - Unconquerable! -';
                  }
                }
                showMessage(9, 'Turn Change! $enemyAbility', null);
              });
            }
            // あなたの攻撃
          } else if (ret.type == 'attack' &&
              gameObject!.you.toString() == ret.playerId) {
            isBattling = true;
            var msg = jsonDecode(ret.message.split(',TransactionID:')[0]);
            setState(() {
              defaultTriggerCards = onChainYourTriggerCardsDisplay;
            });
            // 攻撃側が使用中のトリガー/インターセプトカードをセット
            List<int> _attackerUsedCardIds = [];
            for (var i in msg['usedCardIds']) {
              _attackerUsedCardIds.add(i);
            }
            setState(() => attackerUsedCardIds = _attackerUsedCardIds);
            if (msg['skillMessage'] != '') {
              showMessage(7, msg['skillMessage'], null);
            }
            var usedInterceptPositions = msg['arg4'];
            // 攻撃時に使用したトリガーカード
            List<int> _attackerUsedInterceptCard = [];
            for (var i in usedInterceptPositions) {
              _attackerUsedInterceptCard.add(i);
            }
            setState(() {
              attackerUsedInterceptCard = _attackerUsedInterceptCard;
              defaultTriggerCards = onChainYourTriggerCardsDisplay;
            });
            attackStatusBloc.canAttackEventSink.add(BattlingEvent());
            /////////////
            // 敵の攻撃 //
            /////////////
          } else if (ret.type == 'attack' &&
              gameObject!.opponent.toString() == ret.playerId) {
            isBattling = true;
            _timer.countdownStart(8, () {
              isBattling = false;
              attackStatusBloc.canAttackEventSink.add(BattleFinishingEvent());
            });
            var msg = jsonDecode(ret.message.split(',TransactionID:')[0]);
            // 攻撃側が使用中のトリガー/インターセプトカードをセット
            List<int> _attackerUsedCardIds = [];
            for (var i in msg['usedCardIds']) {
              _attackerUsedCardIds.add(i);
            }
            setState(() => attackerUsedCardIds = _attackerUsedCardIds);
            bool messageAlreadyShown = false;
            onBattlePosition = msg['arg1'];
            if (gameObject!.opponentFieldUnit[onBattlePosition] == '6') {
              // Valkyrie
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showMessage(5, '',
                    'Valkyrie ${L10n.of(context)!.activatedAbility} Cannot Block!');
              });
              yourDefendableUnitPositions = [];
              messageAlreadyShown = true;
            }
            var usedCardIds = msg['usedCardIds'];
            var skillTarget = msg['arg2'];
            String toastMsg = L10n.of(context)!.opponentAttack;
            // used_intercept_position
            for (var i = 0; i < usedCardIds.length; i++) {
              if (usedCardIds[0] == 25) {
                // Judge
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showMessage(5, '',
                      'Judgement ${L10n.of(context)!.activatedEffect} Cannot Block!');
                });
                yourDefendableUnitPositions = [];
                messageAlreadyShown = true;
              }
              if (usedCardIds[0] == 24) {
                // Titan's Lock
                var target = gameObject!.yourFieldUnit[skillTarget.toString()];
                if (target != null) {
                  toastMsg =
                      "$toastMsg Titan's Lock${L10n.of(context)!.activatedEffect} ${getCardName(target)}${L10n.of(context)!.cannotMove}";
                  yourDefendableUnitPositions.removeWhere((element) {
                    debugPrint(
                        'element == skillTarget: ${element == skillTarget} element: $element skillTarget: $skillTarget');
                    return element == skillTarget;
                  });
                }
              }
            }
            bool canBlock = msg['canBlock'];
            if (canBlock == true) {
              showDefenceUnitsCarousel = true;
            }
            String enemyAbility = '';
            if (gameObject!.opponentFieldUnit[onBattlePosition] == '2') {
              // Fighter
              enemyAbility = 'Fighter ${L10n.of(context)!.activatedAbility} ';
            } else if (gameObject!.opponentFieldUnit[onBattlePosition] == '3') {
              // Lancer
              enemyAbility = 'Lancer ${L10n.of(context)!.activatedAbility} ';
              var damagedCardId = gameObject!.yourFieldUnit[skillTarget];
              enemyAbility =
                  '$enemyAbility ${L10n.of(context)!.gotUnitDamage(getCardName(damagedCardId))}';
            } else if (gameObject!.opponentFieldUnit[onBattlePosition] == '7') {
              // Lilim
              enemyAbility = 'Lilim ${L10n.of(context)!.activatedAbility} ';
            }

            var usedInterceptPositions = msg['arg4'];
            // 攻撃時に使用したトリガーカード
            List<int> _attackerUsedInterceptCard = [];
            for (var i in usedInterceptPositions) {
              _attackerUsedInterceptCard.add(i);
            }
            setState(() {
              attackerUsedInterceptCard = _attackerUsedInterceptCard;
              isEnemyAttack = true;
            });
            if (defenderUsedInterceptCard.isNotEmpty) {
              toastMsg =
                  '$toastMsg ${L10n.of(context)!.opponentAttackTrigger(defenderUsedInterceptCard.length)}';
            }
            if (messageAlreadyShown == false) {
              // 敵攻撃メッセージ
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showMessage(
                    7, '$toastMsg  $enemyAbility ${msg['skillMessage']}', null);
              });
            }
            // === 敵の攻撃 ここまで ===
            // バトルの相手側の対応
          } else if (ret.type == 'battle_reaction') {
            if (isBattling == true) {
              attackStatusBloc.canAttackEventSink.add(BattlingEvent());
              _timer.countdownStart(3, () {
                isBattling = false;
                attackStatusBloc.canAttackEventSink
                    .add(CanNotUseTriggerEvent());
                attackStatusBloc.canAttackEventSink.add(BattleFinishingEvent());
              });
              var msg = jsonDecode(ret.message.split(',TransactionID:')[0]);
              print(msg);
              bool enemyHasBlocked = false;
              // isEnemyAttackがnullの場合はfalseをセットする。
              if (isEnemyAttack == null) {
                enemyHasBlocked = true;
                setState(() {
                  isEnemyAttack = false;
                });
              }
              // ブロックしたユニットのposition
              setState(() => opponentDefendPosition = msg['arg1']);
              var attackerUsedInterceptPositions = msg['arg2'];
              // 攻撃時に使用したトリガーカード
              List<int> _attackerUsedInterceptCard = [];
              for (var i in attackerUsedInterceptPositions) {
                _attackerUsedInterceptCard.add(i);
              }

              var defenderUsedInterceptPositions = msg['arg3'];
              // 攻撃時に使用したトリガーカード
              List<int> _defenderUsedInterceptCard = [];
              for (var i in defenderUsedInterceptPositions) {
                _defenderUsedInterceptCard.add(i);
              }

              // 攻撃側が使用中のトリガー/インターセプトカードをセット
              List<int> _attackerUsedCardIds = [];
              for (var i in msg['attackerUsedCardIds']) {
                _attackerUsedCardIds.add(i);
              }
              // 防御側が使用中のトリガー/インターセプトカードをセット
              List<int> _defenderUsedCardIds = [];
              for (var i in msg['defenderUsedCardIds']) {
                _defenderUsedCardIds.add(i);
              }
              setState(() {
                attackerUsedInterceptCard = _attackerUsedInterceptCard;
                defenderUsedInterceptCard = _defenderUsedInterceptCard;
                attackerUsedCardIds = _attackerUsedCardIds;
                defenderUsedCardIds = _defenderUsedCardIds;
              });

              /////////////////
              //// Ability ////
              /////////////////
              // 格闘相手がいる場合
              if (opponentDefendPosition != null) {
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
              }

              if (enemyHasBlocked &&
                  gameObject!.opponent.toString() == ret.playerId) {
                String enemyAbility = '';
                if (gameObject!.opponentFieldUnit[opponentDefendPosition] ==
                    '9') {
                  // Sohei
                  enemyAbility =
                      'Sohei ${L10n.of(context)!.activatedAbility} - Defensive Specialization! -';
                } else if (gameObject!
                        .opponentFieldUnit[opponentDefendPosition] ==
                    '15') {
                  // Roin
                  enemyAbility =
                      'Roin ${L10n.of(context)!.activatedAbility} - Defensive Specialization! -';
                }
                if (enemyAbility != '') {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showMessage(
                        5,
                        canUseIntercept
                            ? '$enemyAbility ${L10n.of(context)!.interceptAbailable}'
                            : enemyAbility,
                        L10n.of(context)!.opponentBlocking);
                  });
                }
              } else if (canUseIntercept) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showMessage(5, L10n.of(context)!.interceptAbailable, null);
                });
              }
            }
          } else if (ret.type == 'defence_action') {
            debugPrint('##########DEFENCE ACTION Returned##########');
            isBattling = false;
            attackStatusBloc.canAttackEventSink.add(CanNotUseTriggerEvent());
          }
        }
      },
      onError: (Object e) => debugPrint('Error in subscription stream: $e'),
    );
  }

  /*
  **  ブロック処理
  */
  void block(int activeIndex) async {
    setState(() {
      showDefenceUnitsCarousel = false;
      opponentDefendPosition = activeIndex + 1;
      canUseIntercept = false;
    });

    // Battle Reaction
    if (widget.isMobile == true) {
      showGameLoading();
      var message = DefenceActionModel(
          opponentDefendPosition!,
          attackerUsedInterceptCard,
          defenderUsedInterceptCard,
          attackerUsedCardIds,
          defenderUsedCardIds);
      apiService.saveGameServerProcess(
          'battle_reaction', jsonEncode(message), gameObject!.you.toString());
      await Future.delayed(const Duration(seconds: 2));
      closeGameLoading();
    } else {
      showGameLoading();
      var message = DefenceActionModel(
          opponentDefendPosition!,
          attackerUsedInterceptCard,
          defenderUsedInterceptCard,
          attackerUsedCardIds,
          defenderUsedCardIds);
      await apiService.saveGameServerProcess(
          'battle_reaction', jsonEncode(message), gameObject!.you.toString());
      closeGameLoading();
    }
  }

  /*
  **  インターセプトカード使用処理(フィールドのカードの行動時)
  */
  void useInterceptCardForField(int cardId, int activeIndex) async {
    // (Breaker,Imperiale,Photon,Signal for assault)
    // ２度押ししていないかチェック
    if (!usedInterceptCardPosition
        .any((element) => element == activeIndex + 1)) {
      usedTriggers.add(cardId);
      usedInterceptCardPosition.add(activeIndex + 1);
      onChainYourTriggerCardsDisplay[activeIndex] = null;
    }
  }

  /*
  **  インターセプトカード使用処理(攻撃時)
  */
  void useInterceptCardForAttack(int cardId, int activeIndex) async {
    // (Titan's lock, Dainsleif, Judge)
    // ２度押ししていないかチェック
    if (!usedInterceptCardPosition
        .any((element) => element == activeIndex + 1)) {
      usedInterceptCardPosition.add(activeIndex + 1);
      attackerUsedInterceptCard.add(activeIndex);
      attackerUsedCardIds.add(cardId);
      setState(() {
        usedTriggers.add(cardId);
        usedInterceptCardPosition = usedInterceptCardPosition;
        attackerUsedInterceptCard = attackerUsedInterceptCard;
        attackerUsedCardIds = attackerUsedCardIds;
      });
      onChainYourTriggerCardsDisplay[activeIndex] = null;
    }
    reviewInterceptCards();
  }

  /*
  **  インターセプトカード使用処理(バトル時)
  */
  void useInterceptCardForBattle(int cardId, int activeIndex) async {
    // 攻撃時もしくは防御時
    if (isEnemyAttack != null) {
      if (isEnemyAttack == true) {
        // ２度押ししていないかチェック
        if (!defenderUsedInterceptCard
            .any((element) => element == activeIndex + 1)) {
          setState(() {
            defenderUsedInterceptCard.add(activeIndex + 1);
            defenderUsedCardIds.add(cardId);
          });
        }
      } else {
        // ２度押ししていないかチェック
        if (!attackerUsedInterceptCard
            .any((element) => element == activeIndex + 1)) {
          setState(() {
            attackerUsedInterceptCard.add(activeIndex + 1);
            attackerUsedCardIds.add(cardId);
          });
        }
      }
      // Battle Reaction
      showGameLoading();
      var message = DefenceActionModel(
          opponentDefendPosition,
          attackerUsedInterceptCard,
          defenderUsedInterceptCard,
          attackerUsedCardIds,
          defenderUsedCardIds);
      if (widget.isMobile == true) {
        apiService.saveGameServerProcess(
            'battle_reaction', jsonEncode(message), gameObject!.you.toString());
        await Future.delayed(const Duration(seconds: 2));
        closeGameLoading();
        onChainYourTriggerCardsDisplay[activeIndex] = null;
      } else {
        await apiService.saveGameServerProcess(
            'battle_reaction', jsonEncode(message), gameObject!.you.toString());
        closeGameLoading();
        onChainYourTriggerCardsDisplay[activeIndex] = null;
      }
    }
  }

  void showMessage(int second, String content, String? title) {
    try {
      if (title != null) {
        showFlash(
            context: context,
            duration: Duration(seconds: second),
            builder: (context, controller) {
              return Flash(
                controller: controller,
                position: FlashPosition.bottom,
                child: FlashBar(
                  controller: controller,
                  title: Text(title, style: TextStyle(fontSize: _r * 24.0)),
                  content: Text(content, style: TextStyle(fontSize: _r * 20.0)),
                  indicatorColor: Colors.blue,
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                  ),
                ),
              );
            });
      } else {
        showFlash(
            context: context,
            duration: Duration(seconds: second),
            builder: (context, controller) {
              return Flash(
                controller: controller,
                position: FlashPosition.bottom,
                child: FlashBar(
                  controller: controller,
                  content: Text(content, style: TextStyle(fontSize: _r * 20.0)),
                  indicatorColor: Colors.blue,
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                  ),
                ),
              );
            });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /*
  **  1秒おきにブロックチェーンから取得したデータの処理
  */
  void setDataAndMarigan(GameObject? data, List<List<int>>? mariganCardIds) {
    bool turnChanged = false;
    if (gameProgressStatus < 2) {
      setState(() => gameProgressStatus = 2); // リロードなどの対応
    }
    if (data != null) {
      if (gameObject != null) {
        // ターンの変わり目を察知
        if (gameObject!.turn != data.turn ||
            gameObject!.isFirstTurn != data.isFirstTurn) {
          turnChanged = true;
        } else {
          // CP使用済みなら、使用済みの方を使用する
          if (data.yourCp > gameObject!.yourCp) {
            data.yourCp = gameObject!.yourCp;
          }
        }
        if (data.yourLife < gameObject!.yourLife) {
          // バトル終結のため、パラメータをnullにする
          setState(() {
            onBattlePosition = null;
            isEnemyAttack = null;
            showDefenceUnitsCarousel = false;
            opponentDefendPosition = null;
            attackerUsedInterceptCard = [];
            defenderUsedInterceptCard = [];
            attackerUsedCardIds = [];
            defenderUsedCardIds = [];
            actedCardPosition = null;
            canUseIntercept = false;
            attackSignalPosition = null;
          });
          attackStatusBloc.canAttackEventSink.add(BattleFinishedEvent());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showMessage(5, L10n.of(context)!.gotDamage, null);
          });
        } else if (data.opponentLife < gameObject!.opponentLife) {
          // バトル終結のため、パラメータをnullにする
          setState(() {
            onBattlePosition = null;
            isEnemyAttack = null;
            showDefenceUnitsCarousel = false;
            opponentDefendPosition = null;
            attackerUsedInterceptCard = [];
            defenderUsedInterceptCard = [];
            attackerUsedCardIds = [];
            defenderUsedCardIds = [];
            actedCardPosition = null;
            canUseIntercept = false;
            attackSignalPosition = null;
          });
          attackStatusBloc.canAttackEventSink.add(BattleFinishedEvent());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showMessage(5, L10n.of(context)!.giveDamage, null);
          });
        } else if ((data.yourAttackingCard == null &&
                gameObject!.yourAttackingCard != null) ||
            (data.enemyAttackingCard == null &&
                gameObject!.enemyAttackingCard != null)) {
          // バトル終結のため、パラメータをnullにする
          setState(() {
            onBattlePosition = null;
            isEnemyAttack = null;
            showDefenceUnitsCarousel = false;
            opponentDefendPosition = null;
            attackerUsedInterceptCard = [];
            defenderUsedInterceptCard = [];
            attackerUsedCardIds = [];
            defenderUsedCardIds = [];
            actedCardPosition = null;
            canUseIntercept = false;
            attackSignalPosition = null;
          });
          attackStatusBloc.canAttackEventSink.add(BattleFinishedEvent());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showMessage(5, L10n.of(context)!.battleSettled, null);
          });
        }
        possibleUnitLost = false;
        // 自ターンでない場合は即座にトリガー、ユニットを反映 / バトルで負けた場合に備え更新
        if (data.isFirst != data.isFirstTurn ||
            (gameObject!.yourAttackingCard != null &&
                data.yourAttackingCard == null)) {
          possibleUnitLost = true;
          List<dynamic> _units = [];
          for (int i = 1; i <= 5; i++) {
            _units.add(data.yourFieldUnit[i.toString()]);
          }
          List<int?> _triggerCards = [];
          for (int i = 1; i <= 4; i++) {
            var cardId = data.yourTriggerCards[i.toString()];
            if (cardId != null) {
              _triggerCards.add(int.parse(cardId));
            } else {
              _triggerCards.add(null);
            }
          }

          setState(() {
            onChainYourFieldUnit = _units;
            defaultDropedList = _units.isEmpty ? [null] : _units;
            onChainYourTriggerCards = _triggerCards;
            onChainYourTriggerCardsDisplay = _triggerCards;
            defaultTriggerCards =
                _triggerCards.isEmpty ? [null] : _triggerCards;
          });
        }
        // 新しいカードをドローしているケース
        if (data.newlyDrawedCards.isNotEmpty) {
          for (var i = 0; i < data.newlyDrawedCards.length; i++) {
            if (gameObject!.newlyDrawedCards.length < i + 1) {
              // 新しくドローしたカードをセット
              handCards.add(int.parse(data.newlyDrawedCards[i]));
            } else if (gameObject!.newlyDrawedCards[i] !=
                data.newlyDrawedCards[i]) {
              // 新しくドローしたカードをセット
              handCards.add(int.parse(data.newlyDrawedCards[i]));
            }
          }
          setState(() {
            handCards = handCards;
          });
        }
        if ((data.yourLife == 1 &&
                data.isFirst != data.isFirstTurn &&
                gameObject!.yourLife > 1) ||
            (data.opponentLife == 1 &&
                data.isFirst == data.isFirstTurn &&
                gameObject!.opponentLife > 1)) {
          // Detect Yggdrasill
          bool existFieldUnit = false;
          for (int i = 1; i <= 5; i++) {
            if (data.yourFieldUnit[i.toString()] != null) {
              existFieldUnit = true;
              break;
            }
            if (data.opponentFieldUnit[i.toString()] != null) {
              existFieldUnit = true;
              break;
            }
          }
          if (existFieldUnit == false) {
            // Check Trigger card is decreased
            bool yggdrasillUsed = false;
            if (data.opponentTriggerCards < gameObject!.opponentTriggerCards &&
                data.isFirst == data.isFirstTurn) {
              yggdrasillUsed = true;
            } else if (data.isFirst != data.isFirstTurn) {
              for (int i = 1; i <= 4; i++) {
                if (gameObject!.yourTriggerCards[i.toString()] != null &&
                    data.yourTriggerCards[i.toString()] == null) {
                  yggdrasillUsed = true;
                }
              }
            }
            if (yggdrasillUsed == true) {
              showMessage(
                  5, 'Yggdrasill${L10n.of(context)!.activatedEffect}!', null);
            }
          }
        }
      }
    }

    setState(() => gameObject = data);

    // マリガン時のみこちらへ
    if (mariganCardIds != null) {
      setState(() {
        mariganCardIdList = mariganCardIds;
        mariganClickCount = 0;
        handCards = mariganCardIdList[mariganClickCount];
        gameProgressStatus = 1;
        defaultDropedList = [null];
        defaultTriggerCards = [null];
      });
      // Start Marigan.
      _timer.countdownStart(8, battleStart);
      // ゲームが終了した
    } else if (data == null) {
      setState(() {
        handCards = [];
        defaultDropedList = [null];
        defaultTriggerCards = [null];
      });
    } else {
      setState(() => canOperate = true);

      // 通常時はこちら
      if (turnChanged || onChainHandCards == null) {
        // ハンドのブロックチェーンデータとの調整
        List<int> _hand = [];
        for (int i = 1; i <= 7; i++) {
          var cardId = data.yourHand[i.toString()];
          if (cardId != null) {
            _hand.add(int.parse(cardId));
          }
        }
        // フイールドユニットのブロックチェーンデータとの調整
        List<dynamic> _units = [];
        for (int i = 1; i <= 5; i++) {
          _units.add(data.yourFieldUnit[i.toString()]);
        }
        // トリガーのブロックチェーンデータとの調整
        List<int?> _triggerCards = [];
        for (int i = 1; i <= 4; i++) {
          var cardId = data.yourTriggerCards[i.toString()];
          if (cardId != null) {
            _triggerCards.add(int.parse(cardId));
          } else {
            _triggerCards.add(null);
          }
        }
        onChainYourTriggerCardsDisplay = [];
        // 参照渡しにならないようにディープコピー
        for (var i = 0; i < _triggerCards.length; i++) {
          onChainYourTriggerCardsDisplay.add(_triggerCards[i]);
        }
        setState(() {
          handCards = _hand;
          onChainHandCards = data.yourHand;
          onChainYourFieldUnit = _units;
          onChainYourTriggerCards = _triggerCards;
          // ターンチェンジ後に空になっている場合は空であることをコンポーネントに伝える必要がある
          defaultDropedList = _units.isEmpty ? [null] : _units;
          defaultTriggerCards = _triggerCards.isEmpty ? [null] : _triggerCards;
        });
      } else {
        if (possibleUnitLost == false) {
          setState(() {
            // フイールドユニットのブロックチェーンデータとの調整(こうしないとプレイヤーが操作した動きがリセットされる為)
            defaultDropedList = [];
            defaultTriggerCards = [];
          });
        }
      }

      opponentFieldUnitPositions = [];
      yourDefendableUnitPositions = [];
      for (var i = 1; i <= 5; i++) {
        if (gameObject!.opponentFieldUnit[i.toString()] != null) {
          opponentFieldUnitPositions.add(i);
        }
        if (gameObject!.yourFieldUnitAction[i.toString()] == '1' ||
            gameObject!.yourFieldUnitAction[i.toString()] == '2') {
          if (gameObject!.yourFieldUnit[i.toString()] != null) {
            yourDefendableUnitPositions.add(i);
          }
        }
      }
      Future.delayed(const Duration(milliseconds: 20), () {
        // 攻撃可能かどうかをコンポーネントに通知
        if (gameObject != null &&
            gameObject!.isFirst == gameObject!.isFirstTurn) {
          if (gameObject!.lastTimeTurnend != null) {
            DateTime lastTurnEndTime = DateTime.fromMillisecondsSinceEpoch(
                double.parse(gameObject!.lastTimeTurnend!).toInt() * 1000);
            final turnEndTime =
                lastTurnEndTime.add(const Duration(seconds: 65));
            final now = DateTime.now();

            if (turnEndTime.difference(now).inSeconds > 0 &&
                isBattling == false) {
              for (var i = 1; i <= 5; i++) {
                // 攻撃可能なユニット
                if (gameObject!.yourFieldUnitAction[i.toString()] == '2') {
                  if (tapCardIndex == 0 && i == 1) {
                    attackStatusBloc.canAttackEventSink
                        .add(Index1AttackAllowedEvent());
                  } else if (tapCardIndex == 1 && i == 2) {
                    attackStatusBloc.canAttackEventSink
                        .add(Index2AttackAllowedEvent());
                  } else if (tapCardIndex == 2 && i == 3) {
                    attackStatusBloc.canAttackEventSink
                        .add(Index3AttackAllowedEvent());
                  } else if (tapCardIndex == 3 && i == 4) {
                    attackStatusBloc.canAttackEventSink
                        .add(Index4AttackAllowedEvent());
                  } else if (tapCardIndex == 4 && i == 5) {
                    attackStatusBloc.canAttackEventSink
                        .add(Index5AttackAllowedEvent());
                  }
                }
              }
            } else {
              attackStatusBloc.canAttackEventSink.add(AttackNotAllowedEvent());
            }
          }
        } else {
          attackStatusBloc.canAttackEventSink.add(AttackNotAllowedEvent());
        }
      });
    }
  }

  ///////////////////////////
  // ドラッグ&ドロップ後の処理 //
  ///////////////////////////
  void putCard(cardId) {
    if (gameObject == null) return;
    int position = 0;
    // Trigger case
    if (cardId > 16) {
      if (onChainYourTriggerCards.isEmpty) {
        onChainYourTriggerCards = [null, null, null, null];
      }
      for (int i = 0; i < 4; i++) {
        if (onChainYourTriggerCards[i] == null) {
          setState(() {
            onChainYourTriggerCards[i] = cardId;
          });
          break;
        }
      }
      return;
    }
    ///////////////
    // Unit case //
    ///////////////
    for (int i = 0; i < 5; i++) {
      if (onChainYourFieldUnit[i] == null) {
        onChainYourFieldUnit[i] = cardId;
        position = i;
        break;
      }
    }
    setState(() {
      gameObject!.yourCp =
          gameObject!.yourCp - int.parse(cardInfos[cardId.toString()]['cost']);
    });

    // 初期化
    unitPositions = [null, null, null, null, null];
    unitPositions[position] = cardId;
    fieldUnit = FieldUnits(unitPositions[0], unitPositions[1], unitPositions[2],
        unitPositions[3], unitPositions[4]);
    enemySkillTarget = 0;
    triggerCards = TriggerCards(
        onChainYourTriggerCards[0],
        onChainYourTriggerCards[1],
        onChainYourTriggerCards[2],
        onChainYourTriggerCards[3]);
    usedInterceptCardPosition = [];
    skillMessage = '';
    usedTriggers = [];
    cannotDefendUnitPositions = [];
    selectTargetFlg = false;
    // 使用可能なインターセプトを初期化
    canUseIntercept = false;
    reviewingTriggerCardPosition = 0;
    calledFieldUnitActionTrans = null;
    putCardOnFieldType = null;
    cardTriggerAbilityCase = 1; // カードがフィールドに出た時の能力
    reviewFieldUnitAbility(cardId);
  }

  /////////////////
  //// Ability ////
  /////////////////
  // trigger=1: trigger when the card is put on the field (フィールド上にカードを置いた時)
  // unit: 4,5,7,8,11,13,16 trigger: 18,19 intercept: 20,21,23,27
  // (HellDog,Arty,Lilim,Belial,Allie,Caim,Rairyu,Canon,Merchant,Breaker,Imperiale,Photon,Signal for assault)

  // When card ATTACKs trigger=1,4:
  // 2(Fighter),3(Lancer), 6(Valkyrie),7(Lilim)

  //  ask 0: Not choose target. (選ばない)
  //  ask 1: Target one unit (相手を選ぶ)
  //  ask 2: Only target which has no action right(行動権がない相手を選ぶ)
  //  ask 3: Not choose target. But influence all units (選ばない。全体に影響)
  //  type 1: Damage(ダメージ)
  //  type 2: BP Pump(BPパンプ)
  //  type 3: Trigger lost(トリガーロスト)
  //  type 5: Remove action right(行動権剥奪)
  //  type 7: Draw cards(カードドロー)
  //  type 7: Indomitable spirit(不屈)
  //  type 11: Speed Move(スピードムーブ)
  void reviewFieldUnitAbility(cardId) {
    // フィールドに置いたカードは置いたとき発動可能なユニットか?
    var skill = getCardSkill(cardId.toString());
    if (cardTriggerAbilityCase == 1) {
      putCardOnFieldType = getCardType(cardId.toString());
    }
    if (skill != null) {
      if (skill['trigger_1'] == cardTriggerAbilityCase.toString()) {
        if (skill['ask_1'] == '1') {
          // 対象を選ぶ
          if (skill['type_1'] == '1' && opponentFieldUnitPositions.isNotEmpty) {
            if (cardTriggerAbilityCase == 1) {
              // Lilim
              skillMessage =
                  'Lilim ${L10n.of(context)!.activatedAbility} - Dmage One Unit! -';
              showUnitTargetCarousel = true;
              showMessage(
                  4,
                  'Lilim ${L10n.of(context)!.activatedAbility} - Choos One Unit! -',
                  null);
              _timer.countdownStart(6, () {
                showUnitTargetCarousel = false;
                selectTarget(0); // 左端を強制選択
              });
              return;
            } else if (cardTriggerAbilityCase == 2) {
              // Lancer
              skillMessage =
                  'Lancer ${L10n.of(context)!.activatedAbility} - Dmage One Unit! -';
              showUnitTargetCarousel = true;
              showMessage(
                  4,
                  'Lancer ${L10n.of(context)!.activatedAbility} - Choos One Unit! -',
                  null);
              _timer.countdownStart(6, () {
                showUnitTargetCarousel = false;
                selectTarget(0); // 左端を強制選択
              });
              return;
            }
          } else if (skill['type_1'] == '5' &&
              opponentFieldUnitPositions.isNotEmpty) {
            if (cardTriggerAbilityCase == 1) {
              // Allie
              for (var i = 1; i <= 5; i++) {
                if (gameObject!.opponentFieldUnitAction[i.toString()] == '1' ||
                    gameObject!.opponentFieldUnitAction[i.toString()] == '2') {
                  cannotDefendUnitPositions.add(i);
                }
              }
              if (cannotDefendUnitPositions.isNotEmpty) {
                skillMessage =
                    'Allie ${L10n.of(context)!.activatedAbility} - Remove Action Right! -';
                showUnitTargetCarousel = true;
                showMessage(
                    4,
                    'Allie ${L10n.of(context)!.activatedAbility} - Choos One Unit! -',
                    null);
                _timer.countdownStart(6, () {
                  showUnitTargetCarousel = false;
                  selectTarget(0); // 左端を強制選択
                });
                return;
              }
            }
          }
        } else if (skill['ask_1'] == '2') {
          // 行動ずみユニットの対象を選ぶ
          if (cardTriggerAbilityCase == 1) {
            // Rairyu
            var leftMost = 0;
            for (var i = 1; i <= 5; i++) {
              if (gameObject!.opponentFieldUnitAction[i.toString()] == '0') {
                if (leftMost == 0) {
                  leftMost = i;
                }
                cannotDefendUnitPositions.add(i);
              }
            }
            if (cannotDefendUnitPositions.isNotEmpty) {
              skillMessage =
                  'Rairyu ${L10n.of(context)!.activatedAbility} - Dmage Acted-up Unit! -';
              showUnitTargetCarousel = true;
              showMessage(
                  4,
                  'Rairyu ${L10n.of(context)!.activatedAbility} - Choos One Unit! -',
                  null);
              _timer.countdownStart(6, () {
                showUnitTargetCarousel = false;
                selectTarget(leftMost - 1); // 左端を強制選択
              });
              return;
            }
          }
        } else if (skill['ask_1'] == '3') {
          // 全体が対象
          if (cardTriggerAbilityCase == 1) {
            // Belial
            skillMessage =
                'Belial ${L10n.of(context)!.activatedAbility} - Dmage All Units! -';
          }
        } else {
          // 対象を選ばない
          if (cardTriggerAbilityCase == 1) {
            // HellDog,Arty,Caim
            var unit =
                cardId == 4 ? 'HellDog' : (cardId == 5 ? 'Arty' : 'Caim');
            var ability = cardId == 4
                ? '- Trigger Card Lost! -'
                : (cardId == 5 ? '- Speed Move! -' : '- Card Draw! -');
            if (cardId == 4 && gameObject!.opponentTriggerCards == 0) {
              // 発動しない
            } else {
              skillMessage =
                  '$unit ${L10n.of(context)!.activatedAbility} $ability';
            }
          } else if (cardTriggerAbilityCase == 2) {
            // Fighter,Lilim
            var unit =
                cardId == 2 ? 'Fighter' : (cardId == 6 ? 'Valkyrie' : 'Lilim');
            var ability = cardId == 2
                ? '- Augmented Power! -'
                : (cardId == 6
                    ? 'This unit is not blocked!'
                    : (gameObject!.opponentTriggerCards > 0
                        ? '- Trigger Card Lost! -'
                        : ''));
            skillMessage =
                '$unit ${L10n.of(context)!.activatedAbility} $ability';
          }
        }
      }
    }
    reviewTriggerCards();
  }

  /////////////////////////////////////////
  // カルーセルで敵ターゲットを選択した後の処理 //
  /////////////////////////////////////////
  void selectTarget(int index) {
    if (selectTargetFlg == false) {
      selectTargetFlg = true;
      if (index == 0) {
        // もし左端に敵ユニットがいないと困るので...
        for (int i = 1; i <= 5; i++) {
          if (gameObject!.opponentFieldUnit[i.toString()] != null) {
            enemySkillTarget = i;
            break;
          }
        }
      } else {
        enemySkillTarget = index + 1;
      }
    }
    if (calledFieldUnitActionTrans == null) {
      reviewTriggerCards();
    } else {
      if (cardTriggerAbilityCase == 2) {
        // カードが攻撃に出た時の能力
        reviewInterceptCards();
      } else {
        // カードがフィールドに出た時
        callEnterTheFieldTransaction();
      }
    }
  }

  /////////////////////////////
  // トリガーゾーンの効果判定処理 //
  /////////////////////////////
  void reviewTriggerCards() {
    reviewingTriggerCardPosition++;
    if (reviewingTriggerCardPosition > 4) {
      reviewInterceptCards();
      return;
    }
    // When put the card on FIELD:
    // trigger: 18,19 intercept: 20,21,23,27
    // Canon,Merchant, Breaker,Imperiale,Photon,Signal for assault)
    // When card ATTACK:
    // trigger: 17(Drive) intercept: 22(Dainsleif),24(Titan's Lock),25(Judge)

    // トリガーゾーンのカードはカードを置いたとき発動可能なインターセプトか?
    if (onChainYourTriggerCards.isNotEmpty &&
        onChainYourTriggerCards[reviewingTriggerCardPosition - 1] != null) {
      int cardId = onChainYourTriggerCards[reviewingTriggerCardPosition - 1]!;
      var skill = getCardSkill(cardId.toString());
      if (skill != null) {
        if (skill['trigger_1'] == cardTriggerAbilityCase.toString()) {
          if (getCardCategory(cardId.toString()) == '2') {
            /////////////////////////////
            // インターセプト (Breaker,Imperiale,Photon,Signal for assault)
            /////////////////////////////
            if (putCardOnFieldType != null &&
                (putCardOnFieldType == getCardType(cardId.toString()) ||
                    getCardType(cardId.toString()) == '4')) {
              canUseIntercept = true;
            } else {
              for (var i = 0; i < onChainYourFieldUnit.length; i++) {
                if (onChainYourFieldUnit[i] != null) {
                  if (getCardType(onChainYourFieldUnit[i].toString()) ==
                      getCardType(cardId.toString())) {
                    canUseIntercept = true;
                  }
                }
              }
            }
            if (gameObject!.yourCp <
                int.parse(getCardCost(cardId.toString()))) {
              canUseIntercept = false;
            }
            // Breaker
            if (cardId == 20) {
              if (opponentFieldUnitPositions.isEmpty) {
                canUseIntercept = false;
              }
            }
            // Dainsleif
            if (cardId == 22) {
              if (gameObject!.opponentTriggerCards == 0) {
                canUseIntercept = false;
              }
            }
            // Photon
            if (cardId == 23) {
              bool flg = false;
              for (var i = 1; i <= 5; i++) {
                if (gameObject!.opponentFieldUnitAction[i.toString()] == '0') {
                  flg = true;
                }
              }
              if (flg == false) {
                canUseIntercept = false;
              }
            }
            // Titan's Lock & Judge
            if (cardId == 24 || cardId == 25) {
              bool flg = false;
              for (var i = 1; i <= 5; i++) {
                if (gameObject!.opponentFieldUnitAction[i.toString()] == '1' ||
                    gameObject!.opponentFieldUnitAction[i.toString()] == '2') {
                  flg = true;
                }
              }
              if (flg == false) {
                canUseIntercept = false;
              }
            }
            if (canUseIntercept) {
              // 同色のカードがフィールドにあるので選択可能
              if (reviewingTriggerCardPosition == 1) {
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex1Event());
              } else if (reviewingTriggerCardPosition == 2) {
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex2Event());
              } else if (reviewingTriggerCardPosition == 3) {
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex3Event());
              } else if (reviewingTriggerCardPosition == 4) {
                attackStatusBloc.canAttackEventSink
                    .add(CanUseTriggerIndex4Event());
              }
            }
          } else if (getCardCategory(cardId.toString()) == '1') {
            /////////////////////////////
            // トリガー(Canon,Merchant) //
            /////////////////////////////
            if (cardId == 18) {
              if (opponentFieldUnitPositions.isNotEmpty) {
                // Canon
                onChainYourTriggerCardsDisplay[
                    reviewingTriggerCardPosition - 1] = null;
                usedTriggers.add(cardId);
                usedInterceptCardPosition.add(reviewingTriggerCardPosition);
                skillMessage = skillMessage != ''
                    ? '$skillMessage \nTRIGGER Canon ${L10n.of(context)!.activatedEffect} - Damage One Unit! -'
                    : 'TRIGGER Canon ${L10n.of(context)!.activatedEffect} - Damage One Unit! -';
                if (enemySkillTarget == 0) {
                  showUnitTargetCarousel = true;
                  showMessage(
                      4,
                      'TRIGGER Canon ${L10n.of(context)!.activatedEffect} - Choos One Unit! -',
                      null);
                  _timer.countdownStart(6, () {
                    showUnitTargetCarousel = false;
                    selectTarget(0); // 左端を強制選択
                  });
                  return;
                }
              }
            } else if (cardId == 17) {
              // Drive
              setState(() {
                skillMessage = skillMessage != ''
                    ? '$skillMessage \nTRIGGER Drive ${L10n.of(context)!.activatedEffect} - Augmented Power! -'
                    : 'TRIGGER Drive ${L10n.of(context)!.activatedEffect} - Augmented Power! -';
              });
              onChainYourTriggerCardsDisplay[reviewingTriggerCardPosition - 1] =
                  null;
              usedTriggers.add(cardId);
              usedInterceptCardPosition.add(reviewingTriggerCardPosition);
            } else if (cardId == 19) {
              // Merchant
              skillMessage = skillMessage != ''
                  ? '$skillMessage \nTRIGGER Merchant ${L10n.of(context)!.activatedEffect} - Card Draw! -'
                  : 'TRIGGER Merchant ${L10n.of(context)!.activatedEffect} - Card Draw! -';
              onChainYourTriggerCardsDisplay[reviewingTriggerCardPosition - 1] =
                  null;
              usedTriggers.add(cardId);
              usedInterceptCardPosition.add(reviewingTriggerCardPosition);
            }
          } else if (getCardCategory(cardId.toString()) == '2') {
            /////////////////////////////
            // トリガー(Drive) //
            /////////////////////////////
            if (cardId == 17) {
              // Drive
              skillMessage = skillMessage != ''
                  ? '$skillMessage \nTRIGGER Drive ${L10n.of(context)!.activatedEffect} - Augmented Power! -'
                  : 'TRIGGER Drive ${L10n.of(context)!.activatedEffect} - Augmented Power! -';
              onChainYourTriggerCardsDisplay[reviewingTriggerCardPosition - 1] =
                  null;
              usedTriggers.add(cardId);
              usedInterceptCardPosition.add(reviewingTriggerCardPosition);
              setState(() {
                usedInterceptCardPosition = usedInterceptCardPosition;
              });
            }
          }
        }
      }
    }
    Future.delayed(const Duration(milliseconds: 20), () {
      reviewTriggerCards();
    });
  }

  void reviewInterceptCards() {
    if (canUseIntercept == true) {
      setCanOperateTmp(false);
      showMessage(5, L10n.of(context)!.interceptAbailable, null);

      _timer.countdownStart(5, () async {
        canUseIntercept = false;
        setCanOperateTmp(true);
        attackStatusBloc.canAttackEventSink.add(CanNotUseTriggerEvent());
        if (cardTriggerAbilityCase == 2) {
          // カードが攻撃に出た時の能力
          calledFieldUnitActionTrans = false;
          for (var i = 0; i < usedTriggers.length; i++) {
            if (usedTriggers[i] == 22) {
              // Dainsleif
              setState(() {
                skillMessage = skillMessage = skillMessage != ''
                    ? '$skillMessage \nDainsleif ${L10n.of(context)!.activatedAbility} - Trigger Card Lost! -'
                    : 'Dainsleif ${L10n.of(context)!.activatedAbility} - Trigger Card Lost! -';
              });
            } else if (usedTriggers[i] == 24) {
              // Titan's Lock
              var leftMost = 0;
              for (var i = 1; i <= 5; i++) {
                if (gameObject!.opponentFieldUnitAction[i.toString()] == '1' ||
                    gameObject!.opponentFieldUnitAction[i.toString()] == '2') {
                  if (leftMost == 0) {
                    leftMost = i;
                  }
                  cannotDefendUnitPositions.add(i);
                }
              }
              if (cannotDefendUnitPositions.isNotEmpty) {
                setState(() {
                  skillMessage = skillMessage != ''
                      ? "$skillMessage \nTitan's Lock ${L10n.of(context)!.activatedAbility} - Remove Action Right! -"
                      : "Titan's Lock ${L10n.of(context)!.activatedAbility} - Remove Action Right! -";
                });
                if (enemySkillTarget == 0) {
                  showUnitTargetCarousel = true;
                  showMessage(
                      4,
                      "Titan's Lock ${L10n.of(context)!.activatedEffect} - Choos One Unit! -",
                      null);
                  _timer.countdownStart(6, () {
                    showUnitTargetCarousel = false;
                    selectTarget(leftMost - 1); // 左端を強制選択
                  });
                  return;
                }
              }
            } else if (usedTriggers[i] == 25) {
              // Judge
              setState(() {
                skillMessage = skillMessage != ''
                    ? '$skillMessage \Judgement ${L10n.of(context)!.activatedAbility} Remove Action Rights!'
                    : 'Judgement ${L10n.of(context)!.activatedAbility} Remove Action Rights!';
              });
            }
          }
          debugPrint('enemySkillTargetPosition $enemySkillTargetPosition');
          setState(() {
            attackIsReady = true;
            enemySkillTargetPosition = enemySkillTarget;
            isEnemyAttack = false;
          });
        } else if (cardTriggerAbilityCase == 1) {
          // カードがフィールドに出た時
          callEnterTheFieldTransaction();
        }
      });
    } else {
      // カードが攻撃に出た時の能力の場合
      if (cardTriggerAbilityCase == 2) {
        setState(() {
          enemySkillTargetPosition = enemySkillTarget;
          attackIsReady = true;
          isEnemyAttack = false;
        });
      } else if (cardTriggerAbilityCase == 1) {
        // カードがフィールドに出た時
        callEnterTheFieldTransaction();
      }
    }
  }

  // ユニットカードをフィールドに置くトランザクション実行処理
  void callEnterTheFieldTransaction() async {
    if (enemySkillTarget == 0) {
      calledFieldUnitActionTrans = false;
      for (var i = 0; i < usedTriggers.length; i++) {
        if (usedTriggers[i] == 20) {
          // Breaker
          skillMessage =
              'Breaker ${L10n.of(context)!.activatedAbility}  - Damage One Unit! -';
          if (enemySkillTarget == 0) {
            showUnitTargetCarousel = true;
            showMessage(
                4,
                'Breaker ${L10n.of(context)!.activatedEffect} - Choos One Unit! -',
                null);
            _timer.countdownStart(6, () {
              showUnitTargetCarousel = false;
              selectTarget(0); // 左端を強制選択
            });
          }
          return;
        } else if (usedTriggers[i] == 23) {
          // Photon
          for (var i = 1; i <= 5; i++) {
            if (gameObject!.opponentFieldUnitAction[i.toString()] == '0') {
              cannotDefendUnitPositions.add(i);
            }
          }
          if (cannotDefendUnitPositions.isNotEmpty) {
            skillMessage =
                'Photon ${L10n.of(context)!.activatedAbility} - Damage Acted-up Unit! -';
            if (enemySkillTarget == 0) {
              showUnitTargetCarousel = true;
              showMessage(
                  4,
                  'Photon ${L10n.of(context)!.activatedEffect} - Choos One Unit! -',
                  null);
              _timer.countdownStart(6, () {
                showUnitTargetCarousel = false;
                selectTarget(cannotDefendUnitPositions[0]); // 左端を強制選択
              });
            }
            return;
          }
        }
      }
    }
    if (calledFieldUnitActionTrans == null ||
        calledFieldUnitActionTrans == false) {
      calledFieldUnitActionTrans = true;
      // 使用可能なインターセプトを初期化
      canUseIntercept = false;
      // Call GraphQL method.
      var message = PutCardModel(fieldUnit, enemySkillTarget, triggerCards,
          usedInterceptCardPosition, skillMessage, usedTriggers);
      if (widget.isMobile == true) {
        apiService.saveGameServerProcess('put_card_on_the_field',
            jsonEncode(message), gameObject!.you.toString());
        await Future.delayed(const Duration(seconds: 1));
        for (var i = 0; i < usedInterceptCardPosition.length; i++) {
          onChainYourTriggerCards[usedInterceptCardPosition[i] - 1] = null;
        }
      } else {
        await apiService.saveGameServerProcess('put_card_on_the_field',
            jsonEncode(message), gameObject!.you.toString());
        for (var i = 0; i < usedInterceptCardPosition.length; i++) {
          onChainYourTriggerCards[usedInterceptCardPosition[i] - 1] = null;
        }
      }
    }
  }

  ///////////////////////
  // カードのタップ時処理 //
  ///////////////////////
  void tapCard(message, cardId, index) {
    tapCardIndex = index;
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
      attackStatusBloc.canAttackEventSink.add(ButtonTapedEvent());
      if (gameObject!.yourFieldUnitAction[(index + 1).toString()] == '2') {
        // 初期化
        enemySkillTarget = 0;
        triggerCards = TriggerCards(
            onChainYourTriggerCards[0],
            onChainYourTriggerCards[1],
            onChainYourTriggerCards[2],
            onChainYourTriggerCards[3]);
        usedInterceptCardPosition = [];
        skillMessage = '';
        usedTriggers = [];
        cannotDefendUnitPositions = [];
        selectTargetFlg = false;
        // 使用可能なインターセプトを初期化
        canUseIntercept = false;
        reviewingTriggerCardPosition = 0;
        calledFieldUnitActionTrans = null;
        putCardOnFieldType = null;
        cardTriggerAbilityCase = 2; // カードが攻撃に出た時の能力
        isBattling = true;
        attackIsReady = false;
        setState(() {
          attackSignalPosition = index;
          actedCardPosition = index;
        });
        reviewFieldUnitAbility(cardId);
      } else {
        showMessage(5, L10n.of(context)!.tooEarly, null);
      }
    } else if (message == 'use') {
      if (index == 0) {
        attackStatusBloc.canAttackEventSink.add(DisableTriggerIndex1Event());
      } else if (index == 1) {
        attackStatusBloc.canAttackEventSink.add(DisableTriggerIndex2Event());
      } else if (reviewingTriggerCardPosition == 2) {
        index.canAttackEventSink.add(DisableTriggerIndex3Event());
      } else if (index == 3) {
        attackStatusBloc.canAttackEventSink.add(DisableTriggerIndex4Event());
      }
      // インターセプトで使用したCPを減らす
      setState(() {
        gameObject!.yourCp = gameObject!.yourCp -
            int.parse(cardInfos[cardId.toString()]['cost']);
      });
      if (isEnemyAttack != null) {
        // バトル時
        useInterceptCardForBattle(cardId, index);
      } else if (cardTriggerAbilityCase == 2) {
        // 攻撃時
        useInterceptCardForAttack(cardId, index);
      } else if (cardTriggerAbilityCase == 1) {
        // フィールドにカードを出した時
        useInterceptCardForField(cardId, index);
      }
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

  // setState 一時的な操作可否
  void setCanOperateTmp(flg) {
    setState(() {
      canOperateTmp = flg;
    });
  }

  void doAnimation() {
    // Crashの原因になる
    if (widget.isMobile == false) {
      setState(() => cardPosition = 400.0);
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() => cardPosition = 0.0);
      });
    }
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

  // カードコスト
  String getCardCost(String cardId) {
    if (cardInfos != null) {
      var cardInfo = cardInfos[cardId];
      return cardInfo['cost'];
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
      if (widget.isMobile == true) {
        showGameLoading();
        apiService.saveGameServerProcess(
            'game_start', jsonEncode(handCards), gameObject!.you.toString());
        await Future.delayed(const Duration(seconds: 4));
        closeGameLoading();
        await Future.delayed(const Duration(seconds: 4));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showMessage(
              7,
              'Game Start. ${gameObject!.isFirst ? 'Your Turn!' : "Opponent's Turn!"}',
              null);
        });
      } else {
        showGameLoading();
        await apiService.saveGameServerProcess(
            'game_start', jsonEncode(handCards), gameObject!.you.toString());
        closeGameLoading();
        await Future.delayed(const Duration(seconds: 4));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showMessage(
              7,
              'Game Start. ${gameObject!.isFirst ? 'Your Turn!' : "Opponent's Turn!"}',
              null);
        });
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

      double r10 = r(10.0);
      double r35 = r(35.0);
      double r50 = r(50.0);
      double r80 = r(80.0);
      double r90 = r(90.0);
      double r100 = r(100.0);
      double r122 = r(122.0);
      double r125 = r(125.0);
      double r351 = r(351.0);
      double r373 = r(373.0);
      double r650 = r(650.0);
      double r785 = r(785.0);
      double r920 = r(920.0);
      double r1055 = r(1055.0);
      double r1190 = r(1190.0);
      _r = wRes;
      return Scaffold(
          backgroundColor: Colors.transparent,
          body: isMainWindow == false
              ? Padding(
                  padding: EdgeInsets.only(top: r(55.0)),
                  child: Stack(children: [
                    Center(
                        child: Image.asset(
                      width: r(1280.0),
                      height: r(720.0),
                      '${lottiePath}images/img_1.jpg',
                      fit: BoxFit.cover,
                    )),
                    eyeCatchSequence == 0 && widget.enLocale == true
                        ? Center(
                            child: Text(
                            'For every 1000 battles played worldwide, \n20 FLOW will be paid to the first place \nin the ranking! The more people play, the more \nmoney you get! Earn more and more \$FLOW!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: r(50.0) > 42 ? 42 : r(54.0)),
                          ))
                        : const SizedBox.shrink(),
                    eyeCatchSequence == 0 && widget.enLocale == false
                        ? Center(
                            child: Text(
                            '全世界で1000バトルプレイされる度に20\$FLOW\nがランキング１位に支払われる！\nプレイ人口が増えれば増えるほど、\n金額も上がる！どんどん\$FLOWを稼ごう！',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: r(50.0) > 42 ? 42 : r(54.0)),
                          ))
                        : const SizedBox.shrink(),
                    eyeCatchSequence == 2
                        ? Center(
                            child: Image.asset(
                            width: r(1113.0),
                            height: r(560.0),
                            '${lottiePath}images/img_0.jpg',
                            fit: BoxFit.cover,
                          ))
                        : const SizedBox.shrink(),
                  ]))
              : Stack(fit: StackFit.expand, children: <Widget>[
                  widget.needEyeCatch == true &&
                          widget.isMobile == true &&
                          widget.enLocale == true
                      ? Stack(children: [
                          Positioned(
                              left: r(50.0),
                              bottom: r(10.0),
                              child: Image.asset(
                                width: r(1280.0),
                                height: r(780.0),
                                '${imagePath}unit/hazard.png',
                                fit: BoxFit.cover,
                              )),
                          Positioned(
                              left: r(20.0),
                              bottom: r(800.0),
                              child: Text(
                                'You will own 78 cards to start with, so you can decide which cards you want \nto use in the game. You will be provided with a starter deck, so you can start \nplaying right away.\n\nYou can play 10 times for 3 \$FLOW, and if you win 10 games, you get 5 \$FLOW.\n\n',
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(38.0)),
                              )),
                          Positioned(
                              left: r(90.0),
                              bottom: r(610.0),
                              child: Text(
                                '🚨Images may take a time to load on your phone and may not\nimmediately display at the drop site. Please wait until they are cached.',
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(36.0)),
                              )),
                          Positioned(
                              left: r(90.0),
                              bottom: r(380.0),
                              child: Text(
                                '🚨Reloading seems to occur more frequently by the degraded \nbattery condition, if you have a Mac,PC I recommend you to use \nthat. This is implemented to work on a smartphone, but it is mainly \nsuitable for use on a laptop because of the bounty on it.',
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(36.0)),
                              )),
                          Positioned(
                              left: r(90.0),
                              bottom: r(310.0),
                              child: Text(
                                "Discord channel:",
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(42.0)),
                              )),
                          Positioned(
                              left: r(90.0),
                              bottom: r(256.0),
                              child: InkWell(
                                onTap: () => html.window.open(
                                    'https://discord.com/invite/DV6VafmQ2S',
                                    'discord'),
                                child: const Text(
                                  'https://discord.com/invite/DV6VafmQ2S',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue,
                                      fontSize: 12.0),
                                ),
                              )),
                          Positioned(
                              left: r(90.0),
                              bottom: r(90.0),
                              child: Text(
                                "Code Of Joker(COJ) debuted in SEGA's Game Arcade on July 11, \n 2013 (10 years ago!). I wanted to tell people that the revival is \npossible with BCG if it's built on Flow Blockchain.",
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(42.0)),
                              )),
                        ])
                      : const SizedBox.shrink(),
                  widget.needEyeCatch == true &&
                          widget.isMobile == true &&
                          widget.enLocale == false
                      ? Stack(children: [
                          Positioned(
                              left: r(50.0),
                              bottom: r(10.0),
                              child: Image.asset(
                                width: r(1280.0),
                                height: r(780.0),
                                '${imagePath}unit/hazard.png',
                                fit: BoxFit.cover,
                              )),
                          Positioned(
                              left: r(20.0),
                              bottom: r(800.0),
                              child: Text(
                                '最初に78枚のカードを所有していますので、どのカードをゲームに使用するか\n決める事が出来ます。最初にスターターデッキがセットされていますので、いき\nなりゲームする事も出来ます。\n3 \$FLOWで10回プレイ出来、10回ゲームに勝利すると5 \$FLOWを得る事が出来\nます。\n\n',
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(38.0)),
                              )),
                          Positioned(
                              left: r(90.0),
                              bottom: r(610.0),
                              child: Text(
                                '🚨画像はスマホでは読み込みに時間がかかり、すぐにドロップ先で\n表示されない可能性があります。キャッシュされるまでお待ち下さい。',
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(36.0)),
                              )),
                          Positioned(
                              left: r(90.0),
                              bottom: r(380.0),
                              child: Text(
                                '🚨バッテリー状態が劣化しているとリロードが頻繁に発生するよう\nです。Mac,PCをお持ちでしたらそちらをお勧めします。\nスマホでも動くように実装しましたが、賞金がかかっているので\nノートパソコンの方をメインに使うのが合っていると思います。',
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(36.0)),
                              )),
                          Positioned(
                              left: r(90.0),
                              bottom: r(310.0),
                              child: Text(
                                'Discord チャンネル:',
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(42.0)),
                              )),
                          Positioned(
                              left: r(90.0),
                              bottom: r(256.0),
                              child: InkWell(
                                onTap: () => html.window.open(
                                    'https://discord.com/invite/DV6VafmQ2S',
                                    'discord'),
                                child: const Text(
                                  'https://discord.com/invite/DV6VafmQ2S',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue,
                                      fontSize: 12.0),
                                ),
                              )),
                          Positioned(
                              left: r(90.0),
                              bottom: r(90.0),
                              child: Text(
                                'Code Of Joker(COJ)は2013年の7月11日（今から10年前!）に\nSEGAのゲームセンターでデビューしました。Flow Blockchainの\nBCGなら復活が可能だと伝えたかったのです。',
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(42.0)),
                              )),
                        ])
                      : const SizedBox.shrink(),
                  // デッキカード
                  Positioned(
                      left: r(340.0),
                      top: r(403.0),
                      child: Row(children: <Widget>[
                        gameProgressStatus >= 1 && gameStarted
                            ? widget.isMobile == true
                                ? Row(
                                    children: [
                                      for (var i = 0; i < handCards.length; i++)
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                tappedCardId = handCards[i];
                                              });
                                            },
                                            child: DragBox(
                                                i,
                                                handCards[i],
                                                putCard,
                                                cardInfos[
                                                    handCards[i].toString()],
                                                r,
                                                widget.isMobile)),
                                    ],
                                  )
                                : AnimatedContainer(
                                    margin: EdgeInsetsDirectional.only(
                                        top: cardPosition),
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.linear,
                                    child: Row(
                                      children: [
                                        for (var i = 0;
                                            i < handCards.length;
                                            i++)
                                          GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  tappedCardId = handCards[i];
                                                });
                                              },
                                              child: DragBox(
                                                  i,
                                                  handCards[i],
                                                  putCard,
                                                  cardInfos[
                                                      handCards[i].toString()],
                                                  r,
                                                  widget.isMobile)),
                                      ],
                                    ),
                                  )
                            : widget.isMobile == true
                                ? Row(
                                    children: [
                                      for (var cardId in [
                                        16,
                                        13,
                                        4,
                                        3,
                                        25,
                                        20,
                                        26
                                      ])
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
                                                    ? cardInfos[
                                                        cardId.toString()]
                                                    : null,
                                                r,
                                                widget.isMobile)),
                                    ],
                                  )
                                : AnimatedContainer(
                                    margin: EdgeInsetsDirectional.only(
                                        top: cardPosition),
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.linear,
                                    child: Row(
                                      children: [
                                        for (var cardId in [
                                          16,
                                          13,
                                          4,
                                          3,
                                          25,
                                          20,
                                          26
                                        ])
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
                                                      ? cardInfos[
                                                          cardId.toString()]
                                                      : null,
                                                  r,
                                                  widget.isMobile)),
                                      ],
                                    ),
                                  ),
                      ])),
                  Positioned(
                    left: r(470.0),
                    top: r90,
                    child: Container(
                      width: r125,
                      height: r(45.0),
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image:
                                      AssetImage('image/trigger/trigger.png'),
                                  fit: BoxFit.cover),
                            )
                          : const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage(
                                      'assets/image/trigger/trigger.png'),
                                  fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  gameObject != null && gameStarted == true
                      ? OnGoingGameInfo(
                          gameObject,
                          setCanOperate,
                          attackStatusBloc.attack_stream,
                          opponentDefendPosition,
                          attackerUsedInterceptCard,
                          defenderUsedInterceptCard,
                          isEnemyAttack == true
                              ? opponentDefendPosition != null &&
                                      gameObject!.yourFieldUnit[opponentDefendPosition.toString()] !=
                                          null
                                  ? gameObject!.yourFieldUnit[
                                      opponentDefendPosition.toString()]
                                  : ''
                              : actedCardPosition != null &&
                                      gameObject!.yourFieldUnit[(actedCardPosition! + 1).toString()] !=
                                          null
                                  ? gameObject!.yourFieldUnit[
                                      (actedCardPosition! + 1).toString()]
                                  : '',
                          isEnemyAttack == true
                              ? onBattlePosition != null &&
                                      gameObject!.opponentFieldUnit[
                                              onBattlePosition.toString()] !=
                                          null
                                  ? gameObject!.opponentFieldUnit[
                                      onBattlePosition.toString()]
                                  : ''
                              : opponentDefendPosition != null &&
                                      gameObject!.opponentFieldUnit[
                                              opponentDefendPosition.toString()] !=
                                          null
                                  ? gameObject!.opponentFieldUnit[opponentDefendPosition.toString()]
                                  : '',
                          cardInfos,
                          onChainYourTriggerCards,
                          isEnemyAttack,
                          attackerUsedCardIds,
                          defenderUsedCardIds,
                          r,
                          widget.isMobile)
                      : const SizedBox.shrink(),
                  DeckCardInfo(gameObject, cardInfos, tappedCardId, 'home',
                      widget.enLocale, r),
                  // DragTargetWidget
                  Positioned(
                      left: r(35.0),
                      top: 0.0,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  r(150.0), r(200.0), r(30.0), r(0.0)),
                              child: DragTargetWidget(
                                  'trigger',
                                  '${imagePath}trigger/trigger.png',
                                  gameObject,
                                  cardInfos,
                                  tapCard,
                                  actedCardPosition,
                                  canOperate,
                                  attackStatusBloc.attack_stream,
                                  defaultTriggerCards,
                                  onChainYourTriggerCards,
                                  const [],
                                  const [],
                                  null,
                                  '',
                                  canOperateTmp,
                                  attackIsReady,
                                  r,
                                  widget.isMobile),
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
                                  onChainYourTriggerCards,
                                  usedInterceptCardPosition,
                                  usedTriggers,
                                  enemySkillTargetPosition,
                                  skillMessage,
                                  canOperateTmp,
                                  attackIsReady,
                                  r,
                                  widget.isMobile),
                            ),
                          ])),
                  // マリガンタイマー
                  gameProgressStatus == 1
                      ? Positioned(
                          left: r(800),
                          top: r(480),
                          child: SizedBox(
                              width: r100,
                              child: StreamBuilder<int>(
                                  stream: _timer.events.stream,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<int> snapshot) {
                                    return Visibility(
                                        visible: snapshot.data != null &&
                                            snapshot.data != 0,
                                        child: Center(
                                            child: Text(
                                          '0:0${snapshot.data.toString()}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: r(42.0)),
                                        )));
                                  })))
                      : const SizedBox.shrink(),
                  // マリガンボタン
                  mariganClickCount < 5 && gameProgressStatus == 1
                      ? Positioned(
                          left: r(900),
                          top: r(500),
                          child: StreamBuilder<int>(
                              stream: _timer.events.stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<int> snapshot) {
                                return Visibility(
                                    visible: snapshot.data != 0,
                                    child: SizedBox(
                                        width: snapshot.data != 0 ? r100 : 0.0,
                                        height: r(25.0),
                                        child: FloatingActionButton(
                                            backgroundColor: Colors.transparent,
                                            onPressed: () {
                                              if (mariganClickCount < 5) {
                                                setState(() =>
                                                    mariganClickCount =
                                                        mariganClickCount + 1);
                                                setState(() => handCards =
                                                    mariganCardIdList[
                                                        mariganClickCount]);
                                              } else {
                                                // 6回目は1回目をセット
                                                setState(() => handCards =
                                                    mariganCardIdList[0]);
                                              }
                                            },
                                            tooltip: 'Redraw',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              child: Image.asset(
                                                width: r(65.0),
                                                height: r(25.0),
                                                '${imagePath}button/redo.png',
                                                fit: BoxFit
                                                    .cover, //prefer cover over fill
                                              ),
                                            ))));
                              }))
                      : const SizedBox.shrink(),
                  // AttackTarget
                  attackSignalPosition != null
                      ? Positioned(
                          left: r(attackSignalPosition != null &&
                                  (attackSignalPosition! == 2 ||
                                      attackSignalPosition! == 0)
                              ? 760.0
                              : 830.0),
                          top: r(-2.0),
                          child: Container(
                            width: r(75.0),
                            height: r(75.0),
                            decoration: envFlavor != 'prod'
                                ? const BoxDecoration(
                                    color: Colors.transparent,
                                    image: DecorationImage(
                                        opacity: 0.7,
                                        image: AssetImage(
                                            'image/unit/attackTarget.png'),
                                        fit: BoxFit.cover),
                                  )
                                : const BoxDecoration(
                                    color: Colors.transparent,
                                    image: DecorationImage(
                                        opacity: 0.7,
                                        image: AssetImage(
                                            'assets/image/unit/attackTarget.png'),
                                        fit: BoxFit.cover),
                                  ),
                          ),
                        )
                      : const SizedBox.shrink(),

                  Positioned(
                    left: r(648.0),
                    top: r122,
                    child: Container(
                      width: r90,
                      height: r50,
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage('image/unit/status.png'),
                                  fit: BoxFit.cover),
                            )
                          : (widget.isMobile == true
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )),
                    ),
                  ),
                  // Enemy's 1st Unit Name
                  Positioned(
                      left: r650,
                      top: r125,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.opponentFieldUnit['1'] != null
                              ? (gameObject!.opponentFieldUnitAction['1'] == '2'
                                      ? '🗡️'
                                      : '　') +
                                  getCardName(
                                      gameObject!.opponentFieldUnit['1'])
                              : '',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  // Enemy's 1st Unit BP
                  Positioned(
                      left: r650,
                      top: r(147.0),
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.opponentFieldUnit['1'] != null
                              ? (gameObject!.opponentFieldUnitAction['1'] ==
                                              '1' ||
                                          gameObject!.opponentFieldUnitAction[
                                                  '1'] ==
                                              '2'
                                      ? '🛡️'
                                      : '　') +
                                  gameObject!.opponentFiledUnitBps['1']
                                      .toString()
                              : '',
                          style: TextStyle(
                            color: gameObject != null &&
                                    gameObject!.opponentFieldUnitBpAmountOfChange[
                                            '1'] !=
                                        null
                                ? (int.parse(gameObject!
                                                .opponentFieldUnitBpAmountOfChange[
                                            '1']) >
                                        0
                                    ? Colors.blue
                                    : Colors.red)
                                : Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),

                  Positioned(
                    left: r(783.0),
                    top: r122,
                    child: Container(
                      width: r90,
                      height: r50,
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage('image/unit/status.png'),
                                  fit: BoxFit.cover),
                            )
                          : (widget.isMobile == true
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )),
                    ),
                  ),
                  // Enemy's 2st Unit Name
                  Positioned(
                      left: r785,
                      top: r125,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.opponentFieldUnit['2'] != null
                              ? (gameObject!.opponentFieldUnitAction['2'] == '2'
                                      ? '🗡️'
                                      : '　') +
                                  getCardName(
                                      gameObject!.opponentFieldUnit['2'])
                              : '',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  // Enemy's 2st Unit BP
                  Positioned(
                      left: r785,
                      top: r(147.0),
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.opponentFieldUnit['2'] != null
                              ? (gameObject!.opponentFieldUnitAction['2'] ==
                                              '1' ||
                                          gameObject!.opponentFieldUnitAction[
                                                  '2'] ==
                                              '2'
                                      ? '🛡️'
                                      : '　') +
                                  gameObject!.opponentFiledUnitBps['2']
                                      .toString()
                              : '',
                          style: TextStyle(
                            color: gameObject != null &&
                                    gameObject!.opponentFieldUnitBpAmountOfChange[
                                            '2'] !=
                                        null
                                ? (int.parse(gameObject!
                                                .opponentFieldUnitBpAmountOfChange[
                                            '2']) >
                                        0
                                    ? Colors.blue
                                    : Colors.red)
                                : Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),

                  Positioned(
                    left: r(918.0),
                    top: r122,
                    child: Container(
                      width: r90,
                      height: r50,
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage('image/unit/status.png'),
                                  fit: BoxFit.cover),
                            )
                          : (widget.isMobile == true
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )),
                    ),
                  ),
                  // Enemy's 3st Unit Name
                  Positioned(
                      left: r920,
                      top: r125,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.opponentFieldUnit['3'] != null
                              ? (gameObject!.opponentFieldUnitAction['3'] == '2'
                                      ? '🗡️'
                                      : '　') +
                                  getCardName(
                                      gameObject!.opponentFieldUnit['3'])
                              : '',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  // Enemy's 3st Unit BP
                  Positioned(
                      left: r920,
                      top: r(147.0),
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.opponentFieldUnit['3'] != null
                              ? (gameObject!.opponentFieldUnitAction['3'] ==
                                              '1' ||
                                          gameObject!.opponentFieldUnitAction[
                                                  '3'] ==
                                              '2'
                                      ? '🛡️'
                                      : '　') +
                                  gameObject!.opponentFiledUnitBps['3']
                                      .toString()
                              : '',
                          style: TextStyle(
                            color: gameObject != null &&
                                    gameObject!.opponentFieldUnitBpAmountOfChange[
                                            '3'] !=
                                        null
                                ? (int.parse(gameObject!
                                                .opponentFieldUnitBpAmountOfChange[
                                            '3']) >
                                        0
                                    ? Colors.blue
                                    : Colors.red)
                                : Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  Positioned(
                    left: r(1053.0),
                    top: r122,
                    child: Container(
                      width: r90,
                      height: r50,
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage('image/unit/status.png'),
                                  fit: BoxFit.cover),
                            )
                          : (widget.isMobile == true
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )),
                    ),
                  ),
                  // Enemy's 4st Unit Name
                  Positioned(
                      left: r1055,
                      top: r125,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.opponentFieldUnit['4'] != null
                              ? (gameObject!.opponentFieldUnitAction['4'] == '2'
                                      ? '🗡️'
                                      : '　') +
                                  getCardName(
                                      gameObject!.opponentFieldUnit['4'])
                              : '',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  // Enemy's 4st Unit BP
                  Positioned(
                      left: r1055,
                      top: r(147.0),
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.opponentFieldUnit['4'] != null
                              ? (gameObject!.opponentFieldUnitAction['4'] ==
                                              '1' ||
                                          gameObject!.opponentFieldUnitAction[
                                                  '4'] ==
                                              '2'
                                      ? '🛡️'
                                      : '　') +
                                  gameObject!.opponentFiledUnitBps['4']
                                      .toString()
                              : '',
                          style: TextStyle(
                            color: gameObject != null &&
                                    gameObject!.opponentFieldUnitBpAmountOfChange[
                                            '4'] !=
                                        null
                                ? (int.parse(gameObject!
                                                .opponentFieldUnitBpAmountOfChange[
                                            '4']) >
                                        0
                                    ? Colors.blue
                                    : Colors.red)
                                : Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  Positioned(
                    left: r(1188.0),
                    top: r122,
                    child: Container(
                      width: r90,
                      height: r50,
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage('image/unit/status.png'),
                                  fit: BoxFit.cover),
                            )
                          : (widget.isMobile == true
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )),
                    ),
                  ),
                  // Enemy's 5st Unit Name
                  Positioned(
                      left: r1190,
                      top: r125,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.opponentFieldUnit['5'] != null
                              ? (gameObject!.opponentFieldUnitAction['5'] == '2'
                                      ? '🗡️'
                                      : '　') +
                                  getCardName(
                                      gameObject!.opponentFieldUnit['5'])
                              : '',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  // Enemy's 5st Unit BP
                  Positioned(
                      left: r1190,
                      top: r(147.0),
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.opponentFieldUnit['5'] != null
                              ? (gameObject!.opponentFieldUnitAction['5'] ==
                                              '1' ||
                                          gameObject!.opponentFieldUnitAction[
                                                  '5'] ==
                                              '2'
                                      ? '🛡️'
                                      : '　') +
                                  gameObject!.opponentFiledUnitBps['5']
                                      .toString()
                              : '',
                          style: TextStyle(
                            color: gameObject != null &&
                                    gameObject!.opponentFieldUnitBpAmountOfChange[
                                            '5'] !=
                                        null
                                ? (int.parse(gameObject!
                                                .opponentFieldUnitBpAmountOfChange[
                                            '5']) >
                                        0
                                    ? Colors.blue
                                    : Colors.red)
                                : Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  Positioned(
                    left: r(648.0),
                    top: r(348.0),
                    child: Container(
                      width: r90,
                      height: r50,
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage('image/unit/status.png'),
                                  fit: BoxFit.cover),
                            )
                          : (widget.isMobile == true
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )),
                    ),
                  ),
                  // Your 1st Unit Name
                  Positioned(
                      left: r650,
                      top: r351,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.yourFieldUnit['1'] != null
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
                      left: r650,
                      top: r373,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.yourFieldUnit['1'] != null
                              ? (gameObject!.yourFieldUnitAction['1'] == '1' ||
                                          gameObject!
                                                  .yourFieldUnitAction['1'] ==
                                              '2'
                                      ? '🛡️'
                                      : '　') +
                                  gameObject!.yourFiledUnitBps['1'].toString()
                              : '',
                          style: TextStyle(
                            color: gameObject != null &&
                                    gameObject!.yourFieldUnitBpAmountOfChange[
                                            '1'] !=
                                        null
                                ? (int.parse(gameObject!
                                                .yourFieldUnitBpAmountOfChange[
                                            '1']) >
                                        0
                                    ? Colors.blue
                                    : Colors.red)
                                : Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  Positioned(
                    left: r(783.0),
                    top: r(348.0),
                    child: Container(
                      width: r90,
                      height: r50,
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage('image/unit/status.png'),
                                  fit: BoxFit.cover),
                            )
                          : (widget.isMobile == true
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )),
                    ),
                  ),
                  // Your 2st Unit Name
                  Positioned(
                      left: r785,
                      top: r351,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.yourFieldUnit['2'] != null
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
                      left: r785,
                      top: r373,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.yourFieldUnit['2'] != null
                              ? (gameObject!.yourFieldUnitAction['2'] == '1' ||
                                          gameObject!
                                                  .yourFieldUnitAction['2'] ==
                                              '2'
                                      ? '🛡️'
                                      : '　') +
                                  gameObject!.yourFiledUnitBps['2'].toString()
                              : '',
                          style: TextStyle(
                            color: gameObject != null &&
                                    gameObject!.yourFieldUnitBpAmountOfChange[
                                            '2'] !=
                                        null
                                ? (int.parse(gameObject!
                                                .yourFieldUnitBpAmountOfChange[
                                            '2']) >
                                        0
                                    ? Colors.blue
                                    : Colors.red)
                                : Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  Positioned(
                    left: r(918.0),
                    top: r(348.0),
                    child: Container(
                      width: r90,
                      height: r50,
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage('image/unit/status.png'),
                                  fit: BoxFit.cover),
                            )
                          : (widget.isMobile == true
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )),
                    ),
                  ),
                  // Your 3st Unit Name
                  Positioned(
                      left: r920,
                      top: r351,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.yourFieldUnit['3'] != null
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
                      left: r920,
                      top: r373,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.yourFieldUnit['3'] != null
                              ? (gameObject!.yourFieldUnitAction['3'] == '1' ||
                                          gameObject!
                                                  .yourFieldUnitAction['3'] ==
                                              '2'
                                      ? '🛡️'
                                      : '　') +
                                  gameObject!.yourFiledUnitBps['3'].toString()
                              : '',
                          style: TextStyle(
                            color: gameObject != null &&
                                    gameObject!.yourFieldUnitBpAmountOfChange[
                                            '3'] !=
                                        null
                                ? (int.parse(gameObject!
                                                .yourFieldUnitBpAmountOfChange[
                                            '3']) >
                                        0
                                    ? Colors.blue
                                    : Colors.red)
                                : Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  Positioned(
                    left: r(1053.0),
                    top: r(348.0),
                    child: Container(
                      width: r90,
                      height: r50,
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage('image/unit/status.png'),
                                  fit: BoxFit.cover),
                            )
                          : (widget.isMobile == true
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )),
                    ),
                  ),
                  // Your 4st Unit Name
                  Positioned(
                      left: r1055,
                      top: r351,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.yourFieldUnit['4'] != null
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
                      left: r1055,
                      top: r373,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.yourFieldUnit['4'] != null
                              ? (gameObject!.yourFieldUnitAction['4'] == '1' ||
                                          gameObject!
                                                  .yourFieldUnitAction['4'] ==
                                              '2'
                                      ? '🛡️'
                                      : '　') +
                                  gameObject!.yourFiledUnitBps['4'].toString()
                              : '',
                          style: TextStyle(
                            color: gameObject != null &&
                                    gameObject!.yourFieldUnitBpAmountOfChange[
                                            '4'] !=
                                        null
                                ? (int.parse(gameObject!
                                                .yourFieldUnitBpAmountOfChange[
                                            '4']) >
                                        0
                                    ? Colors.blue
                                    : Colors.red)
                                : Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  Positioned(
                    left: r(1188.0),
                    top: r(348.0),
                    child: Container(
                      width: r90,
                      height: r50,
                      decoration: envFlavor != 'prod'
                          ? const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.5,
                                  image: AssetImage('image/unit/status.png'),
                                  fit: BoxFit.cover),
                            )
                          : (widget.isMobile == true
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )
                              : const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      opacity: 0.5,
                                      image: AssetImage(
                                          'assets/image/unit/status.png'),
                                      fit: BoxFit.cover),
                                )),
                    ),
                  ),
                  // Your 5st Unit Name
                  Positioned(
                      left: r1190,
                      top: r351,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.yourFieldUnit['5'] != null
                              ? (gameObject!.yourFieldUnitAction['5'] == '2'
                                      ? '🗡️'
                                      : '　') +
                                  getCardName(gameObject!.yourFieldUnit['5'])
                              : '',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  // Your 5st Unit BP
                  Positioned(
                      left: r1190,
                      top: r373,
                      width: r100,
                      child: Text(
                          gameObject != null &&
                                  gameObject!.yourFieldUnit['5'] != null
                              ? (gameObject!.yourFieldUnitAction['5'] == '1' ||
                                          gameObject!
                                                  .yourFieldUnitAction['5'] ==
                                              '2'
                                      ? '🛡️'
                                      : '　') +
                                  gameObject!.yourFiledUnitBps['5'].toString()
                              : '',
                          style: TextStyle(
                            color: gameObject != null &&
                                    gameObject!.yourFieldUnitBpAmountOfChange[
                                            '5'] !=
                                        null
                                ? (int.parse(gameObject!
                                                .yourFieldUnitBpAmountOfChange[
                                            '5']) >
                                        0
                                    ? Colors.blue
                                    : Colors.red)
                                : Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: r(16.0),
                          ))),
                  // ランキングボタン
                  gameStarted == false
                      ? Positioned(
                          top: r(160.0),
                          left: r(330.0),
                          child: SizedBox(
                              width: r50 < 26 ? 26 : r50,
                              height: r50 < 26 ? 26 : r50,
                              child: FittedBox(
                                  child: FloatingActionButton(
                                      backgroundColor: Colors.transparent,
                                      onPressed: () {
                                        html.window.location.href = 'ranking';
                                      },
                                      tooltip: 'RANKING!',
                                      // elevation: 0.0,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(r(4.0)),
                                        child: Image.asset(
                                          '${imagePath}button/home_ranking.png',
                                          fit: BoxFit.cover,
                                        ),
                                      )))))
                      : const SizedBox.shrink(),
                  // ホワイトペーパー
                  gameStarted == false
                      ? Positioned(
                          top: r(160.0),
                          left: r(205.0),
                          child: SizedBox(
                              width: r50 < 26 ? 26 : r50,
                              height: r50 < 26 ? 26 : r50,
                              child: FittedBox(
                                  child: FloatingActionButton(
                                      backgroundColor: Colors.transparent,
                                      onPressed: () {
                                        html.window
                                            .open('white_paper', 'white_paper');
                                        // html.window.location.href = 'white_paper';
                                      },
                                      tooltip: 'White Paper',
                                      // elevation: 0.0,
                                      child: const ClipRRect(
                                        child: Icon(
                                          Icons.receipt_long,
                                          size: 52.0,
                                          color: Colors.white,
                                        ),
                                      )))))
                      : const SizedBox.shrink(),
                  // 敵のバトルカード
                  gameObject != null &&
                          ((isEnemyAttack == true &&
                                  onBattlePosition != null &&
                                  gameObject!.opponentFieldUnit[
                                          onBattlePosition.toString()] !=
                                      null) ||
                              (isEnemyAttack == false &&
                                  opponentDefendPosition != null &&
                                  gameObject!.opponentFieldUnit[
                                          opponentDefendPosition.toString()] !=
                                      null))
                      ? Positioned(
                          right: r80,
                          top: r90,
                          child: GFImageOverlay(
                            width: r(200.0),
                            height: r(300.0),
                            image: AssetImage(gameObject == null
                                ? ''
                                : isEnemyAttack == true
                                    ? gameObject!.opponentFieldUnit[
                                                onBattlePosition.toString()] !=
                                            null
                                        ? '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_${gameObject!.opponentFieldUnit[onBattlePosition.toString()]}.jpeg'
                                        : '${imagePath}unit/bg-2.jpg'
                                    : gameObject!.opponentFieldUnit[
                                                opponentDefendPosition
                                                    .toString()] !=
                                            null
                                        ? '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_${gameObject!.opponentFieldUnit[opponentDefendPosition.toString()]}.jpeg'
                                        : '${imagePath}unit/bg-2.jpg'),
                          ),
                        )
                      : const SizedBox.shrink(),
                  // あなたのバトルカード
                  gameObject != null &&
                          ((isEnemyAttack == true &&
                                  opponentDefendPosition != null &&
                                  gameObject!.yourFieldUnit[
                                          opponentDefendPosition.toString()] !=
                                      null) ||
                              (isEnemyAttack == false &&
                                  actedCardPosition != null &&
                                  attackerUsedCardIds.isNotEmpty &&
                                  gameObject!.yourFieldUnit[
                                          (actedCardPosition! + 1)
                                              .toString()] !=
                                      null))
                      ? Positioned(
                          right: r(400.0),
                          top: r90,
                          child: GFImageOverlay(
                            width: r(200.0),
                            height: r(300.0),
                            shape: BoxShape.rectangle,
                            image: AssetImage(isEnemyAttack == true
                                ? opponentDefendPosition != null &&
                                        gameObject!.yourFieldUnit[
                                                opponentDefendPosition
                                                    .toString()] !=
                                            null
                                    ? '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_${gameObject!.yourFieldUnit[opponentDefendPosition.toString()]}.jpeg'
                                    : '${imagePath}unit/bg-2.jpg'
                                : actedCardPosition != null &&
                                        gameObject!.yourFieldUnit[
                                                (actedCardPosition! + 1)
                                                    .toString()] !=
                                            null
                                    ? '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_${gameObject!.yourFieldUnit[(actedCardPosition! + 1).toString()]}.jpeg'
                                    : '${imagePath}unit/bg-2.jpg'),
                          ))
                      : const SizedBox.shrink(),
                  // 攻撃側の使用したトリガー・インターセプトカード
                  gameObject != null && attackerUsedCardIds.isNotEmpty
                      ? Positioned(
                          right: isEnemyAttack == true ? r80 : r(400.0),
                          top: r(340.0),
                          child: Row(
                            children: [
                              for (var cardId in attackerUsedCardIds)
                                GFImageOverlay(
                                  width: r80,
                                  height: r(120.0),
                                  image: AssetImage(gameObject == null
                                      ? ''
                                      : '${imagePath}trigger/${widget.isMobile ? 'mobile/' : ''}card_${cardId.toString()}.jpeg'),
                                ),
                            ],
                          ))
                      : const SizedBox.shrink(),
                  // 防御側の使用したトリガー・インターセプトカード
                  gameObject != null && defenderUsedCardIds.isNotEmpty
                      ? Positioned(
                          right: isEnemyAttack == true ? r(400.0) : r80,
                          top: r(340.0),
                          child: Row(
                            children: [
                              for (var cardId in defenderUsedCardIds)
                                GFImageOverlay(
                                  width: r80,
                                  height: r(120.0),
                                  image: AssetImage(gameObject == null
                                      ? ''
                                      : '${imagePath}trigger/${widget.isMobile ? 'mobile/' : ''}card_${cardId.toString()}.jpeg'),
                                ),
                            ],
                          ))
                      : const SizedBox.shrink(),
                  // Choose target unit
                  showUnitTargetCarousel == true
                      ? Column(children: <Widget>[
                          CarouselSlider.builder(
                            carouselController: cController,
                            options: CarouselOptions(
                                height: r(250),
                                aspectRatio: 14 / 9,
                                viewportFraction: 0.6, // 1.0:1つが全体に出る
                                initialPage: 0,
                                // enableInfiniteScroll: true,
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    activeIndex = index;
                                  });
                                }),
                            itemCount: gameObject == null
                                ? 0
                                : (cannotDefendUnitPositions.isNotEmpty
                                    ? cannotDefendUnitPositions.length
                                    : opponentFieldUnitPositions.length),
                            itemBuilder: (context, index, realIndex) {
                              // 行動済みのみ
                              if (cannotDefendUnitPositions.isNotEmpty) {
                                var target = cannotDefendUnitPositions[index];
                                var cardId = gameObject!
                                    .opponentFieldUnit[(target).toString()];
                                return Image.asset(
                                  '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_$cardId.jpeg',
                                  fit: BoxFit.cover,
                                );
                              } else {
                                // 全体から
                                var target = opponentFieldUnitPositions[index];
                                var cardId = gameObject!
                                    .opponentFieldUnit[(target).toString()];
                                return Image.asset(
                                  '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_$cardId.jpeg',
                                  fit: BoxFit.cover,
                                );
                              }
                            },
                          ),
                          SizedBox(height: r10),
                          buildIndicator(cannotDefendUnitPositions.isNotEmpty
                              ? cannotDefendUnitPositions.length
                              : opponentFieldUnitPositions.length),
                          SizedBox(height: r10),
                          Visibility(
                              visible: cannotDefendUnitPositions.isNotEmpty
                                  ? cannotDefendUnitPositions.length > 1
                                  : opponentFieldUnitPositions.length > 1,
                              child: ElevatedButton(
                                onPressed: () =>
                                    cController.animateToPage(activeIndex + 1),
                                child: Text('Next->',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: r(28.0))),
                              )),
                          SizedBox(height: r10),
                          ElevatedButton(
                            onPressed: () {
                              showUnitTargetCarousel = false;
                              selectTarget(activeIndex);
                            },
                            child: Text('Choice',
                                style: TextStyle(
                                    color: Colors.black, fontSize: r(28.0))),
                          ),
                        ])
                      : const SizedBox.shrink(),
                  // 攻撃をブロックするユニットを選ぶ
                  showDefenceUnitsCarousel == true
                      ? Column(children: <Widget>[
                          CarouselSlider.builder(
                            carouselController: cController,
                            options: CarouselOptions(
                                height: r(250),
                                aspectRatio: 14 / 9,
                                viewportFraction: 0.6, // 1.0:1つが全体に出る
                                initialPage: 0,
                                // enableInfiniteScroll: true,
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    activeIndex = index;
                                  });
                                }),
                            itemCount: yourDefendableUnitPositions.length,
                            itemBuilder: (context, index, realIndex) {
                              var target = yourDefendableUnitPositions[index];
                              var cardId = gameObject!
                                  .yourFieldUnit[(target).toString()];
                              return Image.asset(
                                '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_$cardId.jpeg',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          SizedBox(height: r10),
                          buildIndicator(yourDefendableUnitPositions.length),
                          SizedBox(height: r10),
                          SizedBox(
                              height: r35,
                              child: ElevatedButton(
                                onPressed: () =>
                                    cController.animateToPage(activeIndex + 1),
                                child: Text('Next->',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: r(28.0))),
                              )),
                          SizedBox(height: r10),
                          SizedBox(
                              height: r35,
                              child: ElevatedButton(
                                onPressed: () => block(activeIndex),
                                child: Text('Block',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: r(28.0))),
                              )),
                        ])
                      : const SizedBox.shrink(),
                  // 相手ユニット選択タイマー 兼 防御側タイマー
                  // (canUseIntercept == true || showUnitTargetCarousel == true) ||
                  showUnitTargetCarousel == true ||
                          (isBattling == true &&
                              yourDefendableUnitPositions.isNotEmpty &&
                              !(onBattlePosition != null &&
                                  gameObject!.opponentFieldUnit[
                                          onBattlePosition.toString()] ==
                                      '6'))
                      ? Center(
                          child: Padding(
                              padding: EdgeInsets.only(bottom: r(300.0)),
                              child: SizedBox(
                                  width: r(180.0),
                                  child: StreamBuilder<int>(
                                      stream: _timer.events.stream,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<int> snapshot) {
                                        return Visibility(
                                            visible: snapshot.data != null &&
                                                snapshot.data != 0,
                                            child: Center(
                                                child: Text(
                                              '0:0${snapshot.data.toString()}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: r(60.0)),
                                            )));
                                      }))))
                      : const SizedBox.shrink(),
                  // Load a Lottie file from your assets
                ]),
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
          floatingActionButton: StartButtons(gameProgressStatus,
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
                // バトルデータなし
                if (gameObject != null) {
                  // データがない = 10ターンが終わった可能性
                  if ((gameObject!.turn == 10 &&
                          gameObject!.yourLife < gameObject!.opponentLife) ||
                      (gameObject!.yourLife == 1 &&
                          gameObject!.yourLife < gameObject!.opponentLife)) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'You Lose...',
                      text: 'Try Again!',
                    );
                  } else if (gameObject!.turn == 10 &&
                      gameObject!.isFirstTurn == true &&
                      gameObject!.isFirst == true &&
                      gameObject!.yourLife <= gameObject!.opponentLife) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'You Lose...',
                      text: 'Try Again!',
                    );
                  }
                }
                // 内部データ初期化
                setState(() {
                  onChainYourFieldUnit = [];
                  onChainYourTriggerCards = [];
                  onChainYourTriggerCardsDisplay = [];
                  canOperate = false;
                  gameStarted = false;
                  gameObject = null;
                });
                attackStatusBloc.canAttackEventSink.add(BattleFinishedEvent());
                // setDataAndMarigan(data, null);
                break;
              case 'card-info':
                setCardInfo(cardInfo);
                break;
            }
          }, widget.enLocale, r, widget.isMobile, widget.needEyeCatch));
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // cController.dispose();
    // attackStatusBloc.dispose();
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

  Widget buildIndicator(int itemCount) => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: itemCount,
        onDotClicked: (index) {
          cController.animateToPage(index);
        },
        effect: const JumpingDotEffect(
          verticalOffset: 4.0,
          radius: 22.0,
          activeDotColor: Colors.orange,
          // dotColor: Colors.black12,
        ),
      );
}
