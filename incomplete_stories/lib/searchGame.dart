import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/bottomBar.dart';
import 'package:incomplete_stories/Components/listItem.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/myGames.dart';
import 'package:incomplete_stories/services/databaseService.dart';

class SearchGame extends StatefulWidget {
  const SearchGame({Key? key, required this.title}) : super(key: key);

  final String title;


  @override
  State<SearchGame> createState() => _SearchGameState();
}

class _SearchGameState extends State<SearchGame> {
  final DatabaseService _databaseService = DatabaseService();
  late Map<dynamic,GameRoom> games = {};
  
  void filterGames() {
    
    games.removeWhere((key, value) => value.currentPlayers.contains("a"));
    
    if(mounted) {
      setState(() {
        games = games;
      });
    }
    
    
  }
  
  
  listFoundedGames(dynamic availableGames){

    for(var game in availableGames as List<Object?>) {
      if(game != null) {
        dynamic hashedMap = jsonDecode(jsonEncode(game));
        var map = HashMap.from(hashedMap);
        GameRoom gameRoom = GameRoom.fromJson(map);
        games.putIfAbsent(gameRoom.id, () => gameRoom);
      }
    }
    filterGames();
  }

  checkRemovedGames(dynamic removedGames) {
    for(var game in removedGames as List<Object?>) {
      if(game != null) {
        dynamic hashedMap = jsonDecode(jsonEncode(game));
        var map = HashMap.from(hashedMap);
        GameRoom gameRoom = GameRoom.fromJson(map);
        games.remove(gameRoom.id);
      }
    }
    filterGames();
  }

  checkUpdates(dynamic updatedGames) {
    for(var game in updatedGames as List<Object?>) {
      if(game != null) {
        dynamic hashedMap = jsonDecode(jsonEncode(game));
        var map = HashMap.from(hashedMap);
        GameRoom gameRoom = GameRoom.fromJson(map);

        games.update(
            gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
      }

    }
    filterGames();
  }

  @override
  void initState() {
    super.initState();
    print("initState");
    _databaseService.searchAvailableGames(listFoundedGames,checkRemovedGames, checkUpdates);

  }
  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  // Widget _listItem(key) {
  //   String? cPlayerCnt = games[key]?.currentNumberOfPlayers.toString();
  //   String? mPlayerCnt = games[key]?.maxNumberOfPlayers.toString();
  //   String? beginStory = games[key]?.story;
  //   String? id = games[key]?.id.toString();
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     child: ListTile(
  //       onLongPress: () {
  //           _databaseService.joinGame("a", games[key] as GameRoom);
  //           Navigator.push(context, MaterialPageRoute(builder: (context) {
  //             return  const MyGames(title: "test");
  //           }));
  //       },
  //       leading: Text(id ?? "", style: const TextStyle(fontSize: 18)),
  //       title: Text(
  //         beginStory ?? "",
  //         style: const TextStyle(fontSize: 14,fontStyle: FontStyle.italic),
  //       ),
  //       trailing: Chip(label: Text('$cPlayerCnt/$mPlayerCnt',
  //           style: const TextStyle(fontSize: 18, color: Colors.purple)),
  //       )
  //     ),
  //     decoration: const BoxDecoration(
  //         border: Border(bottom: BorderSide(width: 1, color: Colors.black26))),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    print("build");
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.amber,
                child: const ListTile(
                  leading: Text('ID'),
                  title: Text('Story'),
                  trailing: Text('Players'),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: games.keys.length,
                    itemBuilder: (_, index) {
                      return listItem(games[games.keys.toList()[index]] as GameRoom,_databaseService,context,0);
                    }),
              ),
            ],
          ),

          // ListView(
      //     children: [
      //       for(var id in games.keys) ListTile(
      //
      //           leading: Chip(label:Text('${games[id]?.currentNumberOfPlayers.toString()}/${games[id]?.maxNumberOfPlayers.toString()}'??"no data"),
      //             backgroundColor: Colors.yellow.shade300,
      //           ),
      //           title : Text(games[id]?.id.toString() ?? ""),
      //
      //
      //       ),
      //
      //     ],
      //   ),
          bottomNavigationBar: const BottomNavigator(),
      ),
    );
  }
}