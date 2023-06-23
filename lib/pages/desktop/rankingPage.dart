import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:CodeOfFlow/components/expandableFAB.dart';
import 'package:CodeOfFlow/components/playerInfo.dart';
import 'package:CodeOfFlow/responsive/dimensions.dart';

const envFlavor = String.fromEnvironment('flavor');

class RankingPage extends StatefulWidget {
  final bool enLocale;
  const RankingPage({super.key, required this.enLocale});

  @override
  State<RankingPage> createState() => RankingPageState();
}

class RankingPageState extends State<RankingPage> {
  RefreshController refreshController = RefreshController(initialRefresh: true);
  List<PlayerInfo> players = [];
  Size size = WidgetsBinding.instance.window.physicalSize;
  double r(double val) {
    final wRes = size.width / desktopWidth;
    return val * wRes;
  }

  getPlayers() async {
    setState(() {
      players.clear();
    });
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      players.add(PlayerInfo(
        icon: const Icon(Icons.create, color: Colors.white),
        onPressed: () {
          print('EN is successfully charged.');
        },
        r: r,
      ));
      players.add(PlayerInfo(
        icon: const Icon(Icons.create, color: Colors.white),
        onPressed: () {
          print('EN is successfully charged.');
        },
        r: r,
      ));
      players.add(PlayerInfo(
        icon: const Icon(Icons.create, color: Colors.white),
        onPressed: () {
          print('EN is successfully charged.');
        },
        r: r,
      ));
    });

    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: AppBar(
                        bottom: const TabBar(tabs: [
                      Tab(
                        text: 'Tab1',
                      ),
                      Tab(
                        text: 'Tab1',
                      )
                    ]))),
                body: TabBarView(children: [
                  const NestedTabBar(),
                  SmartRefresher(
                      controller: refreshController,
                      header: WaterDropHeader(
                        waterDropColor: Colors.green.shade700,
                        // refresh:,
                        // complete: Container(),
                        completeDuration: Duration.zero,
                      ),
                      onRefresh: () => getPlayers(),
                      child: ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (BuildContext context, int index) =>
                              players[index])),
                ]))));
  }
}

class NestedTabBar extends StatefulWidget {
  const NestedTabBar({Key? key}) : super(key: key);

  @override
  _NestedTabBarState createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: AppBar(
                    bottom: const TabBar(tabs: [
                  Tab(
                    text: 'NTab1',
                  ),
                  Tab(
                    text: 'NTab1',
                  )
                ]))),
            body: TabBarView(
              children: [
                Container(
                  color: Colors.black,
                ),
                Container(
                  color: Colors.amber,
                ),
              ],
            )));
  }
}
