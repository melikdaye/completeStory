import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/myGames.dart';
import 'package:incomplete_stories/services/databaseService.dart';


Widget listItem(GameRoom room,DatabaseService _databaseService,BuildContext context,mode) {
  String? cPlayerCnt = room.currentNumberOfPlayers.toString();
  String? mPlayerCnt = room.maxNumberOfPlayers.toString();
  String? beginStory = room.story;
  String? id = room.id.toString();
  return Container(
    padding: const EdgeInsets.all(10),
    child: ListTile(
        onLongPress: () {
          switch(mode){
            case 0:
              _databaseService.joinGame("a", room);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return  const MyGames(title: "test");
              }));
              break;
            case 1:
              _databaseService.leaveGame("a", room,"pre");
              break;
            case 2:
                break;
          }
        },
        leading: Text(id , style: const TextStyle(fontSize: 18)),
        title: Text(
          beginStory,
          style: const TextStyle(fontSize: 14,fontStyle: FontStyle.italic),
        ),
        trailing: Chip(label: Text('$cPlayerCnt/$mPlayerCnt',
            style: const TextStyle(fontSize: 18, color: Colors.purple)),
        )
    ),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Colors.black26))),
  );
}