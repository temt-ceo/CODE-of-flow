@JS()
library index;

import 'dart:async';
import 'dart:convert';
import 'dart:js_util';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:js/js.dart';
import 'package:quickalert/quickalert.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:CodeOfFlow/services/api_service.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/components/timerComponent.dart';
import 'package:CodeOfFlow/components/expandableFAB.dart';
import 'package:CodeOfFlow/components/fabActionButton.dart';

const envFlavor = String.fromEnvironment('flavor');

@JS('authenticate')
external void authenticate();

@JS('unauthenticate')
external void unauthenticate();

@JS('subscribe')
external void subscribe(dynamic user);

@JS('createPlayer')
external void createPlayer(String? name);

@JS('buyCyberEN')
external void buyCyberEN();

@JS('getAddr')
external String? getAddr(dynamic user);

@JS('isRegistered')
external dynamic isRegistered(String? address);

@JS('getCurrentStatus')
external dynamic getCurrentStatus(String? address);

@JS('getMariganCards')
external dynamic getMariganCards(String? address, int playerId);

@JS('getBalance')
external dynamic getBalance(String? address, int? playerId);

@JS('getPlayerUUId')
external String? getPlayerUUId(dynamic player);

@JS('getPlayerId')
external String? getPlayerId(dynamic player);

@JS('getPlayerName')
external String? getPlayerName(dynamic player);

@JS('getCardInfo')
external dynamic getCardInfo();

@JS('getPlayerDeck')
external dynamic getPlayerDeck(String? address, int playerId);

@JS('getStarterDeck')
external dynamic getStarterDeck();

@JS('jsonToString')
external String jsonToString(dynamic obj);

typedef void StringCallback(String val, dynamic userDeck, dynamic cardInfo);
typedef double ResponsiveSizeChangeFunction(double data);

class DeckButtons extends StatefulWidget {
  int gameProgressStatus;
  final List<dynamic> savedDeck;
  final ResponsiveSizeChangeFunction r;
  final bool isMobile;
  final StringCallback callback;

  DeckButtons(this.gameProgressStatus, this.savedDeck, this.r, this.isMobile,
      this.callback);

  @override
  DeckButtonsState createState() => DeckButtonsState();
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

class DeckButtonsState extends State<DeckButtons> {
  final nameController = TextEditingController();
  APIService apiService = APIService();
  WalletUser walletUser = WalletUser('');
  PlayerResource player = PlayerResource('', '', '');
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  bool showBottomSheet = false;
  bool showBottomSheet2 = false;
  bool onTyping = false;
  bool onClickButton = false;
  bool gameStarted = false;
  double imagePosition = 0.0;
  double? balance;
  int? cyberEnergy;
  String yourScore = '';
  String enemyName = '';
  String enemyScore = '';
  BuildContext? dcontext1;
  BuildContext? dcontext2;
  BuildContext? loadingContext;
  bool showCarousel = false;
  bool showCarousel2 = false;
  int activeIndex = 0;
  dynamic cardList;
  final cController = CarouselController();

  late StreamController<bool> _wait;

  dynamic timerObj = null;
  @override
  void initState() {
    super.initState();
    _wait = StreamController<bool>();
    // setInterval by every 2 second
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      timerObj = timer;
      if (walletUser.addr == '') {
        debugPrint('Not Login.');
      }
    });

    // カード情報取得
    getCardInfos();
  }

  void getCardInfos() async {
    // カード情報取得
    dynamic cardInfo = await promiseToFuture(getCardInfo());
    var objStr = jsonToString(cardInfo);
    var objJs = jsonDecode(objStr);
    setState(() {
      cardList = objJs;
    });
    widget.callback('card-info', null, objJs);
  }

  @override
  void dispose() {
    super.dispose();
    if (timerObj != null) {
      timerObj.cancel();
    }
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
      var userDeck = await promiseToFuture(
          getPlayerDeck(walletUser.addr, int.parse(playerId!)));
      widget.callback('player-deck', userDeck, null);
    } else {
      debugPrint('Not Imporing.');
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

  Future<void> saveUserDeck() async {
    if (widget.savedDeck.length == 30) {
      if (widget.isMobile == true) {
        showGameLoading();
        // Call GraphQL method.
        apiService.saveGameServerProcess(
            'save_deck', jsonEncode(widget.savedDeck), player.playerId);
        await Future.delayed(const Duration(seconds: 6));
        closeGameLoading();
        showAlertWindow('success');
      } else {
        showGameLoading();
        // Call GraphQL method.
        await apiService.saveGameServerProcess(
            'save_deck', jsonEncode(widget.savedDeck), player.playerId);
        await Future.delayed(const Duration(seconds: 3));
        closeGameLoading();
        showAlertWindow('success');
      }
    } else {
      showAlertWindow('error');
    }
  }

  Future<void> resetUserDeck() async {
    showGameLoading();
    var userDeck = await promiseToFuture(
        getPlayerDeck(walletUser.addr, int.parse(player.playerId!)));
    widget.callback('player-deck', userDeck, null);
    closeGameLoading();
  }

  void showAlertWindow(String type) {
    if (type == 'success') {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'Your deck is successfully saved!',
        text: '',
      );
    } else if (type == 'error') {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Your Deck is not 30 cards',
        text: '',
      );
    }
  }

  void countdown() {
    var timerComponent = TimerComponent();
    timerComponent.countdownStart(60, null);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (builderContext) {
          dcontext1 = builderContext;
          return StreamBuilder<int>(
              stream: timerComponent.events.stream,
              builder:
                  (BuildContext builderContext, AsyncSnapshot<int> snapshot) {
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

  void signout() {
    unauthenticate();
    setState(() => walletUser = WalletUser(''));
    setState(() => player = PlayerResource('', '', ''));
    setState(() => showBottomSheet = false);
  }

  @override
  Widget build(BuildContext context) {
    subscribe(allowInterop(setupWallet));

    return Stack(children: <Widget>[
      Positioned(
        left: 10.0,
        top: 0,
        child: Text(
          'Deck Editor',
          style: TextStyle(color: Colors.lightGreen, fontSize: widget.r(32.0)),
        ),
      ),
      Visibility(
          visible: cyberEnergy != null,
          child: Positioned(
            left: widget.r(75),
            top: widget.r(32),
            child: SizedBox(
                width: widget.r(300.0),
                child: Row(children: <Widget>[
                  Text(
                    'EN:  ',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 32, 243, 102),
                        fontSize: widget.r(16.0)),
                  ),
                  Text(
                    '${cyberEnergy.toString()} / 200',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 32, 243, 102),
                        fontSize: widget.r(18.0)),
                  ),
                  const SizedBox(width: 20.0),
                  Text(
                    yourScore,
                    style: TextStyle(
                        color: const Color.fromARGB(255, 247, 245, 245),
                        fontSize: widget.r(18.0)),
                  ),
                ])),
          )),
      Padding(
          padding: const EdgeInsets.only(top: .0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Visibility(
                visible: walletUser.addr == '',
                child: Padding(
                    padding: EdgeInsets.only(top: widget.r(5.0)),
                    child: Text(
                      walletUser.addr == ''
                          ? 'connect to wallet → '
                          : (player.uuid == ''
                              ? 'Address: ${walletUser.addr} '
                              : ''),
                      style: TextStyle(
                          color: Colors.white, fontSize: widget.r(26.0)),
                    ))),
            SizedBox(
                width: widget.r(65.0),
                height: widget.r(40.0),
                child: Visibility(
                    visible: walletUser.addr != '',
                    child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        onPressed: () {
                          widget.callback('sort', List.empty(), null);
                        },
                        tooltip: 'SORT',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(widget.r(7.0)),
                          child: Image.asset(
                            width: widget.r(65.0),
                            height: widget.r(25.0),
                            '${imagePath}button/sort.png',
                            fit: BoxFit.cover,
                          ),
                        )))),
            SizedBox(width: widget.r(10.0)),
            SizedBox(
                width: widget.r(65.0),
                height: widget.r(40.0),
                child: Visibility(
                    visible: walletUser.addr != '',
                    child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        onPressed: () {
                          saveUserDeck();
                        },
                        tooltip: 'SAVE',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(widget.r(7.0)),
                          child: Image.asset(
                            width: widget.r(65.0),
                            height: widget.r(25.0),
                            '${imagePath}button/save.png',
                            fit: BoxFit.cover,
                          ),
                        )))),
            SizedBox(width: widget.r(10.0)),
            SizedBox(
                width: widget.r(65.0),
                height: widget.r(40.0),
                child: Visibility(
                    visible: walletUser.addr != '',
                    child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        onPressed: () async {
                          await resetUserDeck();
                        },
                        tooltip: 'Reset',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(widget.r(7.0)),
                          child: Image.asset(
                            width: widget.r(65.0),
                            height: widget.r(25.0),
                            '${imagePath}button/reset.png',
                            fit: BoxFit.cover,
                          ),
                        )))),
            Visibility(
                visible: walletUser.addr == '',
                child: SizedBox(
                    width: widget.r(40.0),
                    height: widget.r(40.0),
                    child: const FittedBox(
                      child: FloatingActionButton(
                          onPressed: authenticate,
                          tooltip: 'Authenticate',
                          child: Icon(Icons.key_outlined)),
                    ))),
            SizedBox(width: widget.r(55)),
          ])),
      Stack(children: <Widget>[
        Positioned(
            left: widget.r(200),
            top: 0.0,
            child:
                ExpandableFAB(distance: widget.r(150), r: widget.r, children: [
              SizedBox(
                  width: 32.0,
                  height: 32.0,
                  child: FittedBox(
                      child: FABActionButton(
                          icon: const Icon(Icons.design_services,
                              size: 25.0, color: Colors.white),
                          onPressed: () {
                            html.window.open('rule_book', 'rule_book');
                          },
                          tooltip: 'The rule of this game'))),
              SizedBox(
                  width: 32.0,
                  height: 32.0,
                  child: FittedBox(
                      child: FABActionButton(
                    icon: const Icon(Icons.view_carousel_outlined,
                        size: 25.0, color: Colors.white),
                    onPressed: () {
                      setState(() => showCarousel2 = true);
                    },
                    tooltip: 'How to Play',
                  ))),
              SizedBox(
                  width: 32.0,
                  height: 32.0,
                  child: FittedBox(
                      child: FABActionButton(
                    icon: const Icon(Icons.how_to_vote,
                        size: 25.0, color: Colors.white),
                    onPressed: () {
                      setState(() => showCarousel = true);
                    },
                    tooltip: 'Card List',
                  ))),
            ])),
      ]),
      Visibility(
          visible: showCarousel == true,
          child: Stack(children: <Widget>[
            CarouselSlider.builder(
              options: CarouselOptions(
                  height: widget.r(800),
                  aspectRatio: 14 / 9,
                  viewportFraction: 0.75, // 1.0:1つが全体に出る
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.vertical),
              itemCount: 28,
              itemBuilder: (context, index, realIndex) {
                dynamic card = cardList != null
                    ? cardList[index >= 11
                        ? (index + 2).toString()
                        : (index + 1).toString()]
                    : null;
                return buildCarouselImage(index, card);
              },
            ),
            Positioned(
                top: widget.r(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showCarousel = false;
                    });
                  },
                  child: Text('Close',
                      style: TextStyle(
                          color: Colors.black, fontSize: widget.r(28.0))),
                )),
          ])),
      Visibility(
          visible: showCarousel2 == true,
          child: Column(children: <Widget>[
            CarouselSlider.builder(
              carouselController: cController,
              options: CarouselOptions(
                  height: widget.r(450.0),
                  // aspectRatio: 9 / 9,
                  viewportFraction: 0.4, // 1.0:1つが全体に出る
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      activeIndex = index;
                    });
                  }),
              itemCount: 9,
              itemBuilder: (context, index, realIndex) {
                List<String> messages = [
                  L10n.of(context)!.tutorial1,
                  L10n.of(context)!.tutorial2,
                  L10n.of(context)!.tutorial3,
                  L10n.of(context)!.tutorial4,
                  L10n.of(context)!.tutorial5,
                  L10n.of(context)!.tutorial6,
                  L10n.of(context)!.tutorial7,
                  L10n.of(context)!.tutorial8,
                  L10n.of(context)!.tutorial9
                ];
                return buildCarouselImage2(index, messages[index]);
              },
            ),
            buildIndicator(),
            SizedBox(height: widget.r(10.0)),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showCarousel2 = false;
                });
              },
              child: const Text('Close',
                  style: TextStyle(color: Colors.black, fontSize: 22.0)),
            ),
          ]))
    ]);
  }

  Widget buildCarouselImage(int index, dynamic card) => Padding(
        padding: EdgeInsets.only(left: widget.r(5.0)),
        child: Row(children: <Widget>[
          card == null
              ? Container()
              : Image.asset(
                  '$imagePath${card['category'] == '0' ? 'unit' : 'trigger'}/card_${card['card_id']}.jpeg',
                  fit: BoxFit.cover,
                ),
          Container(
              color: card == null ? Colors.grey : Colors.white,
              child: card == null
                  ? Container()
                  : Table(
                      border: TableBorder.all(),
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      defaultColumnWidth: IntrinsicColumnWidth(),
                      children: [
                          buildTableRow(['Name', card['name']], false),
                          buildTableRow([
                            'Card Type',
                            card['category'] == '0'
                                ? 'Unit'
                                : (card['category'] == '1'
                                    ? 'Trigger'
                                    : 'Intercept')
                          ], false),
                          buildTableRow([
                            'BP(Power)',
                            card['bp'] == '0' ? '-' : card['bp']
                          ], false),
                          buildTableRow(['CP(Cost)', card['cost']], false),
                          buildTableRow([
                            'Attribute',
                            card['type'] == '0'
                                ? 'Red'
                                : (card['type'] == '1' ? 'Yellow' : '-')
                          ], false),
                          buildTableRow([
                            'Ability',
                            L10n.of(context)!
                                .cardDescription
                                .split('|')[index >= 11 ? index + 1 : index]
                          ], true),
                        ]))
        ]),
      );
  TableRow buildTableRow(List<String> cells, bool high) => TableRow(
          children: cells.map((cell) {
        return TableCell(
            child: high && cell != 'Ability'
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                        widget.r(12), widget.r(12), widget.r(20), widget.r(12)),
                    child: Center(
                        child: SizedBox(
                            height: widget.r(200.0),
                            width: widget.r(750.0),
                            child: Text(cell,
                                style: TextStyle(fontSize: widget.r(22.0))))))
                : Padding(
                    padding: EdgeInsets.all(widget.r(12)),
                    child: Text(cell,
                        style: TextStyle(fontSize: widget.r(28.0)))));
      }).toList());
  Widget buildCarouselImage2(int index, String message) => Column(children: [
        Image.asset(
          '${imagePath}button/how_to_play${index + 1}.png',
          fit: BoxFit.cover,
        ),
        Container(
            color: Colors.white,
            height: widget.r(100.0),
            child: Padding(
                padding: EdgeInsets.all(widget.r(20.0)),
                child: Text(
                  message,
                  style:
                      TextStyle(color: Colors.black, fontSize: widget.r(16.0)),
                ))),
      ]);

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: 9,
        onDotClicked: (index) {
          cController.animateToPage(index);
        },
        effect: JumpingDotEffect(
          verticalOffset: widget.r(5.0),
          activeDotColor: Colors.orange,
          // dotColor: Colors.black12,
        ),
      );
}
