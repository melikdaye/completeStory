import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/listItem.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/services/databaseService.dart';

import 'Components/bottomBar.dart';

class MyGames extends StatefulWidget {
  const MyGames({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyGames> createState() => _MyGamesState();
}

class _MyGamesState extends State<MyGames> {
  final DatabaseService _databaseService = DatabaseService();
  late Map<dynamic,GameRoom> preManagedGames = {};
  late Map<dynamic,GameRoom> playingManagedGames = {};
  late Map<dynamic,GameRoom> completedGames = {};
  late Map<dynamic,GameRoom> preGames = {};

  updateRoomStatus(dynamic updates){
    print(updates);
    if(updates != null) {
      for (var game in updates as List<Object?>) {
        if(game != null){
        dynamic hashedMap = jsonDecode(jsonEncode(game));
        var map = HashMap.from(hashedMap);
        GameRoom gameRoom = GameRoom.fromJson(map);
        if (gameRoom.gameOver) {
          completedGames.update(
              gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
        }
        else {
          if (gameRoom.isWaiting) {
            preManagedGames.update(
                gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
          } else {
            if (preManagedGames.keys.contains(gameRoom.id)) {
              preManagedGames.remove(gameRoom.id);
            }
            playingManagedGames.update(
                gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
          }
        }
        }
      }
      if (mounted) {
        setState(() {
          preManagedGames = preManagedGames;
          playingManagedGames = playingManagedGames;
          completedGames = completedGames;
        });
      }
    }
  }

  updateInLobbyGames(dynamic game){
    if(game!=null) {
      dynamic hashedMap = jsonDecode(jsonEncode(game));
      var map = HashMap.from(hashedMap);
      GameRoom gameRoom = GameRoom.fromJson(map);
      if (gameRoom.currentPlayers.contains("a")) {
        preGames.update(
            gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
      } else {
        preGames.remove(gameRoom.id);
      }
      if (mounted) {
        setState(() {
          preGames = preGames;
        });
      }
    }
    print("preGames $preGames");
  }

  @override
  void initState() {
    super.initState();
    print("initState");
    _databaseService.getManagedPreGames("y7cPlFnzUNRZi3jTirbOPdW4bbC3",updateRoomStatus);
    _databaseService.getManagedPlayingGames("y7cPlFnzUNRZi3jTirbOPdW4bbC3",updateRoomStatus);
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
        backgroundColor: Colors.amber.shade50,
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
            ListView.builder(
                  itemCount: preGames.keys.length,
                  itemBuilder: (_, index) {
                    return listItem(preGames[preGames.keys.toList()[index]] as GameRoom,_databaseService,context,1);
                  }
            ),

           Column(
             children: [
               LimitedBox(
                     child:
               ListView.builder(
                      shrinkWrap: true,
                      itemCount: preManagedGames.keys.length,
                      itemBuilder: (_, index) {
                        return listItem(preManagedGames[preManagedGames.keys.toList()[index]] as GameRoom,_databaseService,context,2);
                      }
                )
               ),
               LimitedBox(child:
               ListView.builder(
                   shrinkWrap: true,
                   itemCount: playingManagedGames.keys.length,
                   itemBuilder: (_, index) {
                     return listItem(playingManagedGames[playingManagedGames.keys.toList()[index]] as GameRoom,_databaseService,context,3);
                   }
               )
               ),
             ],
           ),

            ListView.builder(
                  itemCount: completedGames.keys.length,
                  itemBuilder: (_, index) {
                    return listItem(completedGames[completedGames.keys.toList()[index]] as GameRoom,_databaseService,context,2);
                  }
              ),

          ],
        ),
        bottomNavigationBar: const BottomNavigator(),
      ),
    );
  }
}