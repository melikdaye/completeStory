import 'dart:convert';

class Question {

  late String question = "";
  late DateTime date;
  final String ownerID;
  late int answer = 3;
  late List<String> viewedBy = [];
  late List<String> savedBy = [];
  late String id;
  late String roomID;
  Question.empty(this.ownerID);

  Question.fromJson(Map<dynamic, dynamic> json):
        question = json['question'],
        date = DateTime.parse(json['date'] as String),
        ownerID = json['ownerID'],
        viewedBy = List<String>.from(json["viewedBy"] ?? []),
        savedBy = List<String>.from(json["savedBy"] ?? []),
        answer = json["answer"];

  Map<String, dynamic> toJson() => {
    'question': question,
    'date' : date.toIso8601String(),
    'ownerID' : ownerID,
    'viewedBy' : viewedBy,
    'savedBy' : savedBy,
    'answer' : answer
  };

}