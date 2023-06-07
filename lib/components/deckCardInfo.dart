import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/services/api_service.dart';

const envFlavor = String.fromEnvironment('flavor');

class DeckCardInfo extends StatefulWidget {
  final GameObject? info;
  final String cardText;
  final String label;

  const DeckCardInfo(this.info, this.cardText, this.label);

  @override
  DeckCardInfoState createState() => DeckCardInfoState();
}

class DeckCardInfoState extends State<DeckCardInfo> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  APIService apiService = APIService();
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

  @override
  void initState() {
    super.initState();
    // position = widget.initPos;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned(
          left: 30.0,
          top: widget.label == 'home' ? 485.0 : 450.0,
          width: 270.0,
          child: Text(widget.cardText,
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 16.0,
              ))),
      Positioned(
        left: 280.0,
        top: 0.0,
        child: Visibility(
            visible: widget.info != null
                ? widget.info!.isFirst != widget.info!.isFirstTurn
                : false,
            child: CircularPercentIndicator(
              radius: 23.0,
              lineWidth: 4.0,
              percent: 0.5,
              backgroundWidth: 0.0,
              center: const Column(children: <Widget>[
                SizedBox(height: 12.0),
                Text("50%",
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 16.0,
                    )),
              ]),
              progressColor: const Color.fromARGB(255, 1, 247, 42),
            )),
      ),
    ]);
  }
}
