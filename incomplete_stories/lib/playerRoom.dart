import 'dart:async';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/bottomSheet.dart';
import 'package:incomplete_stories/models/answer.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';

class PlayerRoom extends StatefulWidget {
  const PlayerRoom({Key? key, required this.roomID}) : super(key: key);
  final int roomID;

  @override
  State<PlayerRoom> createState() => _PlayerRoomState();
}

class _PlayerRoomState extends State<PlayerRoom> {
  // late Map<dynamic, List<Question>> s.qPlayedGames =
  //     Provider.of<AppContext>(context, listen: true).s.qPlayedGames;
  late Map<dynamic, GameRoom> playingGames =
      Provider.of<AppContext>(context, listen: true).playingGames;

  late bool isQuestion = true;
  late double amountOfBlur = 6;
  late List<String> hintText = ["Soru sor","Hikayeyi tahmin et"];
  List<String> possibleAns = <String>['Evet', 'Hayır', 'Alakasız'];
  Map<int,Color> colorMap = {0:Colors.green,1:Colors.red,2:Colors.amberAccent,3:Colors.blueGrey};
  Map<int,IconData> iconMap = {0:Icons.check_circle,1:Icons.cancel,2:Icons.block,3:Icons.hourglass_bottom};
  TextEditingController qFieldController = TextEditingController();
  ScrollController _controller = new ScrollController();

  final DatabaseService _databaseService = DatabaseService();

  askOrGuess(){
    if(isQuestion){
      Question question = Question.empty("a");
      question.question = qFieldController.text;
      question.date = DateTime.now();
      _databaseService.addQuestionToGame(question,playingGames[widget.roomID] as GameRoom);
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      qFieldController.clear();
      _scrollDown();
    }else{
      Answer answer = Answer.empty("a");
      answer.answer = qFieldController.text;
      answer.date = DateTime.now();
      _databaseService.addAnswerToGame(answer, playingGames[widget.roomID] as GameRoom);
    }
  }

  showQuestion(Question? question){
    setState(() {
      amountOfBlur = 0;
    });
    Timer(Duration(seconds: 5), () {
      _databaseService.updateViewedPlayers(question!,"a");
      setState(() {
      amountOfBlur = 6;
    });});

  }

  saveQuestion(Question? question){

    _databaseService.updateSavedPlayers(question!,"a");

  }

  void _scrollDown() {
    if(_controller.hasClients) {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
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
                        playingGames[widget.roomID]?.bOfStory ?? "",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        '${playingGames[widget.roomID]?.currentNumberOfPlayers} / ${playingGames[widget.roomID]?.maxNumberOfPlayers}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: (){bottomSheet(playingGames[widget.roomID] as GameRoom,null, 4, context);}, icon: Icon(
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
          if(isQuestion)
      Expanded(
        child: Consumer<AppContext>(
            builder : (context,s,_) {
              s.qPlayedGames[widget.roomID]?.sort((a, b) => a.date.compareTo(b.date));
              return s.qPlayedGames[widget.roomID]?.isNotEmpty ?? false ? ListView.builder(
                itemCount: s.qPlayedGames[widget.roomID]?.length,
                shrinkWrap: false,
                controller: _controller,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(
                        left: 14, right: 14, top: 10, bottom: 10),
                    child: Align(
                      alignment: (s.qPlayedGames[widget.roomID]?[index].ownerID !=
                          "a" ? Alignment.topLeft : Alignment.topRight),
                      child: Row(
                          mainAxisAlignment: (s.qPlayedGames[widget.roomID]?[index]
                              .ownerID != "a"
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end),
                          children: <Widget>[
                            if(s.qPlayedGames[widget.roomID]?[index].ownerID == "a")
                              Icon(iconMap[s.qPlayedGames[widget.roomID]?[index]
                                  .answer]),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: ((s.qPlayedGames[widget.roomID]?[index]
                                    .ownerID != "a" || amountOfBlur != 6 ||
                                    (s.qPlayedGames[widget.roomID]?[index].savedBy
                                        .contains("a") ?? true)) ? Colors.grey
                                    .shade200 : colorMap[s.qPlayedGames[widget
                                    .roomID]?[index].answer]),
                              ),
                              padding: EdgeInsets.all(16),


                              child: Text(
                                  s.qPlayedGames[widget.roomID]?[index].question ??
                                      "",
                                  style: ((s.qPlayedGames[widget.roomID]?[index]
                                      .ownerID != "a" &&
                                      !(s.qPlayedGames[widget.roomID]?[index]
                                          .savedBy.contains("a") ?? false))
                                      ? TextStyle(
                                      fontSize: 15,
                                      foreground: Paint()
                                        ..style = PaintingStyle.fill
                                        ..color = Colors.black
                                        ..maskFilter = MaskFilter.blur(
                                            BlurStyle.normal, amountOfBlur))
                                      : TextStyle(fontSize: 15))),

                            ),
                            if(s.qPlayedGames[widget.roomID]?[index].ownerID !=
                                "a" &&
                                !(s.qPlayedGames[widget.roomID]?[index].viewedBy
                                    .contains("a") ?? false) &&s.qPlayedGames[widget.roomID]?[index].answer!=3)
                              IconButton(onPressed: () {
                                showQuestion(s.qPlayedGames[widget.roomID]?[index]);
                              }, icon: Icon(Icons.remove_red_eye)),
                            if((s.qPlayedGames[widget.roomID]?[index].viewedBy
                                .contains("a") ?? true) &&
                                !(s.qPlayedGames[widget.roomID]?[index].savedBy
                                    .contains("a") ?? false))
                              IconButton(onPressed: () {
                                saveQuestion(s.qPlayedGames[widget.roomID]?[index]);
                              }, icon: Icon(Icons.save)),
                            if((s.qPlayedGames[widget.roomID]?[index].savedBy
                                .contains("a") ?? true))
                              Icon(iconMap[s.qPlayedGames[widget.roomID]?[index]
                                  .answer]),
                          ]

                      ),
                    ),
                  );
                },
              ): Container();
            }
        ),
      ),
          if(!isQuestion)
            Expanded(
              child: Consumer<AppContext>(
                  builder : (context,s,_) {
                    s.aPlayedGames[widget.roomID]?.sort((a, b) => a.date.compareTo(b.date));
                    return s.aPlayedGames[widget.roomID]?.isNotEmpty ?? false ? ListView.builder(
                      itemCount: s.aPlayedGames[widget.roomID]?.length,
                      shrinkWrap: false,
                      controller: _controller,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if(s.aPlayedGames[widget.roomID]?[index].ownerID == "a"){
                        return Container(
                          padding: EdgeInsets.only(
                              left: 14, right: 14, top: 10, bottom: 10),
                          child: Align(
                            alignment: (s.aPlayedGames[widget.roomID]?[index].ownerID !=
                                "a" ? Alignment.topLeft : Alignment.topRight),
                            child: Row(
                                mainAxisAlignment: (s.aPlayedGames[widget.roomID]?[index]
                                    .ownerID != "a"
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end),
                                children: <Widget>[

                                    Icon( iconMap[s.aPlayedGames[widget.roomID]?[index].isCorrect]),

                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),

                                      color: (colorMap[s.aPlayedGames[widget.roomID]?[index].isCorrect]),
                                    ),
                                    padding: EdgeInsets.all(16),


                                    child: Text(
                                        s.aPlayedGames[widget.roomID]?[index].answer ??
                                            "",
                                        style: (TextStyle(fontSize: 15)),)

                                  ),

                                ]

                            ),
                          ),
                        );
                      }
                        else{
                          return Container();
                        }
                                },
                    ) : Container();
                  }
              ),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  FlutterSwitch(
                    activeText: "Soru Sor",
                    inactiveText: "Tahmin et",
                    inactiveColor: Colors.blue,
                    toggleSize: 15,
                    value: isQuestion,
                    valueFontSize: 10.0,
                    width: 80,
                    borderRadius: 30.0,
                    showOnOff: true,
                    onToggle: (val) {
                      setState(() {
                        isQuestion = !isQuestion;
                      });
                    },
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      controller: qFieldController,
                      keyboardType: TextInputType.multiline,
                      scrollPhysics: ScrollPhysics(),
                      decoration: InputDecoration(
                          hintText: hintText[isQuestion ? 0 : 1],
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      askOrGuess();
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );

  }

}
