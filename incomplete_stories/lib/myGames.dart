import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/listItem.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/services/databaseService.dart';

class MyGames extends StatefulWidget {
  const MyGames({Key? key, required this.title}) : super(key: key);

  final String title;




  @override
  State<MyGames> createState() => _MyGamesState();
}

class _MyGamesState extends State<MyGames> {
  final DatabaseService _databaseService = DatabaseService();
  late Map<dynamic,GameRoom> managedGames = {};
  late Map<dynamic,GameRoom> completedGames = {};
  late Map<dynamic,GameRoom> preGames = {};

  updateRoomStatus(dynamic updates){
    for(var game in updates as List<Object?>) {
      dynamic hashedMap = jsonDecode(jsonEncode(game));
      var map = HashMap.from(hashedMap);
      GameRoom gameRoom = GameRoom.fromJson(map);
      if (gameRoom.gameOver){
        completedGames.update(gameRoom.id,(value) => gameRoom,ifAbsent: () => gameRoom);
      }
      else {
       managedGames.update(gameRoom.id,(value) => gameRoom,ifAbsent: () => gameRoom);
      }
    }
    if(mounted) {
        setState(() {
          managedGames = managedGames;
          completedGames = completedGames;
        });
    }
  }

  updateInLobbyGames(dynamic game){
    print(game);
    dynamic hashedMap = jsonDecode(jsonEncode(game));
    var map = HashMap.from(hashedMap);
    GameRoom gameRoom = GameRoom.fromJson(map);
    preGames.update(gameRoom.id,(value) => gameRoom,ifAbsent: () => gameRoom);
    print(preGames);
  }

  @override
  void initState() {
    super.initState();
    print("initState");
    _databaseService.getManagedRoomsUpdates("y7cPlFnzUNRZi3jTirbOPdW4bbC3",updateRoomStatus);
    _databaseService.getInLobbyRooms("a",updateInLobbyGames);

  }
  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            onTap : (int value) async {

            },
            tabs: const[
              Tab(icon: Icon(Icons.gamepad_outlined), text: "Oynadıklarım"),
              Tab(icon: Icon(Icons.people), text: "Oynattıklarım",),
              Tab(icon: Icon(Icons.videogame_asset_off), text: "Bitenler"),
            ],
          ),
        ),
        body:  TabBarView(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: preGames.keys.length,
                  itemBuilder: (_, index) {
                    return listItem(preGames[preGames.keys.toList()[index]] as GameRoom,_databaseService,context,1);
                  }),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: managedGames.keys.length,
                  itemBuilder: (_, index) {
                    return listItem(managedGames[managedGames.keys.toList()[index]] as GameRoom,_databaseService,context,2);
                  }),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: completedGames.keys.length,
                  itemBuilder: (_, index) {
                    return listItem(completedGames[completedGames.keys.toList()[index]] as GameRoom,_databaseService,context,2);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}