import 'dart:async';

import 'package:adhoc_gaming/game/simon_game.dart';
import 'package:adhoc_gaming/pages/adhoc_page.dart';
import 'package:adhoc_gaming/pages/game_page.dart';
import 'package:adhoc_gaming/pages/internet_page.dart';
import 'package:adhoc_gaming/pages/main_page.dart';
import 'package:adhoc_gaming/pages/page_settings.dart';
import 'package:adhoc_gaming/pages/transition_dialog.dart';
import 'package:adhoc_gaming/player/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class OrganisationPage extends StatefulWidget {
  @override
  _OrganisationPage createState() => _OrganisationPage();
}

class _OrganisationPage extends State<OrganisationPage> {
  final textController = TextEditingController();
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Provider.of<PlayerManager>(context, listen: false)
        .startGameStream
        .listen((seed) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => SimonGame(
                Provider.of<PlayerManager>(context, listen: false)
                    .getNbPlayers(),
                seed),
            child: GamePage(),
          ),
        ));
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => TransitionDialog()));
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Simon Game'),
      ),
      body: PageView(
        physics: Provider.of<PageSettings>(context).getScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller:
            Provider.of<PageSettings>(context, listen: false).controller,
        children: [
          AdhocPage(),
          MainPage(),
          InternetPage(),
        ],
        onPageChanged: (i) => Provider.of<PageSettings>(context, listen: false)
            .modifyIndex(i, false),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: Provider.of<PageSettings>(context).getBottomIndex(),
        onTap: (i) => Provider.of<PageSettings>(context, listen: false)
            .modifyIndex(i, true),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.bluetooth),
            title: const Text("Adhoc"),
            selectedColor: const Color.fromRGBO(97, 192, 142, 1),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Game"),
            selectedColor: const Color.fromRGBO(71, 163, 179, 1),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.wifi),
            title: const Text("Internet"),
            selectedColor: const Color.fromRGBO(92, 68, 134, 1),
          ),
        ],
      ),
    );
  }
}
