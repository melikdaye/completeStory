import 'dart:convert';

class GameRoom {

  late String story = "";
  late String bOfStory = "";
  late bool autoStart = false;
  late int currentNumberOfPlayers = 0;
  late int maxNumberOfPlayers = 1;
  late DateTime date;
  final String ownerID;
  late List<String> currentPlayers = [];
  late bool gameOver = false;
  late bool isWaiting = true;
  late int id;
  GameRoom.empty(this.ownerID);

  GameRoom.fromJson(Map<dynamic, dynamic> json):
      story = json['story'],
      bOfStory = json['bOfStory'] ?? "",
      autoStart = json["autoStart"],
      currentNumberOfPlayers = json["currentNumberOfPlayers"],
      maxNumberOfPlayers = json["maxNumberOfPlayers"],
      date = DateTime.parse(json['date'] as String),
      ownerID = json['ownerID'],
      currentPlayers = List<String>.from(json["currentPlayers"] ?? []),
      gameOver = json["gameOver"],
      id = json["id"],
      isWaiting = json["isWaiting"];

  Map<String, dynamic> toJson() => {
    'story': story,
    'bOfStory' : bOfStory,
    'autoStart': autoStart,
    'currentNumberOfPlayers' : currentNumberOfPlayers,
    'maxNumberOfPlayers' : maxNumberOfPlayers,
    'date' : date.toIso8601String(),
    'ownerID' : ownerID,
    'currentPlayers' : currentPlayers,
    'gameOver' : gameOver,
    'isWaiting' : isWaiting,
    'id' : id,
  };

  @override
  String toString(){
      return('story: $story, ownerID: $ownerID, autoStart : $autoStart , maxNumOfPlayers : $maxNumberOfPlayers');
  }

}