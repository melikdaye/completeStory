import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:incomplete_stories/Components/bottomSheet.dart';
import 'package:incomplete_stories/models/answer.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';


class AdminView extends StatefulWidget {
  const AdminView({Key? key, required this.roomID}) : super(key: key);
  final int roomID;

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {

  late Map<dynamic, GameRoom> playingManagedGames =
      Provider.of<AppContext>(context, listen: true).playingManagedGames;

  late bool isQuestion = true;
  late double amountOfBlur = 6;
  late int _selectedIndex = 0;
  late List<String> hintText = ["Soru sor","Hikayeyi tahmin et"];
  List<String> possibleAns = <String>['Evet', 'Hayır', 'Alakasız'];
  Map<int,Color> colorMap = {0:Colors.green,1:Colors.red,2:Colors.amberAccent,3:Colors.blueGrey};
  Map<int,IconData> iconMap = {0:Icons.check_circle,1:Icons.cancel,2:Icons.block,3:Icons.hourglass_bottom};
  TextEditingController qFieldController = TextEditingController();
  ScrollController _controller = new ScrollController();

  final DatabaseService _databaseService = DatabaseService();



 answerQuestion(Question question,int index){
    question.answer = index;
   _databaseService.updateAnswerOfQuestion(question);
 }
  answerGuess(Answer answer,int index){
    answer.isCorrect = index;
    // _databaseService.updateAnswerOfQuestion(question);
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    qFieldController.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => _scrollDown());
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child : Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          playingManagedGames[widget.roomID]?.story ?? "",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          '${playingManagedGames[widget.roomID]?.currentNumberOfPlayers} / ${playingManagedGames[widget.roomID]?.maxNumberOfPlayers}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: (){bottomSheet(playingManagedGames[widget.roomID] as GameRoom,null, 3, context);}, icon: Icon(
                    Icons.settings,
                    color: Colors.black54)
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            if(_selectedIndex == 0)
            Expanded(
              child: Consumer<AppContext>(
                  builder : (context,s,_) {
                    s.qOfGames[widget.roomID]?.sort((a, b) => a.answer.compareTo(b.answer));
                    return ListView.builder(
                      itemCount: s.qOfGames[widget.roomID]?.length,
                      shrinkWrap: false,
                      controller: _controller,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.only(
                              left: 14, right: 14, top: 10, bottom: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[

                                  Icon(iconMap[s.qOfGames[widget.roomID]?[index].answer]),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color:  colorMap[s.qOfGames[widget.roomID]?[index].answer],
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                        s.qOfGames[widget.roomID]?[index].question ??
                                            "",
                                        style: TextStyle(fontSize: 15)),

                                  ),
                                  if(s.qOfGames[widget.roomID]?[index].answer == 3)
                                    IconButton(onPressed: () {
                                      answerQuestion(s.qOfGames[widget.roomID]?[index] as Question,0);
                                    }, icon: Icon(Icons.check_circle),color:Colors.green,tooltip: "Evet",),
                                  if(s.qOfGames[widget.roomID]?[index].answer == 3)
                                  IconButton(onPressed: () {
                                    answerQuestion(s.qOfGames[widget.roomID]?[index] as Question,1);
                                  }, icon: Icon(Icons.cancel),color: Colors.red,tooltip: "Hayır"),
                                  if(s.qOfGames[widget.roomID]?[index].answer == 3)
                                  IconButton(onPressed: () {
                                    answerQuestion(s.qOfGames[widget.roomID]?[index] as Question,2);
                                  }, icon: Icon(Icons.block),color: Colors.grey,tooltip:"Alakasız"),
                                ]

                            ),
                          ),
                        );
                      },
                    );
                  }
              ),
            ),
            if(_selectedIndex != 0)
              Expanded(
                child: Consumer<AppContext>(
                    builder : (context,s,_) {
                      s.aOfGames[widget.roomID]?.sort((a, b) => a.isCorrect.compareTo(b.isCorrect));
                      return ListView.builder(
                        itemCount: s.aOfGames[widget.roomID]?.length,
                        shrinkWrap: false,
                        controller: _controller,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.only(
                                left: 14, right: 14, top: 10, bottom: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[

                                    Icon(iconMap[s.aOfGames[widget.roomID]?[index].answer]),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color:  colorMap[s.aOfGames[widget.roomID]?[index].answer],
                                      ),
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                          s.aOfGames[widget.roomID]?[index].answer ??
                                              "",
                                          style: TextStyle(fontSize: 15)),

                                    ),
                                    if(s.aOfGames[widget.roomID]?[index].isCorrect == 3)
                                      IconButton(onPressed: () {
                                        answerGuess(s.aOfGames[widget.roomID]?[index] as Answer,0);
                                      }, icon: Icon(Icons.check_circle),color:Colors.green,tooltip: "Evet",),
                                    if(s.aOfGames[widget.roomID]?[index].isCorrect == 3)
                                      IconButton(onPressed: () {
                                        answerGuess(s.aOfGames[widget.roomID]?[index]  as Answer,1);
                                      }, icon: Icon(Icons.cancel),color: Colors.red,tooltip: "Hayır"),

                                  ]

                              ),
                            ),
                          );
                        },
                      );
                    }
                ),
              ),

          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Color(0xFF39AEA9),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Sorular',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.gamepad),
                label: 'Hikaye Tahminleri',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              // _onItemTapped(index);
            }
        ),
      ),
    );

  }

}