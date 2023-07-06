import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:CodeOfFlow/responsive/dimensions.dart';

const envFlavor = String.fromEnvironment('flavor');

class WhitePaperPage extends StatefulWidget {
  final bool enLocale;
  const WhitePaperPage({super.key, required this.enLocale});

  @override
  State<WhitePaperPage> createState() => WhitePaperPageState();
}

class WhitePaperPageState extends State<WhitePaperPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (layoutContext, constraints) {
      final wRes = constraints.maxWidth / desktopHeight;
      double r(double val) {
        return val * wRes;
      }

      return DefaultTabController(
        length: 2,
        child: // ホワイトペーパー(中身)
            Positioned(
                top: 0.0,
                left: r(50.0),
                child: Container(
                    color: Colors.white,
                    width: r(1000.0),
                    height: r(1000.0),
                    child: SingleChildScrollView(
                        padding: EdgeInsets.all(r(50.0)),
                        child: Column(children: [
                          SizedBox(
                              height: r(100.0),
                              child: Text(
                                '最初に75枚のカードを所有していますので、どのカードをゲームに使用するか決める事が出来ます。最初にスターターセットがセットされていますので、いきなりゲームする事も出来ます。',
                                style: TextStyle(
                                    color: Colors.black, fontSize: r(16.0)),
                              )),
                          SizedBox(
                              height: r(100.0),
                              child: Text(
                                '最初に75枚のカードを所有していますので、どのカードをゲームに使用するか決める事が出来ます。最初にスターターセットがセットされていますので、いきなりゲームする事も出来ます。',
                                style: TextStyle(
                                    color: Colors.black, fontSize: r(16.0)),
                              )),
                          SizedBox(
                              height: r(100.0),
                              child: Text(
                                '最初に75枚のカードを所有していますので、どのカードをゲームに使用するか決める事が出来ます。最初にスターターセットがセットされていますので、いきなりゲームする事も出来ます。',
                                style: TextStyle(
                                    color: Colors.black, fontSize: r(16.0)),
                              )),
                          SizedBox(
                              height: r(100.0),
                              child: Text(
                                '最初に75枚のカードを所有していますので、どのカードをゲームに使用するか決める事が出来ます。最初にスターターセットがセットされていますので、いきなりゲームする事も出来ます。',
                                style: TextStyle(
                                    color: Colors.black, fontSize: r(16.0)),
                              )),
                          SizedBox(
                              height: r(100.0),
                              child: Text(
                                '最初に75枚のカードを所有していますので、どのカードをゲームに使用するか決める事が出来ます。最初にスターターセットがセットされていますので、いきなりゲームする事も出来ます。',
                                style: TextStyle(
                                    color: Colors.black, fontSize: r(16.0)),
                              )),
                          SizedBox(
                              height: r(100.0),
                              child: Text(
                                '最初に75枚のカードを所有していますので、どのカードをゲームに使用するか決める事が出来ます。最初にスターターセットがセットされていますので、いきなりゲームする事も出来ます。',
                                style: TextStyle(
                                    color: Colors.black, fontSize: r(16.0)),
                              )),
                          SizedBox(
                              height: r(100.0),
                              child: Text(
                                '最初に75枚のカードを所有していますので、どのカードをゲームに使用するか決める事が出来ます。最初にスターターセットがセットされていますので、いきなりゲームする事も出来ます。',
                                style: TextStyle(
                                    color: Colors.black, fontSize: r(16.0)),
                              )),
                        ])))),
      );
    });
  }
}
