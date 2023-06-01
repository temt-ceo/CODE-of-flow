import 'package:flutter/material.dart';
import 'package:CodeOfFlow/components/draggable_card_widget.dart';
import 'package:CodeOfFlow/components/drag_target_widget.dart';
import 'package:CodeOfFlow/components/on_going_game_info.dart';
import 'package:CodeOfFlow/components/start_buttons.dart';
import 'package:CodeOfFlow/components/timerComponent.dart';
import 'package:CodeOfFlow/models/on_going_info_model.dart';
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
  GameInfo gameInfo = GameInfo('', '', '');
  late GameObject gameObject;
  List<List<int>> mariganCardList = [];
  int mariganClickCount = 0;
  List<int> handCards = [];
  int gameProgressStatus = 0;

  void doAnimation() {
    setState(() => gameInfo = GameInfo('', '', ''));
    setState(() => cardPosition = 400.0);
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => cardPosition = 0.0);
      setState(() => gameInfo = GameInfo('bbbbb', '', ''));
    });
  }

  void battleStart() async {
    setState(() => gameProgressStatus = 2);
    // Call GraphQL method.
    if (gameObject != null) {
      var ret = await apiService.saveGameServerProcess(
          'player_matching', '', gameObject.you.toString());
      debugPrint('transaction published');
      if (ret != null) {
        debugPrint(ret.message);
      }
    }
  }

  var timer = TimerComponent();
  void setDataAndMarigan(GameObject? data, List<List<int>>? mariganCards) {
    setState(() => gameObject = data!);
    setState(() => mariganCardList = mariganCards!);
    setState(() => mariganClickCount = 0);
    setState(() => handCards = mariganCards![mariganClickCount]);
    setState(() => gameProgressStatus = 1);
    // Start Marigan.
    timer.countdownStart(8, battleStart);
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
                                DragBox(
                                    cardId,
                                    cardId > 16
                                        ? '${imagePath}trigger/card_${cardId.toString()}.jpeg'
                                        : '${imagePath}unit/card_${cardId.toString()}.jpeg'),
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
                              DragBox(16, '${imagePath}unit/card_16.jpeg'),
                              DragBox(17, '${imagePath}trigger/card_17.jpeg'),
                              DragBox(18, '${imagePath}trigger/card_18.jpeg'),
                              DragBox(19, '${imagePath}trigger/card_19.jpeg'),
                              DragBox(1, '${imagePath}unit/card_1.jpeg'),
                              DragBox(2, '${imagePath}unit/card_2.jpeg'),
                              DragBox(3, '${imagePath}unit/card_3.jpeg'),
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
                            const EdgeInsets.fromLTRB(30.0, 130.0, 30.0, 10.0),
                        child: DragTargetWidget(
                            'trigger', '${imagePath}trigger/trigger.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: DragTargetWidget(
                            'unit', '${imagePath}unit/bg-2.jpg'),
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
                            stream: timer.events.stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<int> snapshot) {
                              return Center(
                                  child: Text(
                                '00:0${snapshot.data.toString()}',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 46.0),
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
          OnGoingGameInfo(gameInfo, 'AAAA'),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: StartButtons((status, data, mariganCards) =>
            status == 'game-is-ready'
                ? doAnimation()
                : (status == 'matching-success'
                    ? setDataAndMarigan(data, mariganCards)
                    : (status == 'matching-success'
                        ? setState(() => {})
                        : () {}))));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
