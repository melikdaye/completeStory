
import 'package:flutter/material.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/services/databaseService.dart';

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
              }, icon: Icon(Icons.exit_to_app),
              ),

            ),
          ],
        );
      });
}



Future<dynamic> bottomSheet(GameRoom gameRoom,mode,context){
  final DatabaseService _databaseService = DatabaseService();
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Oyuncu Çıkar'),
              onTap: () {
                listUser(context, gameRoom);
                print(gameRoom.currentPlayers);

                // Navigator.pop(context);
              },
            ),
            if(mode==2)
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
                leading: const Icon(Icons.question_answer),
                title: const Text('Soruları Cevapla'),
                onTap: () {
                  _databaseService.transferRoomToInGame(gameRoom);
                  Navigator.pop(context);
                },
              ),
            if(mode == 3)
              ListTile(
                leading: const Icon(Icons.thumb_up),
                title: const Text('Hikaye tahminlerini onayla'),
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
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Oyunu Sil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}