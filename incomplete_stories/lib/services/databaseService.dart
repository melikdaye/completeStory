import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:incomplete_stories/models/answer.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  DatabaseReference getCollectionRef(String collectionName){
    return FirebaseDatabase.instance.ref(collectionName);
  }

  Future<void> createGameRoom(GameRoom gameRoom) async {
    //print(gameRoom.toString());
    DatabaseReference refRoomCount = getCollectionRef('numberOfRooms');
    final snapshot  = await refRoomCount.get();
    if (snapshot.exists) {
      String numberOfRooms = snapshot.value.toString();
      //print(numberOfRooms);
      String uid  = gameRoom.ownerID;
      gameRoom.id = int.parse(numberOfRooms);
      DatabaseReference ref = getCollectionRef('rooms/pre/$uid/$numberOfRooms');
      //print(gameRoom.toJson());
      await ref.set(gameRoom.toJson());
      await refRoomCount.set(int.parse(numberOfRooms) + 1);
    }
  }

  Future getInLobbyRooms(String uid,void Function(dynamic updates) callBack) async {
    DatabaseReference ref = getCollectionRef('users/$uid/pre');
    Stream<DatabaseEvent> gameIDStream = ref.onValue;
    gameIDStream.listen((event) {
      dynamic games = event.snapshot.value;
      if(games != null) {
        print("ınlobby rooms $games");
        dynamic _games = (games is Iterable<dynamic>) ? games : games.values.toList() ;
        for (var id in _games as Iterable<dynamic>) {
          //print(id);
          String path = id.toString().replaceAll("-", "/");
          //print(path);
          DatabaseReference pref = getCollectionRef('rooms/pre/$path');
          pref.onValue.listen((event) {
            //print("add ${event.snapshot.value}");
            callBack(event.snapshot.value);
          });
        }
      }
    });
  }

  Future getInGameRooms(String uid,void Function(dynamic updates) callBack) async {
    DatabaseReference ref = getCollectionRef('users/$uid/playing');
    Stream<DatabaseEvent> gameIDStream = ref.onValue;
    gameIDStream.listen((event) {
      dynamic games = event.snapshot.value;
      if(games != null) {
        dynamic _games = (games is Iterable<dynamic>) ? games : games.values.toList() ;
        for (var id in _games as Iterable<dynamic>) {
          //print(id);
          String path = id.toString().replaceAll("-", "/");
          //print(path);
          DatabaseReference pref = getCollectionRef('rooms/playing/$path');
          pref.onValue.listen((event) {
            //print("add ${event.snapshot.value}");
            callBack(event.snapshot.value);
          });
        }
      }
    });
  }

  Future getManagedPreGames(String uid,void Function(dynamic updates) callBack) async {
    DatabaseReference preRef = getCollectionRef('rooms/pre/$uid');
    Stream<DatabaseEvent> preStream = preRef.onValue;
    preStream.listen((event) {
      callBack(event.snapshot.value);
    });
  }

  Future getManagedPlayingGames(String uid,void Function(dynamic updates) callBack) async {
    DatabaseReference inGameRef = getCollectionRef('rooms/playing/$uid');
    Stream<DatabaseEvent> inGameStream = inGameRef.onValue;
    inGameStream.listen((event) {
      callBack(event.snapshot.value);
    });
  }

  Future<void> transferRoomToInGame(GameRoom gameRoom) async {
    String uid  = gameRoom.ownerID;
    int id  = gameRoom.id;
    DatabaseReference ref = getCollectionRef('rooms/pre/$uid/$id');
    await ref.remove();
    gameRoom.isWaiting = false;
    DatabaseReference newRef = getCollectionRef('rooms/playing/$uid/$id');
    await newRef.set(gameRoom.toJson());
    for(var player in gameRoom.currentPlayers){
      getInGame(player, gameRoom);
    }
  }

  Future<void> searchAvailableGames(void Function(dynamic avialableRooms) getRooms,
      void Function(dynamic removedRooms) getRemovedRooms,
      void Function(dynamic updates) getChanges)async {
    DatabaseReference ref = getCollectionRef('rooms/pre');
    ref.onChildAdded.listen((event) {
      getRooms(event.snapshot.value);
    });
    ref.onChildChanged.listen((event) {
      getChanges(event.snapshot.value);
    });
    ref.onChildRemoved.listen((event) {
      getRemovedRooms(event.snapshot.value);
    });

  }

  Future<void> joinGame(String uid,GameRoom gameRoom)async {
    DatabaseReference ref = getCollectionRef('rooms/pre/${gameRoom.ownerID}/${gameRoom.id}');
    await ref.update({"currentNumberOfPlayers":gameRoom.currentNumberOfPlayers+1});
    gameRoom.currentPlayers.add(uid);
    await ref.update({"currentPlayers":gameRoom.currentPlayers});
    DatabaseReference userRef = getCollectionRef('users/$uid/pre/${gameRoom.id}');
    await userRef.set('${gameRoom.ownerID}-${gameRoom.id}');

  }
  Future<void> leaveGame(String uid,GameRoom gameRoom,String gameType)async {
    DatabaseReference ref = getCollectionRef('rooms/$gameType/${gameRoom.ownerID}/${gameRoom.id}');
    await ref.update({"currentNumberOfPlayers":gameRoom.currentNumberOfPlayers-1});
    gameRoom.currentPlayers.remove(uid);
    await ref.update({"currentPlayers":gameRoom.currentPlayers});
    DatabaseReference userRef = getCollectionRef('users/$uid/$gameType/${gameRoom.id}');
    await userRef.remove();
  }

  Future<void> getInGame(String uid,GameRoom gameRoom)async {
    DatabaseReference preRef = getCollectionRef('users/$uid/pre/${gameRoom.id}');
    await preRef.remove();
    DatabaseReference playingRef = getCollectionRef('users/$uid/playing/${gameRoom.id}');
    await playingRef.set('${gameRoom.ownerID}-${gameRoom.id}');
  }

  Future<void> addQuestionToGame(Question question,GameRoom gameRoom)async {
    DatabaseReference roomRef = getCollectionRef('questions/${gameRoom.id}');
    final newKey = roomRef.push().key;
    DatabaseReference qRef = getCollectionRef('questions/${gameRoom.id}/$newKey');
    await qRef.set(question.toJson());
    await setTotalQ(question.ownerID);

  }

  Future<void> getQuestionOfGame(GameRoom gameRoom,void Function(dynamic id,dynamic updates) callBack)async {
    DatabaseReference qRef = getCollectionRef('questions/${gameRoom.id}');
    Stream<DatabaseEvent> qStream = qRef.onValue;
    qStream.listen((event) {
      callBack(gameRoom.id,event.snapshot.value);
    });
  }

  Future<void> getAnswerOfGame(GameRoom gameRoom,void Function(dynamic id,dynamic updates) callBack)async {
    DatabaseReference qRef = getCollectionRef('answers/${gameRoom.id}');
    Stream<DatabaseEvent> qStream = qRef.onValue;
    qStream.listen((event) {
      callBack(gameRoom.id,event.snapshot.value);
    });
  }
  Future<void> updateAnswerOfQuestion(Question question)async {
    DatabaseReference qRef = getCollectionRef(
        'questions/${question.roomID}/${question.id}');
    qRef.update({"answer": question.answer});
  }
  Future<void> addAnswerToGame(Answer answer,GameRoom gameRoom)async {
    DatabaseReference roomRef = getCollectionRef('answers/${gameRoom.id}');
    final newKey = roomRef.push().key;
    DatabaseReference qRef = getCollectionRef('answers/${gameRoom.id}/$newKey');
    await qRef.set(answer.toJson());
    await setTotalA(answer.ownerID);
  }

  Future<void> replyAnswer(Answer answer)async {
    DatabaseReference qRef = getCollectionRef(
        'answers/${answer.roomID}/${answer.id}');
    qRef.update({"isCorrect": answer.isCorrect});
  }

  Future<void> updateViewedPlayers(Question question,String uid)async {
    DatabaseReference qRef = getCollectionRef(
        'questions/${question.roomID}/${question.id}');
    question.viewedBy.add(uid);
    qRef.update({"viewedBy": question.viewedBy});
  }

  Future<void> updateSavedPlayers(Question question,String uid)async {
    DatabaseReference qRef = getCollectionRef(
        'questions/${question.roomID}/${question.id}');
    question.savedBy.add(uid);
    qRef.update({"savedBy": question.viewedBy});
  }

  Future<void> removeGame(GameRoom gameRoom) async {
    late String gameStatus;
    if(gameRoom.isWaiting){
      gameStatus = "pre";
    }
    else{
      gameStatus = "playing";
    }
    DatabaseReference ref = getCollectionRef('rooms/$gameStatus/${gameRoom.ownerID}/${gameRoom.id}');
    await ref.remove();
    for(var player in gameRoom.currentPlayers){
      DatabaseReference userRef = getCollectionRef('users/$player/$gameStatus/${gameRoom.id}');
      await userRef.remove();
    }
    DatabaseReference qRef = getCollectionRef('questions/${gameRoom.id}');
    await qRef.remove();
    DatabaseReference aRef = getCollectionRef('answers/${gameRoom.id}');
    await aRef.remove();
  }

  Future<bool> createUser(String uid) async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    bool exist = false;
    await users.where("uid",isEqualTo: uid).get().then((value) {
      print("exist");
      exist = true;}).catchError((onError){
        print("creating");
      users.add({
        'uid' : uid,
        'credits': 50,
        "playerName" : "",
        "winGames" : 0,
        "playedGames" : 0,
        "correctQ" : 0,
        "correctA" : 0,
        "totalQ" : 0,
        "totalA" : 0,
      }).then((value) {
        print("created");
        exist = true;}).catchError((error) {
          print("failed");exist = false;});
    });
    return exist;
  }

  Future<Map> getUserProps(String uid) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    late dynamic userData = {};
    await users.where("uid",isEqualTo: uid).get().then((value) {
      userData = jsonDecode(jsonEncode(value.docs.first.data()));
      print("getUserProps $userData");
    }).catchError((onError){});

    return userData;
  }

  Future<void> finishGame(AppContext context,GameRoom room,Answer answer,dynamic winnerID) async {

    DatabaseReference ref = getCollectionRef('rooms/playing/${room.ownerID}/${room.id}');
    await ref.update({"gameOver":true});
    int willEarn = (winnerID!=null) ? 10 : 1;

    for(var user in room.currentPlayers){
      willEarn = 10;
      int gameWin = 0;
      if(user == winnerID){
         willEarn = 50;
         gameWin = 1;
      }
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      var querySnapshot = await users.where("uid",isEqualTo: user).get();
      for(var doc in querySnapshot.docs){
          await doc.reference.update({
            "credits" : doc['credits'] + willEarn,
            "playedGames" : (doc.data().toString().contains("playedGames")? doc['playedGames'] :0) + 1,
            "winGames" : (doc.data().toString().contains("winGames")? doc['winGames'] :0) + gameWin,
            "correctA" : (doc.data().toString().contains("correctA")? doc['correctA'] :0) + gameWin,
          });
      }
    }
    int adminCredits = winnerID!=null ? 50 : -5;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await users.where("uid",isEqualTo: room.ownerID).get();
    for(var doc in querySnapshot.docs){
      await doc.reference.update({
        "credits" : doc['credits'] + adminCredits,
        "manageGames" : (doc.data().toString().contains("manageGames")?doc["manageGames"] :0) + 1,
      });
    }
    CollectionReference rooms = FirebaseFirestore.instance.collection('rooms');
    await rooms.add({
       ...(room.toJson()),
      "winner" : winnerID,
      "correctAnswer" : answer.answer,
      "questions" : context.qOfGames[room.id]?.map((e) => e.toJson()).toList(),
      "answers" : context.aOfGames[room.id]?.map((e) => e.toJson()).toList(),
    });

    removeGame(room);

  }

  Future<List> getCompletedGames (String uid) async{
    CollectionReference games = FirebaseFirestore.instance.collection('rooms');
    var managedQuery = await games.where("ownerID",isEqualTo: uid).get();
    var playedQuery = await games.where("currentPlayers",arrayContains: uid).get();
    List compGames = [];
    for(var game in managedQuery.docs){
        compGames.add(game.data());
    }
    for(var game in playedQuery.docs){
      compGames.add(game.data());
    }

    return compGames;

  }

  Future<bool> buySomething(String uid,dynamic price) async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await users.where("uid",isEqualTo: uid).get();
    for(var doc in querySnapshot.docs){
         if(doc['credits']>=price){
           await doc.reference.update({
             "credits" : doc['credits'] - price,
           });
           return true;
         }else{
           return false;
         }
    }
    return false;
  }

  Future<String> getPlayerName (String uid) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await users.where("uid", isEqualTo: uid).get();
    for (var doc in querySnapshot.docs) {
      print(doc.data().toString());
      if (doc.data().toString().contains("playerName")) {
        print(doc["playerName"]);
        return doc["playerName"] ?? "";
      }
    }
    return "";
  }

  Future<void> setPlayerName(String uid,String playerName) async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await users.where("uid",isEqualTo: uid).get();
    for(var doc in querySnapshot.docs){

        await doc.reference.update({
          "playerName" : playerName,
        });
    }

  }

  Future<void> setTotalQ(String uid) async{
    print(uid);
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await users.where("uid",isEqualTo: uid).get();
    for(var doc in querySnapshot.docs){

      await doc.reference.update({
        "totalQ" : (doc.data().toString().contains("totalQ")? doc['totalQ'] :0) + 1,
      });
    }

  }
  Future<void> setTotalA(String uid) async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await users.where("uid",isEqualTo: uid).get();
    for(var doc in querySnapshot.docs){

      await doc.reference.update({
        "totalA" : (doc.data().toString().contains("totalA")? doc['totalA'] :0) + 1,
      });
    }

  }
  Future<void> setCorrectQ(String uid) async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await users.where("uid",isEqualTo: uid).get();
    for(var doc in querySnapshot.docs){

      await doc.reference.update({
        "correctQ" : (doc.data().toString().contains("correctQ")? doc['correctQ'] :0) + 1,
      });
    }

  }



}