
import 'package:flutter/material.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/services/databaseService.dart';
List<String> possibleAns = <String>['Evet', 'Hayır', 'Alakasız'];

Future listUser(context,GameRoom gameRoom){
  final DatabaseService _databaseService = DatabaseService();
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for(var player in gameRoom.currentPlayers)
              ListTile(
              leading: const Icon(Icons.person),
              title: Text(player),
              trailing: IconButton(onPressed: () {
                _databaseService.leaveGame(player, gameRoom, gameRoom.isWaiting?"pre":"playing");
                Navigator.pop(context);
              }, icon: const Icon(Icons.exit_to_app),
              ),

            ),
          ],
        );
      });
}

Future<dynamic> bottomSheet(GameRoom gameRoom,dynamic questions,mode,context){
  final DatabaseService _databaseService = DatabaseService();
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            if(mode == 1 || mode == 4)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Oyunu Terket'),
                onTap: () {
                  _databaseService.leaveGame("a", gameRoom,"pre");

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
                print(gameRoom.currentPlayers);

                // Navigator.pop(context);
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
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}