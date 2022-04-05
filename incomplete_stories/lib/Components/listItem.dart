import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/bottomSheet.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/myGames.dart';
import 'package:incomplete_stories/services/databaseService.dart';


Widget listItem(GameRoom room,DatabaseService _databaseService,BuildContext context,mode,dynamic questions) {
  String? cPlayerCnt = room.currentNumberOfPlayers.toString();
  String? mPlayerCnt = room.maxNumberOfPlayers.toString();
  String? beginStory = room.story;
  String? id = room.id.toString();
  Color statusColor = room.isWaiting ? Colors.deepOrangeAccent : Colors.lightGreenAccent.shade700;
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
        onTap: (){
            bottomSheet(room,questions,mode, context);
        },
        leading:
        mode==0 ? Text(id , style: const TextStyle(fontSize: 18)) :  Chip(label: Text(room.isWaiting ? "Lobby" : "InGame",
        style: TextStyle(fontSize: 18, color: statusColor )),
        ),
        title: Text(
          beginStory,
          style: const TextStyle(fontSize: 14,fontStyle: FontStyle.italic),
        ),
        subtitle:
        mode == 3 ?
        Text('Cevapsız Sorular : ${questions?.where((q) => q.answer == 4).toList()?.length.toString() ?? "0"}') :
        mode == 4 ? Text('Sorularım : ${questions?.where((q) => q.ownerID == "a").toList()?.length.toString() ?? "0"}/${questions?.length.toString() ?? "0"}') : null,
        trailing: Chip(label: Text('$cPlayerCnt/$mPlayerCnt',
                    style: const TextStyle(fontSize: 18, color: Colors.purple)),
                ),

    ),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Colors.deepOrangeAccent)),
        color: Colors.white ),
  );
}