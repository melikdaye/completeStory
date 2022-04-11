import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incomplete_stories/Components/bottomBar.dart';
import 'package:incomplete_stories/Components/listItem.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';

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
    String uid = Provider.of<AppContext>(context,listen: false).uid;
    games.removeWhere((key, value) => value.currentPlayers.contains(uid));
    
    if(mounted) {
      setState(() {
        games = games;
      });
    }
    
    
  }
  
  
  listFoundedGames(dynamic availableGames){
    dynamic avGames = (availableGames is List<Object?>) ? availableGames : availableGames.values.toList() ;
    for(var game in avGames as List<Object?>) {
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
    dynamic rmGames = (removedGames is List<Object?>) ? removedGames : removedGames.values.toList() ;
    for(var game in rmGames as List<Object?>) {
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
    dynamic upGames = (updatedGames is List<Object?>) ? updatedGames : updatedGames.values.toList() ;
    for(var game in upGames as List<Object?>) {
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
    _databaseService.searchAvailableGames(listFoundedGames,checkRemovedGames, checkUpdates);

  }

  static const TextStyle _textStyle = TextStyle(fontSize: 15,fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(backgroundColor: Color(0xFFFB3640) ,),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.amber,
                child: const ListTile(
                  leading: Padding(
                    padding: EdgeInsets.only(top: 8.0,bottom: 8.0),
                    child: Text('ID',style: _textStyle),
                  ),
                  title: Center(
                    child: Text('Hikaye',style: _textStyle),
                  ),
                  trailing: Text('Oyuncular',style: _textStyle),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: games.keys.length,
                    itemBuilder: (_, index) {
                      return listItem(games[games.keys.toList()[index]] as GameRoom,_databaseService,context,0,null);
                    }),
              ),
            ],
          ),

          bottomNavigationBar:  BottomNavigator(),
      ),
    );
  }
}