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
  }

  AppContext.empty() {
  }

  fillStore(String id) {
    uid = id;
    getUserProps();
    getCompletedGames();
    _databaseService.getManagedPreGames(
        id, updateMangedPreRoomStatus);
    _databaseService.getManagedPlayingGames(
        id, updateMangedPlayingRoomStatus);
    _databaseService.getInLobbyRooms(id, updatePreGames);
    _databaseService.getInGameRooms(id, updatePlayingGames);
    // notifyListeners();

  }

  updateMangedPreRoomStatus(dynamic updates) {
    preManagedGames = {};
    if(updates != null) {
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
    notifyListeners();
  }

  updateMangedPlayingRoomStatus(dynamic updates) {
    playingManagedGames = {};
    if(updates != null) {
      dynamic games = (updates is List<Object?>) ? updates : updates.values.toList() ;
      for (var game in games as List<Object?>) {
        if(game != null){
          dynamic hashedMap = jsonDecode(jsonEncode(game));
          var map = HashMap.from(hashedMap);
          GameRoom gameRoom = GameRoom.fromJson(map);
          if (gameRoom.gameOver) {
            getCompletedGames();
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
    notifyListeners();
  }

  updatePreGames(dynamic game){
    preGames = {};
    if(game!=null) {
      dynamic hashedMap = jsonDecode(jsonEncode(game));
      var map = HashMap.from(hashedMap);
      GameRoom gameRoom = GameRoom.fromJson(map);
      if (gameRoom.currentPlayers.contains(uid)) {
        if(gameRoom.isWaiting){
          preGames.update(gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
        }
      }
    }
    notifyListeners();
  }

  updatePlayingGames(dynamic game){
    playingGames = {};
    if(game!=null) {
      dynamic hashedMap = jsonDecode(jsonEncode(game));
      var map = HashMap.from(hashedMap);
      GameRoom gameRoom = GameRoom.fromJson(map);
      if (gameRoom.currentPlayers.contains(uid)) {
        if(!gameRoom.isWaiting){
          if(!playingGames.keys.contains(gameRoom.id)) {
            _databaseService.getQuestionOfGame(gameRoom, getPlayedQuestions);
            _databaseService.getAnswerOfGame(gameRoom, getPlayedAnswers);
          }
          playingGames.update(gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);
          if(gameRoom.gameOver){
            getCompletedGames();
            playingGames.remove(gameRoom.id);
          }
        }
      }
    }
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