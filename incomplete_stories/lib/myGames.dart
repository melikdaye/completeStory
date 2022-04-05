import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/listItem.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';

import 'Components/bottomBar.dart';

class MyGames extends StatefulWidget {
  const MyGames({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyGames> createState() => _MyGamesState();
}

class _MyGamesState extends State<MyGames> {
  final DatabaseService _databaseService = DatabaseService();
  late Map<dynamic,GameRoom> preManagedGames = Provider.of<AppContext>(context,listen:true).preManagedGames;
  late Map<dynamic,GameRoom> playingManagedGames = Provider.of<AppContext>(context,listen:true).playingManagedGames;
  late Map<dynamic,GameRoom> completedGames = Provider.of<AppContext>(context,listen:true).completedGames;
  late Map<dynamic,GameRoom> preGames = Provider.of<AppContext>(context,listen:true).preGames;
  late Map<dynamic,GameRoom> playingGames = Provider.of<AppContext>(context,listen:true).playingGames;
  late Map<dynamic,List<Question>> qOfGames = Provider.of<AppContext>(context,listen:true).qOfGames;
  late Map<dynamic,List<Question>> qPlayedGames = Provider.of<AppContext>(context,listen:true).qPlayedGames;

  updateRoomStatus(dynamic updates){
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
            if(!playingManagedGames.keys.contains(gameRoom.id)) {
              _databaseService.getQuestionOfGame(gameRoom, getQuestions);
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

  updateGames(dynamic game){
    if(game!=null) {
      dynamic hashedMap = jsonDecode(jsonEncode(game));
      var map = HashMap.from(hashedMap);
      GameRoom gameRoom = GameRoom.fromJson(map);
      if (gameRoom.currentPlayers.contains("a")) {
        if(gameRoom.isWaiting){
        preGames.update(
            gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
        }else{

          if(!playingGames.keys.contains(gameRoom.id)) {
            _databaseService.getQuestionOfGame(gameRoom, getPlayedQuestions);
          }
          playingGames.update(
              gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
          if(preGames.keys.contains(gameRoom.id)){
            preGames.remove(gameRoom.id);
            _databaseService.getInGame("a", gameRoom);
          }

        }
      } else {
        if(gameRoom.isWaiting) {
          preGames.remove(gameRoom.id);
        }else{
          playingGames.remove(gameRoom.id);
        }
      }
      if (mounted) {
        setState(() {
          preGames = preGames;
          playingGames = playingGames;
        });
      }
    }
    print("preGames $preGames");
    print("preGames $playingGames");
  }

  showAlertDialog(BuildContext context,int count) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("Tamam"),
      onPressed: () { Navigator.pop(context); },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Ceveplanmamış Soru Sayısı"),
      content: Text("$count"),
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
  getQuestions(dynamic id,dynamic questions){
    if(questions != null) {
      qOfGames = {};
      for (var question in questions.keys.toList()) {
        if (question != null) {
          dynamic hashedMap = jsonDecode(jsonEncode(questions[question]));
          var map = HashMap.from(hashedMap);
          Question _question = Question.fromJson(map);
          _question.id = question.toString();
          _question.roomID = id.toString();
          print(_question.answer);
          if(qOfGames.keys.contains(id)){
            qOfGames[id]?.add(_question);
          }
          else {
            qOfGames[id] = [];
            qOfGames[id]?.add(_question);
          }

        }
      }
      if (mounted) {
        setState(() {
          qOfGames = qOfGames;
        });
      }
    }
  }

  getPlayedQuestions(dynamic id,dynamic questions){
    if(questions != null) {
      qPlayedGames = {};
      for (var question in questions.keys.toList()) {
        if (question != null) {
          dynamic hashedMap = jsonDecode(jsonEncode(questions[question]));
          var map = HashMap.from(hashedMap);
          Question _question = Question.fromJson(map);
          _question.id = question.toString();
          _question.roomID = id.toString();
          print(_question.id);
          if(qPlayedGames.keys.contains(id)){
            qPlayedGames[id]?.add(_question);
          }
          else {
            qPlayedGames[id] = [];
            qPlayedGames[id]?.add(_question);
          }

        }
      }
      if (mounted) {
        setState(() {
          qPlayedGames = qPlayedGames;
        });
      }
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   print("initState");
  //   _databaseService.getManagedPreGames("y7cPlFnzUNRZi3jTirbOPdW4bbC3",updateRoomStatus);
  //   _databaseService.getManagedPlayingGames("y7cPlFnzUNRZi3jTirbOPdW4bbC3",updateRoomStatus);
  //   _databaseService.getInLobbyRooms("a",updateGames);
  //   _databaseService.getInGameRooms("a",updateGames);
  //
  // }
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

            Column(
              children: [
                LimitedBox(
                    child:
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: preGames.keys.length,
                        itemBuilder: (_, index) {
                          return listItem(preGames[preGames.keys.toList()[index]] as GameRoom,_databaseService,context,1,null);
                        }
                    ),
                ),
                LimitedBox(child:
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: playingGames.keys.length,
                    itemBuilder: (_, index) {
                      return listItem(playingGames[playingGames.keys.toList()[index]] as GameRoom,_databaseService,context,4,qPlayedGames[playingGames.keys.toList()[index]]);
                    }
                ),
                ),
              ],
            ),

           Column(
             children: [
               LimitedBox(
                     child:
               ListView.builder(
                      shrinkWrap: true,
                      itemCount: preManagedGames.keys.length,
                      itemBuilder: (_, index) {
                        return listItem(preManagedGames[preManagedGames.keys.toList()[index]] as GameRoom,_databaseService,context,2,null);
                      }
                )
               ),
               LimitedBox(child:
               ListView.builder(
                   shrinkWrap: true,
                   itemCount: playingManagedGames.keys.length,
                   itemBuilder: (_, index) {
                     return listItem(playingManagedGames[playingManagedGames.keys.toList()[index]] as GameRoom,_databaseService,context,3,qOfGames[playingManagedGames.keys.toList()[index]]);
                   }
               )
               ),
             ],
           ),

            ListView.builder(
                  itemCount: completedGames.keys.length,
                  itemBuilder: (_, index) {
                    return listItem(completedGames[completedGames.keys.toList()[index]] as GameRoom,_databaseService,context,2,null);
                  }
              ),

          ],
        ),
        bottomNavigationBar: const BottomNavigator(),
      ),
    );
  }
}