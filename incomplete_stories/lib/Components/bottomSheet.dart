
import 'package:flutter/material.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/services/databaseService.dart';
List<String> possibleAns = <String>['Evet', 'Hayır', 'Alakasız'];

Future listUser(context,GameRoom gameRoom){
  final DatabaseService _databaseService = DatabaseService();
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for(var player in gameRoom.currentPlayers)
              ListTile(
              leading: const Icon(Icons.person),
              title: Text(player),
              trailing: IconButton(onPressed: () {
                _databaseService.leaveGame(player, gameRoom, gameRoom.isWaiting?"pre":"playing");
              }, icon: Icon(Icons.exit_to_app),
              ),

            ),
          ],
        );
      });
}


showAlertDialog(BuildContext context,dynamic question,int index) {
  final DatabaseService _databaseService = DatabaseService();
  // set up the button
  Widget cancelButton = TextButton(
    child: Text("Vazgeç"),
    onPressed: () { Navigator.pop(context); },
  );

  Widget okButton = TextButton(
    child: Text("Cevapla"),
    onPressed: () {
      question.answer = index;
      _databaseService.updateAnswerOfQuestion(question);
      Navigator.pop(context); },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Sorunun Cevabı"),
    content: Text(possibleAns[index]),
    actions: [
      okButton,
      cancelButton
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

Future answerQuestion(context,dynamic questions){
  print(questions);
  dynamic unAnswered = questions?.where((q) => q.answer == 3).toList();
  dynamic answered = questions?.where((q) => q.answer != 3).toList();
  String? dropdownValue = 'Evet';

  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for(var q in unAnswered)
              ListTile(
                leading: const Icon(Icons.question_mark),
                title: Text(q.question),
                trailing: DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    dropdownValue = newValue;
                    showAlertDialog(context,q, possibleAns.indexOf(newValue!));
                  },
                  items:
                      possibleAns.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

              ),
            for(var q in answered)
              ListTile(
                leading: const Icon(Icons.question_mark),
                title: Text(q.question),
                trailing: Text(possibleAns[q.answer])
              ),
          ],
        );
      });
}


Future askQuestion(context,GameRoom gameRoom){
  final DatabaseService _databaseService = DatabaseService();
  final qFieldController = TextEditingController();
  Question question = Question.empty("a");
  return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
          content:  TextField(
            minLines: 2,
            maxLines: 5,
            controller: qFieldController,
            decoration: const InputDecoration(
              labelText: 'Soru',
              hintText: "Sorunu yaz",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Vazgeç'),
              child: const Text('Vazgeç'),
            ),
            TextButton(
            onPressed: () {
              question.question = qFieldController.text;
              question.date = DateTime.now();
              _databaseService.addQuestionToGame(question,gameRoom);
              Navigator.pop(context, 'Sor');},
              child: const Text('Sor'),
            ),

          ],
        ),
      );
}


Future<dynamic> bottomSheet(GameRoom gameRoom,dynamic questions,mode,context){
  final DatabaseService _databaseService = DatabaseService();
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            if(mode == 1 || mode == 4)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Oyunu Terket'),
                onTap: () {
                  _databaseService.leaveGame("a", gameRoom,"pre");

                  // Navigator.pop(context);
                },
              ),

            if(mode == 2 || mode == 3)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Oyuncu Çıkar'),
              onTap: () {
                listUser(context, gameRoom);
                print(gameRoom.currentPlayers);

                // Navigator.pop(context);
              },
            ),
            if(mode==2 )
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Oyunu Başlat'),
              onTap: () {
                _databaseService.transferRoomToInGame(gameRoom);
                Navigator.pop(context);
              },
            ),

            if(mode == 3)
              ListTile(
                leading: const Icon(Icons.publish),
                title: const Text('Hikayeyi yayınla ve bitir'),
                onTap: () {
                  _databaseService.transferRoomToInGame(gameRoom);
                  Navigator.pop(context);
                },
              ),
            if(mode == 2  || mode == 3)
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Oyunu Sil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}