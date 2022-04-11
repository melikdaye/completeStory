
import 'package:flutter/material.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';

import '../myGames.dart';
import '../provider/provider.dart';
List<String> possibleAns = <String>['Evet', 'Hayır', 'Alakasız'];

Future listUser(context,GameRoom gameRoom) {
  final DatabaseService _databaseService = DatabaseService();

  Future<Map> getPlayerName() async {
    late Map uid2name = {};  // method
    for (var player in gameRoom.currentPlayers){
      String name = await _databaseService.getPlayerName(player);
      uid2name[player] = name;
    }
    return uid2name;
  }

  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder<Map>(
          future: getPlayerName(),
          builder: (context, snapshot) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if(snapshot.hasData)
                for(var player in gameRoom.currentPlayers)
                  ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(snapshot.data![player] ?? player),
                  trailing: IconButton(onPressed: () {
                    _databaseService.leaveGame(player, gameRoom, gameRoom.isWaiting?"pre":"playing");
                    Navigator.pop(context);
                  }, icon: const Icon(Icons.exit_to_app),
                  ),

                ),
              ],
            );
          }
        );
      });
}

Future<dynamic> bottomSheet(GameRoom gameRoom,dynamic questions,mode,context){
  final DatabaseService _databaseService = DatabaseService();
  String uid = Provider.of<AppContext>(context,listen: false).uid;
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if(mode == 0)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Oyuna Katıl'),
                onTap: () {
                  _databaseService.joinGame(uid, gameRoom);
                  Provider.of<AppContext>(context,listen: false).changeBottomBarIndex(2);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return  const MyGames();
                  }));
                  // Navigator.pop(context);
                },
              ),
            if(mode == 1 || mode == 4)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Oyunu Terket'),
                onTap: () {
                  _databaseService.leaveGame(uid, gameRoom,mode == 1 ? "pre" : "playing");

                  // Navigator.pop(context);
                },
              ),

            if(mode == 2 || mode == 3)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Oyuncu Çıkar'),
              onTap: () {
                Navigator.pop(context);
                listUser(context, gameRoom);
              },
            ),
            if(mode==2 )
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Oyunu Başlat'),
              onTap: () {
                _databaseService.transferRoomToInGame(gameRoom);
                Navigator.pop(context);
              },
            ),

            if(mode == 3)
              ListTile(
                leading: const Icon(Icons.publish),
                title: const Text('Hikayeyi yayınla ve bitir'),
                onTap: () {
                  _databaseService.transferRoomToInGame(gameRoom);
                  Navigator.pop(context);
                },
              ),
            if(mode == 2  || mode == 3)
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Oyunu Sil'),
              onTap: () {
                _databaseService.removeGame(gameRoom);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return  MyGames();
                }));
              },
            ),
          ],
        );
      });
}