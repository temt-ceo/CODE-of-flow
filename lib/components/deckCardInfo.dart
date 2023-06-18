import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:percent_indicator/percent_indicator.dart';

import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/services/api_service.dart';

const envFlavor = String.fromEnvironment('flavor');
typedef double ResponsiveSizeChangeFunction(double data);

class DeckCardInfo extends StatefulWidget {
  final GameObject? info;
  final dynamic cardInfos;
  final int? tappedCardId;
  final String label;
  final bool isEnglish;
  final ResponsiveSizeChangeFunction r;

  const DeckCardInfo(this.info, this.cardInfos, this.tappedCardId, this.label,
      this.isEnglish, this.r);

  @override
  DeckCardInfoState createState() => DeckCardInfoState();
}

class DeckCardInfoState extends State<DeckCardInfo> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  APIService apiService = APIService();
  BuildContext? loadingContext;

  @override
  void initState() {
    super.initState();
    // position = widget.initPos;
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

  String getCardInfo(int? cardId, String type) {
    if (widget.cardInfos != null) {
      if (type == 'text') {
        if (widget.cardInfos[cardId.toString()] != null) {
          String category = widget.cardInfos[cardId.toString()]['category'];
          if (category == '0') {
            String bp = widget.cardInfos[cardId.toString()]['bp'];
            String ret = L10n.of(context)!.cardDescription;
            return "[BP :$bp]\n${ret.split('|')[cardId! - 1]}";
          } else if (category == '1') {
            String ret = L10n.of(context)!.cardDescription;
            String ability = ret.split('|')[cardId! - 1];
            return "[Trigger] * ${L10n.of(context)!.triggerDesc}\n\n$ability";
          } else if (category == '2') {
            String ret = L10n.of(context)!.cardDescription;
            String ability = ret.split('|')[cardId! - 1];
            return "[Intercept] * ${L10n.of(context)!.interceptDesc}\n\n$ability";
          }
        }
      } else {
        if (widget.cardInfos[cardId.toString()] != null) {
          return widget.cardInfos[cardId.toString()][type];
        }
      }
      return '';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Visibility(
          visible: widget.tappedCardId != null,
          child: Positioned(
              left: widget.r(20.0),
              top: widget.r(386.0),
              child: Container(
                  width: widget.r(180.0),
                  height: widget.r(80.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(widget.tappedCardId == null
                            ? ''
                            : (widget.tappedCardId! >= 17
                                ? '${imagePath}trigger/card_${widget.tappedCardId!}.jpeg'
                                : '${imagePath}unit/card_${widget.tappedCardId!}.jpeg')),
                        fit: BoxFit.cover),
                  ),
                  child: Column(children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(getCardInfo(widget.tappedCardId, 'name'),
                            style: TextStyle(
                                backgroundColor: Colors.black,
                                color: Colors.white,
                                fontSize: widget.r(20.0)))),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(getCardInfo(widget.tappedCardId, 'cost'),
                            style: TextStyle(
                                backgroundColor: Colors.red,
                                color: Colors.white,
                                fontSize: widget.r(22.0)))),
                  ])))),
      Positioned(
          left: widget.r(20.0),
          top: widget.r(442.0),
          child: Container(
            width: widget.r(300.0),
            height: widget.r(165.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('${imagePath}unit/bg-2.jpg'),
                  fit: BoxFit.cover),
            ),
          )),
      Positioned(
          left: widget.r(30.0),
          top: widget.r(462.0),
          width: widget.r(270.0),
          child: Text(getCardInfo(widget.tappedCardId, 'text'),
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.isEnglish ? widget.r(16.0) : widget.r(14.0),
              ))),
    ]);
  }
}
