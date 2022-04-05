
import 'package:flutter/material.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:provider/provider.dart';

class PlayerRoom extends StatefulWidget {
  const PlayerRoom({Key? key, required this.roomID}) : super(key: key);
  final String roomID;
  @override
  State<PlayerRoom> createState() => _PlayerRoomState();
}

class _PlayerRoomState extends State<PlayerRoom> {

  late Map<dynamic,List<Question>> qPlayedGames = Provider.of<AppContext>(context,listen:true).qPlayedGames;


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    throw UnimplementedError();
  }



}