
import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/bottomBar.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/services/databaseService.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {

  final DatabaseService _databaseService = DatabaseService();
  late final GameRoom _gameRoom = GameRoom.empty("y7cPlFnzUNRZi3jTirbOPdW4bbC3");
  final storyFieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    storyFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the CreateGamePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children:  <Widget>[
            OutlinedButton.icon( // <-- OutlinedButton
              onPressed: () {},
              icon: const Icon(
                Icons.delete,
                size: 48.0,
              ),
              label: Text('Oyunu Sil'),
            ),
            OutlinedButton.icon( // <-- OutlinedButton
              onPressed: () {
                _gameRoom.story = storyFieldController.text;
                _gameRoom.date = DateTime.now();
                _databaseService.createGameRoom(_gameRoom);
              },
              icon: const Icon(
                Icons.start,
                size: 48.0,
              ),
              label: Text('Oyun Hazır'),
            ),
      TextField(
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
      const Text("Number Of Players"),
      Text(_gameRoom.maxNumberOfPlayers.toString()),
      Slider(
        value: _gameRoom.maxNumberOfPlayers.toDouble(),
        max: 10,
        min: 1,
        divisions: 10,
        label: _gameRoom.maxNumberOfPlayers.toString(),
        onChanged: (double value) {
          setState(() {
            _gameRoom.maxNumberOfPlayers = value.toInt();
          });
        },
      ),
            const Text("AutoStart"),
            Checkbox(
              value: _gameRoom.autoStart,
              onChanged: (bool? value) {
                setState(() {
                  _gameRoom.autoStart = value!;
                });
              },
            ),

          ],
        ),
      ),
      bottomNavigationBar:  BottomNavigator(),
    );
  }
}