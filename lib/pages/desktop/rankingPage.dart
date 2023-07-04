@JS()
library index;

import 'dart:convert';
import 'dart:async';
import 'dart:js_util';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:js/js.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:CodeOfFlow/components/expandableFAB.dart';
import 'package:CodeOfFlow/components/rankingInfo.dart';
import 'package:CodeOfFlow/components/playerInfo.dart';
import 'package:CodeOfFlow/responsive/dimensions.dart';

const envFlavor = String.fromEnvironment('flavor');

@JS('getRankingScores')
external dynamic getRankingScores();

@JS('getTotalScores')
external dynamic getTotalScores();

@JS('getRewardRaceBattleCount')
external dynamic getRewardRaceBattleCount();

@JS('jsonToString')
external String jsonToString(dynamic obj);

class RankingPage extends StatefulWidget {
  final bool enLocale;
  const RankingPage({super.key, required this.enLocale});

  @override
  State<RankingPage> createState() => RankingPageState();
}

class RankingPageState extends State<RankingPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        supportedLocales: L10n.supportedLocales,
        localizationsDelegates: L10n.localizationsDelegates,
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: AppBar(
                        // backgroundColor:
                        //     const ui.Color.fromARGB(255, 221, 32, 32),
                        bottom: const TabBar(tabs: [
                      Tab(
                        text: 'Mainnet',
                      ),
                      Tab(
                        text: 'Testnet',
                      )
                    ]))),
                body: TabBarView(children: [
                  NestedTabBar(isEnglish: widget.enLocale),
                  NestedTabBar(isEnglish: widget.enLocale),
                ]))));
  }
}

class NestedTabBar extends StatefulWidget {
  const NestedTabBar({Key? key, required this.isEnglish}) : super(key: key);
  final bool isEnglish;

  @override
  _NestedTabBarState createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with SingleTickerProviderStateMixin {
  RefreshController refreshController = RefreshController(initialRefresh: true);
  RefreshController refreshController2 =
      RefreshController(initialRefresh: true);
  List<RankingInfo> rankings = [];
  List<PlayerInfo> players = [];
  Size size = WidgetsBinding.instance.window.physicalSize;
  int battleCount = 0;
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  double r(double val) {
    final wRes = size.width / desktopWidth;
    return val * wRes;
  }

  void setRankingScores(dynamic rankingScores) {
    var objStr = jsonToString(rankingScores);
    var objJs = jsonDecode(objStr);
    objJs
        .sort((a, b) => int.parse(b['point']).compareTo(int.parse(a['point'])));
    setState(() {
      for (int i = 0; i < objJs.length; i++) {
        rankings.add(RankingInfo(
          rank: i + 1,
          point: int.parse(objJs[i]['point']),
          playerName: objJs[i]['player_name'],
          win: int.parse(objJs[i]['period_win_count']),
          icon: Image.asset(
            '${imagePath}button/rank${i < 3 ? (i + 1) : (i < 6 ? 'ing' : 'ing_below')}.png',
            fit: BoxFit.cover,
          ),
          onPressed: () {
            print(objJs[i]['player_name']);
          },
          r: r,
        ));
      }
    });
  }

  void setTotalScores(dynamic rankingScores) {
    var objStr = jsonToString(rankingScores);
    var objJs = jsonDecode(objStr);
    objJs
        .sort((a, b) => int.parse(b['point']).compareTo(int.parse(a['point'])));
    setState(() {
      for (int i = 0; i < objJs.length; i++) {
        players.add(PlayerInfo(
          rank: i + 1,
          point: int.parse(objJs[i]['point']),
          playerName: objJs[i]['player_name'],
          win: int.parse(objJs[i]['win_count']),
          rank1win: int.parse(objJs[i]['ranking_win_count']),
          rank2win: int.parse(objJs[i]['ranking_2nd_win_count']),
          icon: Image.asset(
            '${imagePath}button/rank${i < 3 ? (i + 1) : (i < 6 ? 'ing' : 'ing_below')}.png',
            fit: BoxFit.cover,
          ),
          onPressed: () {
            print(objJs[i]['player_name']);
          },
          r: r,
        ));
      }
    });
  }

  getRankings() async {
    setState(() {
      rankings.clear();
    });
    var rankingScores = await promiseToFuture(getRankingScores());
    setRankingScores(rankingScores);

    refreshController.refreshCompleted();
  }

  getPlayers() async {
    setState(() {
      players.clear();
    });
    var totalScores = await promiseToFuture(getTotalScores());
    setTotalScores(totalScores);

    refreshController2.refreshCompleted();
  }

  Future<void> getRewardRaceBattles() async {
    var ret = await promiseToFuture(getRewardRaceBattleCount());
    setState(() => battleCount = int.parse(ret));
  }

  ////////////////////////////
  ///////  initState   ///////
  ////////////////////////////
  @override
  void initState() {
    super.initState();

    getRewardRaceBattles();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: AppBar(
                    bottom: TabBar(tabs: [
                  Tab(
                    text: widget.isEnglish
                        ? 'Reward Ranking Race (Last ${1000 - battleCount} games)'
                        : 'リワード ランキング レース (残り ${1000 - battleCount} games)',
                  ),
                  const Tab(
                    text: 'Total Score Ranking',
                  )
                ]))),
            body: TabBarView(
              children: [
                Container(
                  color: Colors.black,
                  child: SmartRefresher(
                      controller: refreshController,
                      header: WaterDropHeader(
                        waterDropColor: Colors.blue.shade700,
                        // refresh:,
                        // complete: Container(),
                        completeDuration: Duration.zero,
                      ),
                      onRefresh: () => getRankings(),
                      child: ListView.builder(
                          itemCount: rankings.length,
                          itemBuilder: (BuildContext context, int index) =>
                              rankings[index])),
                ),
                Container(
                  color: Colors.black12,
                  child: SmartRefresher(
                      controller: refreshController2,
                      header: WaterDropHeader(
                        waterDropColor: Colors.blue.shade700,
                        // refresh:,
                        // complete: Container(),
                        completeDuration: Duration.zero,
                      ),
                      onRefresh: () => getPlayers(),
                      child: ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (BuildContext context, int index) =>
                              players[index])),
                ),
              ],
            )));
  }
}
