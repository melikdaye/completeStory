import 'dart:convert';

class Answer {

  late String answer = "";
  late int isCorrect = 3;
  late DateTime date;
  final String ownerID;
  late String id;
  late String roomID;
  Answer.empty(this.ownerID);

  Answer.fromJson(Map<dynamic, dynamic> json):
        answer = json['answer'],
        date = DateTime.parse(json['date'] as String),
        ownerID = json['ownerID'],
        isCorrect = json["isCorrect"];

  Map<String, dynamic> toJson() => {
    'answer': answer,
    'date' : date.toIso8601String(),
    'ownerID' : ownerID,
    'isCorrect' : isCorrect ,
  };

}