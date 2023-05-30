import 'package:flutter/material.dart';
import 'package:CodeOfFlow/components/draggable_card_widget.dart';
import 'package:CodeOfFlow/components/drag_target_widget.dart';
import 'package:CodeOfFlow/components/on_going_game_info.dart';
import 'package:CodeOfFlow/components/start_buttons.dart';
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
  GameInfo gameInfo = GameInfo('', '', '');
  APIService apiService = APIService();

  void doAnimation() {
    setState(() => gameInfo = GameInfo('', '', ''));
    setState(() => cardPosition = 400.0);
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => cardPosition = 0.0);
      setState(() => gameInfo = GameInfo('bbbbb', '', ''));
      apiService.saveGameServerProcess('type', 'message', '1');
      // .then((value) => print(value.toString()));
      print('success');
    });
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
                  AnimatedContainer(
                    margin: EdgeInsetsDirectional.only(top: cardPosition),
                    duration: const Duration(seconds: 1),
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
          ]),
          OnGoingGameInfo(gameInfo, 'AAAA'),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: StartButtons((status) => status == 'game-is-ready'
            ? doAnimation()
            : setState(() => cardPosition = 0.0)));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
