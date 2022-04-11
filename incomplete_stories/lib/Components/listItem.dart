import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/bottomSheet.dart';
import 'package:incomplete_stories/adminView.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/myGames.dart';
import 'package:incomplete_stories/playerRoom.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';


Widget listItem(GameRoom room,DatabaseService _databaseService,BuildContext context,mode,dynamic questions) {
  String? cPlayerCnt = room.currentNumberOfPlayers.toString();
  String? mPlayerCnt = room.maxNumberOfPlayers.toString();
  String? beginStory = room.bOfStory;
  String? id = room.id.toString();
  Color statusColor = room.isWaiting ? Colors.deepOrangeAccent : Colors.lightGreenAccent.shade700;
  dynamic answers  = Provider.of<AppContext>(context, listen: true).aOfGames[room.id];
  dynamic uid = Provider.of<AppContext>(context, listen: true).uid;
  return Container(
    padding: const EdgeInsets.all(10),
    child: ListTile(
        onLongPress: () {
          switch(mode){
            case 0:

              _databaseService.joinGame(uid, room);
              Provider.of<AppContext>(context,listen: false).changeBottomBarIndex(2);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return  const MyGames();
              }));
              break;
            case 1:
              _databaseService.leaveGame(uid, room,"pre");
              break;
            case 2:
              break;
          }
        },
        onTap: (){
            if(mode == 4){
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return  PlayerRoom(roomID: room.id);
              }));
            }
            if(mode == 3){
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return  AdminView(roomID: room.id);
              }));
            }
            if(mode == 2 || mode == 1 || mode == 0){
              bottomSheet(room,null, mode, context);
            }

        },
        leading:
        mode==0 ? Text(id , style: const TextStyle(fontSize: 18)) :  Chip(backgroundColor:Colors.white,label: Text(room.isWaiting ? "Beklemede" : "Oyunda",
        style: TextStyle(fontSize: 14, color: statusColor )),
        ),
        title: Padding(
          padding: mode == 0 ? EdgeInsets.only(left: 45.0) : EdgeInsets.all(0),
          child: Text(
            beginStory,
            style: const TextStyle(fontSize: 14,fontStyle: FontStyle.italic),
          ),
        ),
        subtitle:
        mode == 3 ?
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Cevapsız Sorular : ${questions?.where((q) => q.answer == 3).toList()?.length.toString() ?? "0"}'),
            Text('Cevapsız Tahminler : ${answers?.where((q) => q.isCorrect == 3).toList()?.length.toString() ?? "0"}'),
          ],
        ) :
        mode == 4 ? Text('Sorularım : ${questions?.where((q) => q.ownerID == uid).toList()?.length.toString() ?? "0"}/${questions?.length.toString() ?? "0"}') : null,
        trailing: Chip(backgroundColor:Colors.white,label: Text('$cPlayerCnt/$mPlayerCnt',
                    style: const TextStyle(fontSize: 15, color: Colors.purple)),
                ),

    ),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Color(0xFFDDDDDD))),
        color: Color(0xFFEEEEEE) ),
  );
}

Widget listItemCompleted(dynamic room,DatabaseService _databaseService,BuildContext context) {
  String? cPlayerCnt = room["currentNumberOfPlayers"].toString();
  String? mPlayerCnt = room["maxNumberOfPlayers"].toString();
  String? beginStory = room["bOfStory"];
  String? id = room["id"].toString();
  return Container(
    padding: const EdgeInsets.all(10),
    child: ListTile(
      onLongPress: () {

      },
      onTap: (){

      },
      leading: Text(id , style: const TextStyle(fontSize: 18)),
      title: Padding(
        padding:  EdgeInsets.only(left: 45.0) ,
        child: Text(beginStory!,
          style: const TextStyle(fontSize: 14,fontStyle: FontStyle.italic),
        ),
      ),
      subtitle: Text('${room["winner"]}'),
      trailing: Chip(backgroundColor:Colors.white,label: Text('$cPlayerCnt/$mPlayerCnt',
          style: const TextStyle(fontSize: 15, color: Colors.deepPurpleAccent)),
      ),

    ),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 2, color: Color(0xFFDDDDDD))),
        color: Color(0xFFEEEEEE) ),
  );
}