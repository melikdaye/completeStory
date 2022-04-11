import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:incomplete_stories/models/answer.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppContext extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  late Map<dynamic,GameRoom> preManagedGames = {};
  late Map<dynamic,GameRoom> playingManagedGames = {};
  // late Map<dynamic,GameRoom> completedGames = {};
  late Map<dynamic,GameRoom> preGames = {};
  late Map<dynamic,GameRoom> playingGames = {};
  late Map<dynamic,List<Question>> qOfGames = {};
  late Map<dynamic,List<Answer>> aOfGames = {};
  late Map<dynamic,List<Question>> qPlayedGames = {};
  late Map<dynamic,List<Answer>> aPlayedGames = {};
  late List completedGames = [];
  late SharedPreferences prefs;
  late Map userProps = {};
  late dynamic uid = null;
  late String playerName;
  late dynamic credits;

  addCredits (dynamic amount) {
     userProps["credits"] += amount;
     notifyListeners();
  }


  late int selectedIndexBottomBar = 2;

  Future<void> getSharedPreferences() async { // method
      prefs = await  SharedPreferences.getInstance();
  }

  Future<void> getCompletedGames() async { // method
    completedGames = await  _databaseService.getCompletedGames(uid);
  }
  Future<void> getUserProps() async { // method
    userProps = await  _databaseService.getUserProps(uid);
    print("userprops $userProps");
  }

  AppContext.empty() {
    print("empty provider");
  /*  _databaseService.getManagedPreGames(
        "y7cPlFnzUNRZi3jTirbOPdW4bbC3", updateRoomStatus);
    _databaseService.getManagedPlayingGames(
        "y7cPlFnzUNRZi3jTirbOPdW4bbC3", updateRoomStatus);*/
  }

  fillStore(String id) {
    print("init provider");
    uid = id;
    getUserProps();

    _databaseService.getManagedPreGames(
        "y7cPlFnzUNRZi3jTirbOPdW4bbC3", updateMangedPreRoomStatus);
    _databaseService.getManagedPlayingGames(
        "y7cPlFnzUNRZi3jTirbOPdW4bbC3", updateMangedPlayingRoomStatus);
    _databaseService.getInLobbyRooms(id, updateGames);
    _databaseService.getInGameRooms(id, updateGames);
    // notifyListeners();

  }

  updateMangedPreRoomStatus(dynamic updates) {
    print("updateRoomStatus $updates");
    preManagedGames = {};
    if(updates != null) {
      print(updates.runtimeType);
      dynamic games = (updates is List<Object?>) ? updates : updates.values
          .toList();
      for (var game in games as List<Object?>) {
        if (game != null) {
          dynamic hashedMap = jsonDecode(jsonEncode(game));
          var map = HashMap.from(hashedMap);
          GameRoom gameRoom = GameRoom.fromJson(map);

          preManagedGames.update(
              gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
        }
      }
    }

    print("Pregames Managed $preManagedGames");
    notifyListeners();
  }

  updateMangedPlayingRoomStatus(dynamic updates) {
    print("updateRoomStatus $updates");
    playingManagedGames = {};
    if(updates != null) {
      print(updates.runtimeType);
      dynamic games = (updates is List<Object?>) ? updates : updates.values.toList() ;
      for (var game in games as List<Object?>) {
        if(game != null){
          dynamic hashedMap = jsonDecode(jsonEncode(game));
          var map = HashMap.from(hashedMap);
          GameRoom gameRoom = GameRoom.fromJson(map);
          if (gameRoom.gameOver) {
            getCompletedGames();
            // completedGames.update(
            //     gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
            playingManagedGames.remove(gameRoom.id);
          }
          else {
              if(!playingManagedGames.keys.contains(gameRoom.id)) {
                _databaseService.getQuestionOfGame(gameRoom, getQuestions);
                _databaseService.getAnswerOfGame(gameRoom, getAnswers);
              }
              playingManagedGames.update(
                  gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);

          }

        }
      }
    }
    print("PlayingGames Managed $playingManagedGames");
    notifyListeners();
  }

  updateGames(dynamic game){
    if(game!=null) {
      dynamic hashedMap = jsonDecode(jsonEncode(game));
      var map = HashMap.from(hashedMap);
      GameRoom gameRoom = GameRoom.fromJson(map);
      if (gameRoom.currentPlayers.contains(uid)) {
        if(gameRoom.isWaiting){
          preGames.update(
              gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
        }else{

          if(!playingGames.keys.contains(gameRoom.id)) {
            _databaseService.getQuestionOfGame(gameRoom, getPlayedQuestions);
            _databaseService.getAnswerOfGame(gameRoom, getPlayedAnswers);
          }
          playingGames.update(
              gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
          if(preGames.keys.contains(gameRoom.id)){
            preGames.remove(gameRoom.id);
            _databaseService.getInGame(uid, gameRoom);
          }

        }
        if(gameRoom.gameOver){
          playingGames.remove(gameRoom.id);
        }
      } else {
        if(gameRoom.isWaiting) {
          preGames.remove(gameRoom.id);
        }else{
          playingGames.remove(gameRoom.id);
        }
      }
    }
    print("PreGames $preGames");
    print("Playinggames $playingGames");
    notifyListeners();
  }

  getQuestions(dynamic id,dynamic questions){
    if(questions != null) {
      qOfGames[id] = [];
      for (var question in questions.keys.toList()) {
        if (question != null) {
          dynamic hashedMap = jsonDecode(jsonEncode(questions[question]));
          var map = HashMap.from(hashedMap);
          Question _question = Question.fromJson(map);
          _question.id = question.toString();
          _question.roomID = id.toString();
          qOfGames[id]?.add(_question);
        }
      }
    }
    print(qOfGames);
    notifyListeners();
  }

  getPlayedQuestions(dynamic id,dynamic questions){
    if(questions != null) {
      qPlayedGames[id] = [];
      for (var question in questions.keys.toList()) {
        if (question != null) {
          dynamic hashedMap = jsonDecode(jsonEncode(questions[question]));
          var map = HashMap.from(hashedMap);
          Question _question = Question.fromJson(map);
          _question.id = question.toString();
          _question.roomID = id.toString();
          qPlayedGames[id]?.add(_question);
        }
      }
      print("qPlayedGames $qPlayedGames");
      notifyListeners();
    }

  }

  getAnswers(dynamic id,dynamic answers){
    if(answers != null) {
      aOfGames[id] = [];
      for (var answer in answers.keys.toList()) {
        if (answer != null) {
          dynamic hashedMap = jsonDecode(jsonEncode(answers[answer]));
          var map = HashMap.from(hashedMap);
          Answer _answer = Answer.fromJson(map);
          _answer.id = answer.toString();
          _answer.roomID = id.toString();
          aOfGames[id]?.add(_answer);
        }
      }
      print("aOfGames $aOfGames");
      notifyListeners();
    }

  }

  getPlayedAnswers(dynamic id,dynamic answers){
    if(answers != null) {
      aPlayedGames[id] = [];
      for (var answer in answers.keys.toList()) {
        if (answer != null) {
          dynamic hashedMap = jsonDecode(jsonEncode(answers[answer]));
          var map = HashMap.from(hashedMap);
          Answer _answer = Answer.fromJson(map);
          _answer.id = answer.toString();
          _answer.roomID = id.toString();
          aPlayedGames[id]?.add(_answer);
        }
      }
      print("aPlayedGames $aPlayedGames");
      notifyListeners();
    }

  }

  changeBottomBarIndex(int newIndex){
    selectedIndexBottomBar = newIndex;
    notifyListeners();
  }

  setUID(String uid){
    uid = uid;
    notifyListeners();
  }
  setPlayerName(String playerName){
    userProps["playerName"] = playerName;
    notifyListeners();
  }
  incTotalA(){
    userProps["totalA"] = (userProps["totalA"] ?? 0) + 1 ;
    notifyListeners();
  }
  incTotalQ(){
    userProps["totalQ"] = (userProps["totalQ"] ?? 0) + 1 ;
    notifyListeners();
  }



}