import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:incomplete_stories/models/answer.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/services/databaseService.dart';


class AppContext extends ChangeNotifier {
  /// Internal, private state of the cart.
  final DatabaseService _databaseService = DatabaseService();
  late Map<dynamic,GameRoom> preManagedGames = {};
  late Map<dynamic,GameRoom> playingManagedGames = {};
  late Map<dynamic,GameRoom> completedGames = {};
  late Map<dynamic,GameRoom> preGames = {};
  late Map<dynamic,GameRoom> playingGames = {};
  late Map<dynamic,List<Question>> qOfGames = {};
  late Map<dynamic,List<Answer>> aOfGames = {};
  late Map<dynamic,List<Question>> qPlayedGames = {};
  late Map<dynamic,List<Answer>> aPlayedGames = {};

  AppContext() {
    print("init provider");
    _databaseService.getManagedPreGames(
        "y7cPlFnzUNRZi3jTirbOPdW4bbC3", updateRoomStatus);
    _databaseService.getManagedPlayingGames(
        "y7cPlFnzUNRZi3jTirbOPdW4bbC3", updateRoomStatus);
    _databaseService.getInLobbyRooms("a", updateGames);
    _databaseService.getInGameRooms("a", updateGames);
  }

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
                _databaseService.getAnswerOfGame(gameRoom, getAnswers);
              }
              playingManagedGames.update(
                  gameRoom.id, (value) => gameRoom, ifAbsent: () => gameRoom);

            }
          }
        }
      }
    }
    print("Pregames Managed $preManagedGames");
    print("PlayingGames Managed $playingManagedGames");
    notifyListeners();
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
            _databaseService.getAnswerOfGame(gameRoom, getPlayedAnswers);
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
    }
    print("PreGames $preGames");
    print("Playinggames $playingGames");
    notifyListeners();
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
          if(qOfGames.keys.contains(id)){
            qOfGames[id]?.add(_question);
          }
          else {
            qOfGames[id] = [];
            qOfGames[id]?.add(_question);
          }

        }
      }
    }
    print(qOfGames);
    notifyListeners();
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
          if(qPlayedGames.keys.contains(id)){
            qPlayedGames[id]?.add(_question);
          }
          else {
            qPlayedGames[id] = [];
            qPlayedGames[id]?.add(_question);
          }

        }
      }
      print("qPlayedGames $qPlayedGames");
      notifyListeners();
    }

  }

  getAnswers(dynamic id,dynamic answers){
    if(answers != null) {
      aOfGames = {};
      for (var answer in answers.keys.toList()) {
        if (answer != null) {
          dynamic hashedMap = jsonDecode(jsonEncode(answers[answer]));
          var map = HashMap.from(hashedMap);
          Answer _answer = Answer.fromJson(map);
          _answer.id = answer.toString();
          _answer.roomID = id.toString();
          if(aOfGames.keys.contains(id)){
            aOfGames[id]?.add(_answer);
          }
          else {
            aOfGames[id] = [];
            aOfGames[id]?.add(_answer);
          }

        }
      }
      print("aPlayedGames $aPlayedGames");
      notifyListeners();
    }

  }

  getPlayedAnswers(dynamic id,dynamic answers){
    if(answers != null) {
      aPlayedGames = {};
      for (var answer in answers.keys.toList()) {
        if (answer != null) {
          dynamic hashedMap = jsonDecode(jsonEncode(answers[answer]));
          var map = HashMap.from(hashedMap);
          Answer _answer = Answer.fromJson(map);
          _answer.id = answer.toString();
          _answer.roomID = id.toString();
          if(aPlayedGames.keys.contains(id)){
            aPlayedGames[id]?.add(_answer);
          }
          else {
            aPlayedGames[id] = [];
            aPlayedGames[id]?.add(_answer);
          }

        }
      }
      print("aPlayedGames $aPlayedGames");
      notifyListeners();
    }

  }




}