import 'package:flutter/material.dart';
import 'package:incomplete_stories/createGame.dart';
import 'package:incomplete_stories/myGames.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/searchGame.dart';
import 'package:provider/provider.dart';


class BottomNavigator extends StatefulWidget {
  const BottomNavigator({Key? key}) : super(key: key);

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}


class _BottomNavigatorState extends State<BottomNavigator> {


  late int _selectedIndex = Provider.of<AppContext>(context, listen: true).selectedIndexBottomBar;

  void _onItemTapped(index){
    late Widget selected;
    switch(index){
      case 0:
        selected = const SearchGame( title: '');
        break;
      case 1:
        selected = const CreateGamePage();
        break;
      case 2:
        selected = const MyGames();
        break;
    }

    Provider.of<AppContext>(context,listen: false).changeBottomBarIndex(index);

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