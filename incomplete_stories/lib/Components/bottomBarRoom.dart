import 'package:flutter/material.dart';
import 'package:incomplete_stories/createGame.dart';
import 'package:incomplete_stories/myGames.dart';
import 'package:incomplete_stories/searchGame.dart';


class BottomNavigatorRoom extends StatefulWidget {
  const BottomNavigatorRoom({Key? key}) : super(key: key);

  @override
  State<BottomNavigatorRoom> createState() => _BottomNavigatorRoomState();
}


class _BottomNavigatorRoomState extends State<BottomNavigatorRoom> {


  late int _selectedIndex = 2;

  void _onItemTapped(index){
    late Widget selected;
    switch(index){
      case 0:
        selected = const SearchGame( title: '');
        break;
      case 1:
        selected = const CreateGamePage( title: '');
        break;
      case 2:
        selected = const MyGames( title: '');
        break;
    }
    setState(() {
      _selectedIndex = index;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return  selected;
    }));

  }


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        backgroundColor: Color(0xFF39AEA9),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Oyun Ara',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: 'Oyun Kur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports,),
            label: 'Oyunlarım',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: (index) {
          _onItemTapped(index);
        }
    );
  }
}