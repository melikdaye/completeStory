import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/bottomBar.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/myGames.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({Key? key}) : super(key: key);
  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {

  final DatabaseService _databaseService = DatabaseService();
  late final GameRoom _gameRoom = GameRoom.empty("y7cPlFnzUNRZi3jTirbOPdW4bbC3");
  final storyFieldController = TextEditingController();
  final storyPartFieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    storyFieldController.dispose();
    storyPartFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body:  ListView(
            physics: AlwaysScrollableScrollPhysics(),
          children: [Column(
              mainAxisAlignment: MainAxisAlignment.center,
             mainAxisSize: MainAxisSize.min,
              children:  <Widget>[
                Container(
                  padding: const EdgeInsets.all(15),
                  child: TextField(
                    minLines: 3,
                    maxLines: 6,
                    controller: storyFieldController,
                    decoration: const InputDecoration(
                      labelText: 'Hikaye',
                      hintText: "Hikayeni yaz",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(25),
                  child: TextField(
                    minLines: 1,
                    maxLines: 3,
                    controller: storyPartFieldController,
                    decoration: const InputDecoration(
                      labelText: 'Oyun Başlama Cümlesi',
                      hintText: "Çoğunlukla hikayenin son cümlesi olur",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),

          const Text("Maksimum Oyuncu Sayısı"),
          Text(_gameRoom.maxNumberOfPlayers.toString()),
          Slider(
            value: _gameRoom.maxNumberOfPlayers.toDouble(),
            max: 10,
            min: 1,
            divisions: 10,
            thumbColor: Color(0xFF39AEA9),
            label: _gameRoom.maxNumberOfPlayers.toString(),
            onChanged: (double value) {
              setState(() {
                _gameRoom.maxNumberOfPlayers = value.toInt();
              });
            },
          ),
                const Text("Otomatik Başlama"),
                Checkbox(
                  checkColor:Color(0xFF39AEA9) ,
                  value: _gameRoom.autoStart,
                  onChanged: (bool? value) {
                    setState(() {
                      _gameRoom.autoStart = value!;
                    });
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon( // <-- OutlinedButton
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.delete,
                        size: 48.0,
                      ),
                      style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.red)),
                      label: Text('Oyunu Sil'),
                    ),
                    OutlinedButton.icon( // <-- OutlinedButton
                      onPressed: () {
                        _gameRoom.story = storyFieldController.text;
                        _gameRoom.bOfStory = storyPartFieldController.text;
                        _gameRoom.date = DateTime.now();
                        _databaseService.createGameRoom(_gameRoom);
                        Provider.of<AppContext>(context,listen: false).changeBottomBarIndex(2);
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return  MyGames();
                        }));
                      },
                      icon: const Icon(
                        Icons.start,
                        size: 48.0,
                      ),
                      style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.green)),
                      label: Text('Oyun Hazır'),
                    ),
                  ],
                ),


              ],
            ),
          ]
        ),
        bottomNavigationBar:  BottomNavigator(),
      ),
    );
  }
}