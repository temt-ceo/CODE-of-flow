import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:html' as html;

import 'package:CodeOfFlow/responsive/dimensions.dart';

const envFlavor = String.fromEnvironment('flavor');

class RuleBookPage extends StatefulWidget {
  final bool enLocale;
  const RuleBookPage({super.key, required this.enLocale});

  @override
  State<RuleBookPage> createState() => RuleBookPageState();
}

class RuleBookPageState extends State<RuleBookPage> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (layoutContext, constraints) {
      final wRes = constraints.maxWidth / desktopHeight;
      double r(double val) {
        return val * wRes;
      }

      return Container(
        color: Colors.white,
        child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(r(90.0), 50.0, r(90.0), 50.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    L10n.of(context)!.tutorial01,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial02,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial03,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial04,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial05,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial06,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial07,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial08,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial09,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial10,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial11,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial12,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial13,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial14,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial3.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial15,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial16,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial17,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial18,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial19,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial4.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial20,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial21,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial5.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial22,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial23,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial24,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial25,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial26,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial27,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial28,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial29,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial30,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial31,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial32,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial33,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial34,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial6.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial35,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial36,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial37,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial38,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial39,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial7.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial40,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial41,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial42,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial43,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial44,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial8.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial45,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial46,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial47,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial9.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial48,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial49,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial50,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial51,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial52,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial53,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial54,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial55,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial56,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial10.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial57,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial58,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial59,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial60,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial61,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial11.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial62,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial63,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial64,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial65,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial66,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r(40.0)),
                    child: Image.asset(
                      '${imagePath}button/tutorial12.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    L10n.of(context)!.tutorial67,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial68,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial69,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial70,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial71,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial72,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial73,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial74,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial75,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial76,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial77,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial78,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial79,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.tutorial80,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                ])),
      );
    });
  }
}
