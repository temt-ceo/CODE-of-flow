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
  String savedGraphQLId = '';
  String previousEmitPlayer = '';
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
  final cController = CarouselController();
  int activeIndex = 0;
  bool showDefenceUnitsCarousel = false;
  bool showUnitTargetCarousel = false;
  int? opponentDefendPosition;
  List<int>? attackerUsedInterceptCard;
  List<int>? defenderUsedInterceptCard;
  List<int> attackerUsedCardIds = [];
  List<int> defenderUsedCardIds = [];
  VideoPlayerController? vController;
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
  List<int> timelyUsedTriggers = [];
  List<int> cannotDefendUnitPositions = [];
  bool selectTargetFlg = false;
  int reviewingTriggerCardPosition = 0;
  int? cardTriggerAbilityCase;
  bool? calledFieldUnitActionTrans;
  int? tapCardIndex;
  String? putCardOnFieldType;

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
        var ret = event.data;
        if (ret != null && savedGraphQLId != ret.id) {
          savedGraphQLId = ret.id;
          print('Player No. ${ret.playerId} => ${ret.type}');
          print(
              '*** Subscription event data received: (${ret.id}) ${event.data}');
          if (ret.type == 'player_matching' && playerId == ret.playerId) {
            String transactionId = ret.message.split(',TransactionID:')[1];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showFlash(
                  context: context,
                  duration: const Duration(seconds: 5),
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
          } else if (ret.type == 'player_matching' &&
              gameObject == null &&
              previousEmitPlayer != ret.playerId) {
            previousEmitPlayer = ret.playerId;
            showToast("No. ${ret.playerId} has entered in Alcana.");
          } else if (ret.type == 'put_card_on_the_field' &&
              gameObject != null) {
            var msg = jsonDecode(ret.message.split(',TransactionID:')[0]);
            // List<dynamic> から List<int> への変換
            for (var i = 0; i < msg['usedTriggers'].length; i++) {
              timelyUsedTriggers.add(msg['usedTriggers'][i]);
            }
            Future.delayed(const Duration(seconds: 4), () async {
              setState(() => timelyUsedTriggers = []);
            });
            if (gameObject != null &&
                (gameObject!.you.toString() == ret.playerId)) {
              setState(() {
                defaultTriggerCards = onChainYourTriggerCardsDisplay;
              });
            }

            if (msg['skillMessage'] != '') {
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
                          content: Text(msg['skillMessage'],
                              style: const TextStyle(fontSize: 20.0)),
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
          } else if (ret.type == 'turn_change' &&
              gameObject != null &&
              (gameObject!.you.toString() == ret.playerId ||
                  gameObject!.opponent.toString() == ret.playerId)) {
            isBattling = false;
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
              gameObject != null &&
              (gameObject!.opponent.toString() == ret.playerId)) {
            isBattling = true;
            _timer.countdownStart(7, () {
              isBattling = false;
              onBattlePosition = null;
              attackStatusBloc.canAttackEventSink.add(BattleFinishingEvent());
            });
            var msg = jsonDecode(ret.message.split(',TransactionID:')[0]);
            onBattlePosition = msg['arg1'];
            var skillTarget = msg['arg2'];
            var usedCardIds = msg['usedCardIds'];
            if (gameObject!.opponentFieldUnit[onBattlePosition] == 6) {
              // Valkyrie
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showFlash(
                    context: context,
                    duration: const Duration(seconds: 5),
                    builder: (context, controller) {
                      return Flash(
                        controller: controller,
                        position: FlashPosition.bottom,
                        child: FlashBar(
                          controller: controller,
                          content: Text(
                              'Valkyrie ${L10n.of(context)!.activatedAbility} Cannot Block!',
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
              return;
            }
            // used_intercept_position
            for (var i = 0; i < usedCardIds.length; i++) {
              if (usedCardIds[0] == 25) {
                // Judge
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showFlash(
                      context: context,
                      duration: const Duration(seconds: 5),
                      builder: (context, controller) {
                        return Flash(
                          controller: controller,
                          position: FlashPosition.bottom,
                          child: FlashBar(
                            controller: controller,
                            content: Text(
                                'Judge ${L10n.of(context)!.activatedEffect} Cannot Block!',
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
                return;
              }
            }
            showDefenceUnitsCarousel = true;
            String enemyAbility = '';
            if (gameObject!.opponentFieldUnit[onBattlePosition] == 2) {
              // Fighter
              enemyAbility = 'Fighter ${L10n.of(context)!.activatedAbility} ';
            } else if (gameObject!.opponentFieldUnit[onBattlePosition] == 3) {
              // Lancer
              enemyAbility = 'Lancer ${L10n.of(context)!.activatedAbility} ';
              var damagedCardId = gameObject!.yourFieldUnit[skillTarget];
              enemyAbility =
                  '$enemyAbility ${L10n.of(context)!.gotUnitDamage(getCardName(damagedCardId))}';
            } else if (gameObject!.opponentFieldUnit[onBattlePosition] == 7) {
              // Lilim
              enemyAbility = 'Lilim ${L10n.of(context)!.activatedAbility} ';
            }

            var usedInterceptPositions = msg['arg4'];
            // 攻撃時に使用したトリガーカード
            List<int> _defenderUsedInterceptCard = [];
            for (var i in usedInterceptPositions) {
              _defenderUsedInterceptCard.add(i);
            }
            setState(
                () => defenderUsedInterceptCard = _defenderUsedInterceptCard);
            isEnemyAttack = true;
            attackStatusBloc.canAttackEventSink.add(BattlingEvent());
            String toastMsg = L10n.of(context)!.opponentAttack;
            if (defenderUsedInterceptCard!.isNotEmpty) {
              toastMsg =
                  '$toastMsg ${L10n.of(context)!.opponentAttackTrigger(defenderUsedInterceptCard!.length)}';
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showFlash(
                  context: context,
                  duration: const Duration(seconds: 5),
                  builder: (context, controller) {
                    return Flash(
                      controller: controller,
                      position: FlashPosition.bottom,
                      child: FlashBar(
                        controller: controller,
                        content: Text('$enemyAbility $toastMsg',
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
            // === 敵の攻撃 ここまで ===
            // バトルの相手側の対応
          } else if (ret.type == 'battle_reaction' &&
              gameObject != null &&
              (gameObject!.opponent.toString() == ret.playerId ||
                  playerId == ret.playerId)) {
            isBattling = true;
            _timer.countdownStart(7, () {
              isBattling = false;
              attackStatusBloc.canAttackEventSink.add(CanNotUseTriggerEvent());
              attackStatusBloc.canAttackEventSink.add(BattleFinishingEvent());
            });
            attackStatusBloc.canAttackEventSink.add(BattlingEvent());
            var msg = jsonDecode(ret.message.split(',TransactionID:')[0]);
            bool enemyHasBlocked = false;
            // isEnemyAttackがnullの場合はfalseをセットする。
            if (isEnemyAttack == null) {
              enemyHasBlocked = true;
              isEnemyAttack = false;
            }
            // 敵のposition
            if (gameObject!.opponent.toString() == ret.playerId) {
              setState(() => opponentDefendPosition = msg['arg1']);
            }
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

            if (enemyHasBlocked &&
                gameObject!.opponent.toString() == ret.playerId) {
              String enemyAbility = '';
              if (gameObject!.opponentFieldUnit[opponentDefendPosition] == 9) {
                // Sohei
                enemyAbility =
                    'Sohei ${L10n.of(context)!.activatedAbility} - Defensive Specialization! -';
              } else if (gameObject!
                      .opponentFieldUnit[opponentDefendPosition] ==
                  15) {
                // Roin
                enemyAbility =
                    'Roin ${L10n.of(context)!.activatedAbility} - Defensive Specialization! -';
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showFlash(
                    context: context,
                    duration: const Duration(seconds: 5),
                    builder: (context, controller) {
                      return Flash(
                        controller: controller,
                        position: FlashPosition.bottom,
                        child: FlashBar(
                          controller: controller,
                          title: Text(L10n.of(context)!.opponentBlocking,
                              style: const TextStyle(fontSize: 24.0)),
                          content: Text(
                              canUseIntercept
                                  ? '$enemyAbility ${L10n.of(context)!.interceptAbailable}'
                                  : enemyAbility,
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
            } else if (canUseIntercept) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showFlash(
                    context: context,
                    duration: const Duration(seconds: 5),
                    builder: (context, controller) {
                      return Flash(
                        controller: controller,
                        position: FlashPosition.bottom,
                        child: FlashBar(
                          controller: controller,
                          content: Text(L10n.of(context)!.interceptAbailable,
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
            }
          } else if (ret.type == 'defence_action' &&
              gameObject != null &&
              (gameObject!.you.toString() == ret.playerId ||
                  gameObject!.opponent.toString() == ret.playerId)) {
            isBattling = false;
            // バトルパラメータをnullにする
            setState(() {
              onBattlePosition = null;
              isEnemyAttack = null;
              showDefenceUnitsCarousel = false;
              opponentDefendPosition = null;
              attackerUsedInterceptCard = null;
              defenderUsedInterceptCard = null;
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
      defenderUsedInterceptCard = [];
      canUseIntercept = false;
      attackerUsedCardIds =
          []; // これはブロックチェーンから取ってくるしかない。相手のトリガーゾーンに何が入っているかは相手の攻撃アクション時にはわからない。
      defenderUsedCardIds = [];
    });
    // Battle Reaction
    showGameLoading();
    var message = DefenceActionModel(
        opponentDefendPosition!,
        attackerUsedInterceptCard == null ? [] : attackerUsedInterceptCard!,
        defenderUsedInterceptCard == null ? [] : defenderUsedInterceptCard!,
        attackerUsedCardIds,
        defenderUsedCardIds);
    await apiService.saveGameServerProcess(
        'battle_reaction', jsonEncode(message), gameObject!.you.toString());
    closeGameLoading();
    debugPrint('== transaction published ==');
  }

  /*
  **  インターセプトカード使用処理(バトル時)
  */
  void useInterceptCardForBattle(int cardId, int activeIndex) async {
    // 攻撃時もしくは防御時
    if (isEnemyAttack != null) {
      if (isEnemyAttack == true) {
        // ２度押ししていないかチェック
        if (!defenderUsedInterceptCard!
            .any((element) => element == activeIndex)) {
          setState(() {
            defenderUsedInterceptCard!.add(activeIndex);
            defenderUsedCardIds.add(cardId);
          });
        }
      } else {
        // ２度押ししていないかチェック
        if (!attackerUsedInterceptCard!
            .any((element) => element == activeIndex)) {
          setState(() {
            attackerUsedInterceptCard!.add(activeIndex);
            attackerUsedCardIds.add(cardId);
          });
        }
      }
      // Battle Reaction
      showGameLoading();
      var message = DefenceActionModel(
          opponentDefendPosition!,
          attackerUsedInterceptCard!,
          defenderUsedInterceptCard!,
          attackerUsedCardIds,
          defenderUsedCardIds);
      await apiService.saveGameServerProcess(
          'battle_reaction', jsonEncode(message), gameObject!.you.toString());
      closeGameLoading();
      onChainYourTriggerCards[activeIndex] = null;
      onChainYourTriggerCardsDisplay[activeIndex] = null;
      debugPrint('== transaction published ==');
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showFlash(
                context: context,
                duration: const Duration(seconds: 5),
                builder: (context, controller) {
                  return Flash(
                    controller: controller,
                    position: FlashPosition.bottom,
                    child: FlashBar(
                      controller: controller,
                      content: Text(L10n.of(context)!.gotDamage,
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
        } else if (data.opponentLife < gameObject!.opponentLife) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showFlash(
                context: context,
                duration: const Duration(seconds: 5),
                builder: (context, controller) {
                  return Flash(
                    controller: controller,
                    position: FlashPosition.bottom,
                    child: FlashBar(
                      controller: controller,
                      content: Text(L10n.of(context)!.giveDamage,
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
        } else if ((data.yourAttackingCard == null &&
                gameObject!.yourAttackingCard != null) ||
            (data.enemyAttackingCard == null &&
                gameObject!.enemyAttackingCard != null)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showFlash(
                context: context,
                duration: const Duration(seconds: 5),
                builder: (context, controller) {
                  return Flash(
                    controller: controller,
                    position: FlashPosition.bottom,
                    child: FlashBar(
                      controller: controller,
                      content: Text(L10n.of(context)!.battleSettled,
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
        }
        // 存在していたユニットが消えていたら攻撃でやられている
        List<dynamic> _units = [];
        bool unitDecreased = false;
        for (int i = 1; i <= 5; i++) {
          if (gameObject!.yourFieldUnit[i.toString()] != null &&
              data.yourFieldUnit[i.toString()] == null) {
            _units.add(null);
            unitDecreased = true;
          } else if (onChainYourFieldUnit.length >= i) {
            _units.add(onChainYourFieldUnit[i - 1]);
          }
        }
        if (unitDecreased == true) {
          setState(() {
            onChainYourFieldUnit = _units;
            defaultDropedList = _units.isEmpty ? [null] : _units;
          });
        }
        // 存在したトリガーカードが消えていたら攻撃でロストされている
        List<int?> _triggerCards = [];
        bool triggerDecreased = false;
        for (int i = 1; i <= 4; i++) {
          if (gameObject!.yourTriggerCards[i.toString()] != null &&
              data.yourTriggerCards[i.toString()] == null) {
            triggerDecreased = true;
            _triggerCards.add(null);
          } else if (onChainYourTriggerCards.length >= i) {
            _triggerCards.add(onChainYourTriggerCards[i - 1]);
          }
        }
        if (triggerDecreased == true) {
          setState(() {
            onChainYourTriggerCards = _triggerCards;
            onChainYourTriggerCardsDisplay = _triggerCards;
            defaultTriggerCards =
                _triggerCards.isEmpty ? [null] : _triggerCards;
          });
          print(defaultTriggerCards);
        }
        //
        // 新しいカードをドローしているケース
        if (data!.newlyDrawedCards.isNotEmpty) {
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
    } else {
      // 通常時はこちら
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
        }
        setState(() {
          handCards = _hand;
          onChainHandCards = gameObject!.yourHand;
          onChainYourFieldUnit = _units;
          onChainYourTriggerCards = _triggerCards;
          onChainYourTriggerCardsDisplay = _triggerCards;
          // ターンチェンジ後に空になっている場合は空であることをコンポーネントに伝える必要がある
          defaultDropedList = _units.isEmpty ? [null] : _units;
          defaultTriggerCards = _triggerCards.isEmpty ? [null] : _triggerCards;
        });
      } else {
        setState(() {
          // フイールドユニットのブロックチェーンデータとの調整(こうしないとプレイヤーが操作した動きがリセットされる為)
          defaultDropedList = [];
          defaultTriggerCards = [];
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
            attackStatusBloc.canAttackEventSink.add(AttackNotAllowedEvent());
          }
        }
      } else {
        attackStatusBloc.canAttackEventSink.add(AttackNotAllowedEvent());
      }
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
      for (int i = 0; i < 4; i++) {
        if (onChainYourTriggerCards[i] == null) {
          onChainYourTriggerCards[i] = cardId;
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
    if (mounted) {
      setState(() {
        gameObject!.yourCp = gameObject!.yourCp -
            int.parse(cardInfos[cardId.toString()]['cost']);
      });
    }

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
          if (skill['type_1'] == '1' &&
              gameObject!.opponentFieldUnitLength > 0) {
            if (cardTriggerAbilityCase == 1) {
              // Lilim
              skillMessage =
                  'Lilim ${L10n.of(context)!.activatedAbility} - Dmage One Unit! -';
              showUnitTargetCarousel = true;
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
              _timer.countdownStart(6, () {
                showUnitTargetCarousel = false;
                selectTarget(0); // 左端を強制選択
              });
              return;
            }
          } else if (skill['type_1'] == '5' &&
              gameObject!.opponentFieldUnitLength > 0) {
            if (cardTriggerAbilityCase == 1) {
              // Allie
              for (var i = 1; i <= gameObject!.opponentFieldUnitLength; i++) {
                if (gameObject!.opponentFieldUnitAction[i.toString()] == '1' ||
                    gameObject!.opponentFieldUnitAction[i.toString()] == '2') {
                  cannotDefendUnitPositions.add(i);
                }
              }
              if (cannotDefendUnitPositions.isNotEmpty) {
                skillMessage =
                    'Allie ${L10n.of(context)!.activatedAbility} - Remove Action Right! -';
                showUnitTargetCarousel = true;
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
            for (var i = 1; i <= gameObject!.opponentFieldUnitLength; i++) {
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
            var unit = cardId == 2 ? 'Fighter' : 'Lilim';
            var ability = cardId == 2
                ? '- Augmented Power! -'
                : (gameObject!.opponentTriggerCards > 0
                    ? '- Trigger Card Lost! -'
                    : '');
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

      if (calledFieldUnitActionTrans == null) {
        reviewTriggerCards();
      } else {
        if (cardTriggerAbilityCase == 2) {
          // カードが攻撃に出た時の能力
          setState(() {
            attackSignalPosition = tapCardIndex;
            actedCardPosition = tapCardIndex;
          });
        } else {
          // カードがフィールドに出た時
          callEnterTheFieldTransaction();
        }
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
        print(1);
        if (skill['trigger_1'] == cardTriggerAbilityCase.toString()) {
          print(2);
          if (getCardCategory(cardId.toString()) == '2') {
            print(3);
            /////////////////////////////
            // インターセプト (Breaker,Imperiale,Photon,Signal for assault)
            /////////////////////////////
            if (putCardOnFieldType != null &&
                (putCardOnFieldType == getCardType(cardId.toString()) ||
                    getCardType(cardId.toString()) == '4')) {
              canUseIntercept = true;
            } else {
              print(4);
              for (String position in ['1', '2', '3', '4', '5']) {
                if (gameObject!.yourFieldUnit[position] != null) {
                  if (getCardType(gameObject!.yourFieldUnit[position]) ==
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
            print(5);
            if (canUseIntercept) {
              print(6);
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
              if (gameObject!.opponentFieldUnitLength > 0) {
                // Canon
                skillMessage = skillMessage != ''
                    ? '$skillMessage \nTRIGGER Canon ${L10n.of(context)!.activatedEffect} - Damage One Unit! -'
                    : 'TRIGGER Canon ${L10n.of(context)!.activatedEffect} - Damage One Unit! -';
                if (enemySkillTarget == 0) {
                  showUnitTargetCarousel = true;
                  _timer.countdownStart(6, () {
                    showUnitTargetCarousel = false;
                    selectTarget(0); // 左端を強制選択
                  });
                }
                onChainYourTriggerCardsDisplay[
                    reviewingTriggerCardPosition - 1] = null;
                usedTriggers.add(cardId);
                usedInterceptCardPosition.add(reviewingTriggerCardPosition);
              }
            } else if (cardId == 17) {
              // Drive
              skillMessage = skillMessage != ''
                  ? '$skillMessage \nTRIGGER Drive ${L10n.of(context)!.activatedEffect} - Augmented Power! -'
                  : 'TRIGGER Drive ${L10n.of(context)!.activatedEffect} - Augmented Power! -';
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
          }
        }
      }
    }
    reviewTriggerCards();
  }

  void reviewInterceptCards() {
    if (canUseIntercept == true) {
      showFlash(
          context: context,
          duration: const Duration(seconds: 5),
          builder: (context, controller) {
            return Flash(
              controller: controller,
              position: FlashPosition.bottom,
              child: FlashBar(
                controller: controller,
                content: Text(L10n.of(context)!.interceptAbailable,
                    style: const TextStyle(fontSize: 24.0)),
                indicatorColor: Colors.blue,
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.blue,
                ),
              ),
            );
          });

      _timer.countdownStart(6, () async {
        canUseIntercept = false;
        attackStatusBloc.canAttackEventSink.add(CanNotUseTriggerEvent());
        if (cardTriggerAbilityCase == 2) {
          // カードが攻撃に出た時の能力
          setState(() {
            attackSignalPosition = tapCardIndex;
            actedCardPosition = tapCardIndex;
          });
        } else if (cardTriggerAbilityCase == 1) {
          // カードがフィールドに出た時
          callEnterTheFieldTransaction();
        }
      });
    } else {
      if (cardTriggerAbilityCase == 2) {
        // カードが攻撃に出た時の能力の場合
        if (enemySkillTarget == 0) {
          calledFieldUnitActionTrans = false;
          for (var i = 0; i < usedTriggers.length; i++) {
            if (usedTriggers[i] == 22) {
              // Dainsleif
              skillMessage =
                  'Dainsleif ${L10n.of(context)!.activatedAbility} - Trigger Card Lost! -';
              return;
            } else if (usedTriggers[i] == 24) {
              // Titan's Lock
              var leftMost = 0;
              for (var i = 1; i <= gameObject!.opponentFieldUnitLength; i++) {
                if (gameObject!.opponentFieldUnitAction[i.toString()] != '0') {
                  if (leftMost == 0) {
                    leftMost = 1;
                  }
                  cannotDefendUnitPositions.add(i);
                }
              }
              if (cannotDefendUnitPositions.isNotEmpty) {
                skillMessage =
                    "Titan's Lock ${L10n.of(context)!.activatedAbility} - Remove Action Right! -";
                showUnitTargetCarousel = true;
                _timer.countdownStart(6, () {
                  showUnitTargetCarousel = false;
                  selectTarget(leftMost - 1); // 左端を強制選択
                });
                return;
              }
            } else if (usedTriggers[i] == 25) {
              // Judge
              skillMessage =
                  'Judge ${L10n.of(context)!.activatedAbility} Remove Action Rights!';
              return;
            }
          }
        }
        if (calledFieldUnitActionTrans == null ||
            calledFieldUnitActionTrans == false) {
          calledFieldUnitActionTrans = true;
        }
        setState(() {
          attackSignalPosition = tapCardIndex;
          actedCardPosition = tapCardIndex;
          enemySkillTargetPosition = enemySkillTarget;
        });
        // カードが攻撃に出た時の能力ここまで
      } else if (cardTriggerAbilityCase == 1) {
        // カードがフィールドに出た時
        callEnterTheFieldTransaction();
      }
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
            _timer.countdownStart(6, () {
              showUnitTargetCarousel = false;
              selectTarget(0); // 左端を強制選択
            });
          }
          return;
        } else if (usedTriggers[i] == 23) {
          // Photon
          for (var i = 1; i <= gameObject!.opponentFieldUnitLength; i++) {
            if (gameObject!.opponentFieldUnitAction[i.toString()] == '0') {
              cannotDefendUnitPositions.add(i);
            }
          }
          if (cannotDefendUnitPositions.isNotEmpty) {
            skillMessage =
                'Photon ${L10n.of(context)!.activatedAbility} - Damage Acted-up Unit! -';
            showUnitTargetCarousel = true;
            _timer.countdownStart(6, () {
              showUnitTargetCarousel = false;
              selectTarget(0); // 左端を強制選択
            });
            return;
          }
        }
      }
    }
    if (calledFieldUnitActionTrans == null ||
        calledFieldUnitActionTrans == false) {
      calledFieldUnitActionTrans = true;

      // showGameLoading();
      // 使用可能なインターセプトを初期化
      canUseIntercept = false;
      // Call GraphQL method.
      var message = PutCardModel(fieldUnit, enemySkillTarget, triggerCards,
          usedInterceptCardPosition, skillMessage, usedTriggers);
      await apiService.saveGameServerProcess('put_card_on_the_field',
          jsonEncode(message), gameObject!.you.toString());
      // closeGameLoading();
      debugPrint('transaction published');
    }
  }

  ///////////////////////
  // カードのタップ時処理 //
  ///////////////////////
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
      if (gameObject!.yourFieldUnitAction[(index + 1).toString()] == '2') {
        // 使用可能なインターセプトを初期化
        canUseIntercept = false;
        reviewingTriggerCardPosition = 0;
        calledFieldUnitActionTrans = null;
        tapCardIndex = index;
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
        reviewFieldUnitAbility(cardId);
      }
    } else if (message == 'use') {
      print('isEnemyAttack $isEnemyAttack');
      if (isEnemyAttack == true || isEnemyAttack == false) {
        useInterceptCardForBattle(cardId, index);
      } else {
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
      // showGameLoading();
      var ret = await apiService.saveGameServerProcess(
          'game_start', jsonEncode(handCards), gameObject!.you.toString());
      // closeGameLoading();
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
                    attackerUsedInterceptCard,
                    defenderUsedInterceptCard,
                    actedCardPosition,
                    cardInfos,
                    onChainYourTriggerCards,
                    isEnemyAttack,
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
                            defaultTriggerCards,
                            onChainYourTriggerCards,
                            const [],
                            const [],
                            null,
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
                            onChainYourTriggerCards,
                            usedInterceptCardPosition,
                            usedTriggers,
                            enemySkillTargetPosition,
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
                              return Visibility(
                                  visible: snapshot.data != 0,
                                  child: Center(
                                      child: Text(
                                    '0:0${snapshot.data.toString()}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: r(42.0)),
                                  )));
                            })))),
            Visibility(
                visible: mariganClickCount < 5 && gameProgressStatus == 1,
                child: Positioned(
                    left: r(900),
                    top: r(500),
                    child: StreamBuilder<int>(
                        stream: _timer.events.stream,
                        builder: (BuildContext context,
                            AsyncSnapshot<int> snapshot) {
                          return Visibility(
                              visible: snapshot.data != 0,
                              child: SizedBox(
                                  width: snapshot.data != 0 ? r(100.0) : 0.0,
                                  child: FloatingActionButton(
                                      backgroundColor: Colors.transparent,
                                      onPressed: () {
                                        if (mariganClickCount < 5) {
                                          setState(() => mariganClickCount =
                                              mariganClickCount + 1);
                                          setState(() => handCards =
                                              mariganCardIdList[
                                                  mariganClickCount]);
                                        } else {
                                          // 6回目は1回目をセット
                                          setState(() =>
                                              handCards = mariganCardIdList[0]);
                                        }
                                      },
                                      tooltip: 'Redraw',
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        child: Image.asset(
                                          '${imagePath}button/redo.png',
                                          fit: BoxFit
                                              .cover, //prefer cover over fill
                                        ),
                                      ))));
                        }))),
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
              left: r(470.0),
              top: r(90.0),
              child: Container(
                width: r(125.0),
                height: r(45.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('${imagePath}trigger/trigger.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
              left: r(648.0),
              top: r(160.0),
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
                top: r(163.0),
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
                top: r(185.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['1'] != null
                        ? (gameObject!.opponentFieldUnitAction['1'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['1'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            gameObject!.opponentFiledUnitBps['1'].toString()
                        : '',
                    style: TextStyle(
                      color: gameObject != null &&
                              gameObject!
                                      .opponentFieldUnitBpAmountOfChange['1'] !=
                                  null
                          ? (int.parse(gameObject!
                                      .opponentFieldUnitBpAmountOfChange['1']) >
                                  0
                              ? Colors.blue
                              : Colors.red)
                          : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(783.0),
              top: r(160.0),
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
                top: r(163.0),
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
                top: r(185.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['2'] != null
                        ? (gameObject!.opponentFieldUnitAction['2'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['2'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            gameObject!.opponentFiledUnitBps['2'].toString()
                        : '',
                    style: TextStyle(
                      color: gameObject != null &&
                              gameObject!
                                      .opponentFieldUnitBpAmountOfChange['2'] !=
                                  null
                          ? (int.parse(gameObject!
                                      .opponentFieldUnitBpAmountOfChange['2']) >
                                  0
                              ? Colors.blue
                              : Colors.red)
                          : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(918.0),
              top: r(160.0),
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
                top: r(163.0),
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
                top: r(185.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['3'] != null
                        ? (gameObject!.opponentFieldUnitAction['3'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['3'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            gameObject!.opponentFiledUnitBps['3'].toString()
                        : '',
                    style: TextStyle(
                      color: gameObject != null &&
                              gameObject!
                                      .opponentFieldUnitBpAmountOfChange['3'] !=
                                  null
                          ? (int.parse(gameObject!
                                      .opponentFieldUnitBpAmountOfChange['3']) >
                                  0
                              ? Colors.blue
                              : Colors.red)
                          : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1053.0),
              top: r(160.0),
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
                top: r(163.0),
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
                top: r(185.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['4'] != null
                        ? (gameObject!.opponentFieldUnitAction['4'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['4'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            gameObject!.opponentFiledUnitBps['4'].toString()
                        : '',
                    style: TextStyle(
                      color: gameObject != null &&
                              gameObject!
                                      .opponentFieldUnitBpAmountOfChange['4'] !=
                                  null
                          ? (int.parse(gameObject!
                                      .opponentFieldUnitBpAmountOfChange['4']) >
                                  0
                              ? Colors.blue
                              : Colors.red)
                          : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1188.0),
              top: r(160.0),
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
                top: r(163.0),
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
                top: r(185.0),
                width: r(100.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['5'] != null
                        ? (gameObject!.opponentFieldUnitAction['5'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['5'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            gameObject!.opponentFiledUnitBps['5'].toString()
                        : '',
                    style: TextStyle(
                      color: gameObject != null &&
                              gameObject!
                                      .opponentFieldUnitBpAmountOfChange['5'] !=
                                  null
                          ? (int.parse(gameObject!
                                      .opponentFieldUnitBpAmountOfChange['5']) >
                                  0
                              ? Colors.blue
                              : Colors.red)
                          : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(648.0),
              top: r(386.0),
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
                top: r(389.0),
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
                top: r(411.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['1'] != null
                        ? (gameObject!.yourFieldUnitAction['1'] == '1' ||
                                    gameObject!.yourFieldUnitAction['1'] == '2'
                                ? '🛡️'
                                : '　') +
                            gameObject!.yourFiledUnitBps['1'].toString()
                        : '',
                    style: TextStyle(
                      color: gameObject != null &&
                              gameObject!.yourFieldUnitBpAmountOfChange['1'] !=
                                  null
                          ? (int.parse(gameObject!
                                      .yourFieldUnitBpAmountOfChange['1']) >
                                  0
                              ? Colors.blue
                              : Colors.red)
                          : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(783.0),
              top: r(386.0),
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
                top: r(389.0),
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
                top: r(411.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['2'] != null
                        ? (gameObject!.yourFieldUnitAction['2'] == '1' ||
                                    gameObject!.yourFieldUnitAction['2'] == '2'
                                ? '🛡️'
                                : '　') +
                            gameObject!.yourFiledUnitBps['2'].toString()
                        : '',
                    style: TextStyle(
                      color: gameObject != null &&
                              gameObject!.yourFieldUnitBpAmountOfChange['2'] !=
                                  null
                          ? (int.parse(gameObject!
                                      .yourFieldUnitBpAmountOfChange['2']) >
                                  0
                              ? Colors.blue
                              : Colors.red)
                          : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(918.0),
              top: r(386.0),
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
                top: r(389.0),
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
                top: r(411.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['3'] != null
                        ? (gameObject!.yourFieldUnitAction['3'] == '1' ||
                                    gameObject!.yourFieldUnitAction['3'] == '2'
                                ? '🛡️'
                                : '　') +
                            gameObject!.yourFiledUnitBps['3'].toString()
                        : '',
                    style: TextStyle(
                      color: gameObject != null &&
                              gameObject!.yourFieldUnitBpAmountOfChange['3'] !=
                                  null
                          ? (int.parse(gameObject!
                                      .yourFieldUnitBpAmountOfChange['3']) >
                                  0
                              ? Colors.blue
                              : Colors.red)
                          : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1053.0),
              top: r(386.0),
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
                top: r(389.0),
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
                top: r(411.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['4'] != null
                        ? (gameObject!.yourFieldUnitAction['4'] == '1' ||
                                    gameObject!.yourFieldUnitAction['4'] == '2'
                                ? '🛡️'
                                : '　') +
                            gameObject!.yourFiledUnitBps['4'].toString()
                        : '',
                    style: TextStyle(
                      color: gameObject != null &&
                              gameObject!.yourFieldUnitBpAmountOfChange['4'] !=
                                  null
                          ? (int.parse(gameObject!
                                      .yourFieldUnitBpAmountOfChange['4']) >
                                  0
                              ? Colors.blue
                              : Colors.red)
                          : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1188.0),
              top: r(386.0),
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
                top: r(389.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['5'] != null
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
                left: r(1190.0),
                top: r(411.0),
                width: r(100.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['4'] != null
                        ? (gameObject!.yourFieldUnitAction['5'] == '1' ||
                                    gameObject!.yourFieldUnitAction['5x'] == '2'
                                ? '🛡️'
                                : '　') +
                            gameObject!.yourFiledUnitBps['5'].toString()
                        : '',
                    style: TextStyle(
                      color: gameObject != null &&
                              gameObject!.yourFieldUnitBpAmountOfChange['5'] !=
                                  null
                          ? (int.parse(gameObject!
                                      .yourFieldUnitBpAmountOfChange['5']) >
                                  0
                              ? Colors.blue
                              : Colors.red)
                          : Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Choose target unit
            Visibility(
                visible: showUnitTargetCarousel == true,
                child: Column(children: <Widget>[
                  CarouselSlider.builder(
                    carouselController: cController,
                    options: CarouselOptions(
                        height: r(450),
                        // aspectRatio: 9 / 9,
                        viewportFraction: 0.7, // 1.0:1つが全体に出る
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
                        : (cannotDefendUnitPositions.isNotEmpty
                            ? cannotDefendUnitPositions.length
                            : gameObject!.opponentFieldUnitLength),
                    itemBuilder: (context, index, realIndex) {
                      // 行動済みのみ
                      if (cannotDefendUnitPositions.isNotEmpty) {
                        var target = cannotDefendUnitPositions[index];
                        var cardId =
                            gameObject!.opponentFieldUnit[(target).toString()];
                        return Image.asset(
                          '${imagePath}unit/card_$cardId.jpeg',
                          fit: BoxFit.cover,
                        );
                      } else {
                        // 全体から
                        var cardId = gameObject!
                            .opponentFieldUnit[(index + 1).toString()];
                        return Image.asset(
                          '${imagePath}unit/card_$cardId.jpeg',
                          fit: BoxFit.cover,
                        );
                      }
                    },
                  ),
                  SizedBox(height: r(20.0)),
                  buildIndicator(),
                  SizedBox(
                      width: r(240.0),
                      height: r(100.0),
                      child: ElevatedButton(
                        onPressed: () {
                          showUnitTargetCarousel = false;
                          selectTarget(activeIndex);
                        },
                        child: const Text('Choice',
                            style: TextStyle(fontSize: 24.0)),
                      )),
                ])),
            Visibility(
                visible: showDefenceUnitsCarousel == true,
                child: Column(children: <Widget>[
                  CarouselSlider.builder(
                    carouselController: cController,
                    options: CarouselOptions(
                        height: r(450),
                        // aspectRatio: 9 / 9,
                        viewportFraction: 0.7, // 1.0:1つが全体に出る
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
                  SizedBox(height: r(20.0)),
                  buildIndicator(),
                  SizedBox(
                      width: r(240.0),
                      height: r(100.0),
                      child: ElevatedButton(
                        onPressed: () => block(activeIndex),
                        child: const Text('Block',
                            style: TextStyle(fontSize: 24.0)),
                      )),
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
              visible: gameObject != null &&
                  ((isEnemyAttack == true && onBattlePosition != null) ||
                      (isEnemyAttack == false &&
                          opponentDefendPosition != null)),
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
                                      opponentDefendPosition.toString()] !=
                                  null
                              ? '${imagePath}unit/card_${gameObject!.opponentFieldUnit[opponentDefendPosition.toString()]}.jpeg'
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
            // 攻撃以外の時に、使用した敵のトリガー/インターセプトカード
            Visibility(
              visible: gameObject != null && timelyUsedTriggers.isNotEmpty,
              child: Positioned(
                  right: r(720.0),
                  top: r(90.0),
                  child: Row(
                    children: [
                      for (var cardId in attackerUsedCardIds)
                        GFImageOverlay(
                            width: r(200.0),
                            height: r(300.0),
                            shape: BoxShape.rectangle,
                            image: AssetImage(gameObject == null
                                ? ''
                                : '${imagePath}unit/card_${cardId.toString()}.jpeg')),
                    ],
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
                      ],
                    ))),
            Visibility(
                visible: isBattling == true,
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(bottom: r(50.0)),
                        child: SizedBox(
                            width: r(180.0),
                            child: StreamBuilder<int>(
                                stream: _timer.events.stream,
                                builder: (BuildContext context,
                                    AsyncSnapshot<int> snapshot) {
                                  return Center(
                                      child: Text(
                                    '0:0${snapshot.data.toString()}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: r(60.0)),
                                  ));
                                }))))),
            Visibility(
                visible:
                    canUseIntercept == true || showUnitTargetCarousel == true,
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(bottom: r(250.0)),
                        child: SizedBox(
                            width: r(180.0),
                            child: StreamBuilder<int>(
                                stream: _timer.events.stream,
                                builder: (BuildContext context,
                                    AsyncSnapshot<int> snapshot) {
                                  return Center(
                                      child: Text(
                                    '0:0${snapshot.data.toString()}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: r(60.0)),
                                  ));
                                }))))),
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
                    // バトルデータなし
                    if (gameObject != null) {
                      print('You Lose?? $gameObject');
                      // データがない = 10ターンが終わった可能性
                      if (gameObject!.turn == 10 &&
                          gameObject!.isFirstTurn == false) {
                        if (gameObject!.yourLife < gameObject!.opponentLife ||
                            (gameObject!.isFirst &&
                                gameObject!.yourLife ==
                                    gameObject!.opponentLife)) {
                          print('You Lose...');
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: 'You Lose...',
                            text: 'Try Again!',
                          );
                        }
                      }
                    }
                    // 内部データ初期化
                    setState(() {
                      onChainYourTriggerCards = [];
                      onChainYourTriggerCardsDisplay = [];
                      canOperate = true;
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
