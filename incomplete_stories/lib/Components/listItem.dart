import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/bottomSheet.dart';
import 'package:incomplete_stories/adminView.dart';
import 'package:incomplete_stories/completedView.dart';
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
        title: Center(
          child: Text(
            beginStory,
            style: const TextStyle(fontSize: 14,fontStyle: FontStyle.italic),
          ),
        ),
        subtitle:
        mode == 3 ?
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Cevapsız Sorular : ${questions?.where((q) => q.answer == 3).toList()?.length.toString() ?? "0"}'),
              Text('Cevapsız Tahminler : ${answers?.where((q) => q.isCorrect == 3).toList()?.length.toString() ?? "0"}'),
            ],
          ),
        ) :
        mode == 4 ? Center(child: Text('Sorularım : ${questions?.where((q) => q.ownerID == uid).toList()?.length.toString() ?? "0"}/${questions?.length.toString() ?? "0"}')) : null,
        trailing: Chip(backgroundColor:Colors.white,label: Text('$cPlayerCnt/$mPlayerCnt',
                    style: const TextStyle(fontSize: 15, color: Colors.purple)),
                ),

    ),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Color(0xFFDDDDDD))),
        color: Color(0xFFFFF6EA) ),
  );
}

Widget listItemCompleted(dynamic room,DatabaseService _databaseService,BuildContext context,index) {
  String? cPlayerCnt = room["currentNumberOfPlayers"].toString();
  String? mPlayerCnt = room["maxNumberOfPlayers"].toString();
  String? beginStory = room["bOfStory"];
  String uid = Provider.of<AppContext>(context,listen: false).uid;
  Future<String> getWinnerName() async {
    String name = await _databaseService.getPlayerName(room["winner"]);
    return name;
  }
  return Container(
    padding: const EdgeInsets.all(10),
    child: ListTile(
      onTap: (){
        showAlertDialog(context,room,_databaseService,index);
      },
      leading: room["ownerID"] == uid ? Chip(backgroundColor:Colors.white,label: Text("Mod")) :  Chip(backgroundColor:Colors.white,label: Text("Oyuncu")),
      title: Center(
        child: Text(beginStory!,
          style: const TextStyle(fontSize: 14,fontStyle: FontStyle.italic),
        ),
      ),
      subtitle: FutureBuilder<String>(
        future : getWinnerName(),
        builder: (context, snapshot) {
          return Center(child: Text('Kazanan : ${snapshot.data  ?? "Kazanan Yok"}'));
        }
      ),
      trailing: Chip(backgroundColor:Colors.white,label: Text('$cPlayerCnt/$mPlayerCnt',
          style: const TextStyle(fontSize: 15, color: Colors.deepPurpleAccent)),
      ),

    ),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 2, color: Color(0xFFDDDDDD))),
        color: Color(0xFFFFF6EA) ),
  );


}

showAlertDialog(BuildContext context,dynamic room,DatabaseService _databaseService,index) {

  String? story = room["story"];
  String? correctAns = room["correctAnswer"];
  late Map<String,dynamic> statistics = {};
  for(var i in room["answers"]){
    if(!statistics.keys.toList().contains(i["ownerID"])){
      statistics[i["ownerID"]] = {};
      statistics[i["ownerID"]]["correctA"] = (i["isCorrect"] == 0 ? 1 : 0);
      statistics[i["ownerID"]]["totalA"] = 1;
      statistics[i["ownerID"]]["correctQ"] = 0;
      statistics[i["ownerID"]]["totalQ"] = 0;
    }
    else {
      statistics[i["ownerID"]]["correctA"] +=
      (i["isCorrect"] == 0 ? 1 : 0);
      statistics[i["ownerID"]]["totalA"] += 1;
    }
  }

  for(var i in room["questions"]){
    if(!statistics.keys.toList().contains(i["ownerID"])){
      statistics[i["ownerID"]] = {};
      statistics[i["ownerID"]]["correctQ"] = (i["answer"] == 0 ? 1 : 0);
      statistics[i["ownerID"]]["totalQ"] = 1;
      statistics[i["ownerID"]]["correctA"] = 0;
      statistics[i["ownerID"]]["totalA"] = 0;
    }
    else {
      statistics[i["ownerID"]]["correctQ"] +=
      (i["answer"] == 0 ? 1 : 0);
      statistics[i["ownerID"]]["totalQ"] += 1;
    }
  }
  Future<String> getPlayerName(uid) async {
    String name = await _databaseService.getPlayerName(uid);
    return name;
  }
  List<DataRow> _createRows() {
    return statistics.keys.toList().
        map((id) => DataRow(cells: [
      DataCell(FutureBuilder<String>(
        future: getPlayerName(id),
        builder: (context, snapshot) {
          return Text(snapshot.data ?? "");
        }
      )),
      DataCell(Text('${statistics[id]["correctQ"]}/${statistics[id]["totalQ"]}')),
      DataCell(Text('${statistics[id]["correctA"]}/${statistics[id]["totalA"]}')),
    ]))
        .toList();
  }


  Widget okButton = FlatButton(
    child: Text("Tamam"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Center(child: Text("Oyun Özeti")),
    content: Column(
      children: [
        Text("Oyunun Hikayesi",style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold),),
        SizedBox(height: 15),
        Text(story!),
        SizedBox(height: 15),
        Text("Kazanan Yanıt",style: TextStyle(color: Colors.greenAccent,fontWeight: FontWeight.bold),),
        SizedBox(height: 15),
        Text(correctAns!),
        SizedBox(height: 15),
        DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Text(
                'Oyuncu',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Soru',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Cevap',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: _createRows(),
        ),
        SizedBox(height: 15),
        OutlinedButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return  CompletedView(index: index);
          }));
        }, child: Text("Oyun Geçmişini Gör")),
      ],
    ),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}