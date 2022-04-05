import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';

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
      final games = event.snapshot.value;
      if(games != null) {
        for (var id in games as Iterable<dynamic>) {
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
      final games = event.snapshot.value;
      if(games != null) {
        for (var id in games as Iterable<dynamic>) {
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
    DatabaseReference userRef = getCollectionRef('users/$uid/pre');
    await userRef.set({'${gameRoom.id}':'${gameRoom.ownerID}-${gameRoom.id}'});

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
    DatabaseReference preRef = getCollectionRef('users/$uid/pre');
    await preRef.remove();
    DatabaseReference playingRef = getCollectionRef('users/$uid/playing');
    await playingRef.set({'${gameRoom.id}':'${gameRoom.ownerID}-${gameRoom.id}'});
  }

  Future<void> addQuestionToGame(Question question,GameRoom gameRoom)async {
    DatabaseReference roomRef = getCollectionRef('questions/${gameRoom.id}');
    final newKey = roomRef.push().key;
    DatabaseReference qRef = getCollectionRef('questions/${gameRoom.id}/$newKey');
    await qRef.set(question.toJson());
  }

  Future<void> getQuestionOfGame(GameRoom gameRoom,void Function(dynamic id,dynamic updates) callBack)async {
    DatabaseReference qRef = getCollectionRef('questions/${gameRoom.id}');
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

}