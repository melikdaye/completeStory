import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/bottomSheet.dart';
import 'package:incomplete_stories/models/answer.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/models/question.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';


class CompletedView extends StatefulWidget {
  const CompletedView({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<CompletedView> createState() => _CompletedViewState();
}

class _CompletedViewState extends State<CompletedView> {

  late bool isQuestion = true;
  late double amountOfBlur = 6;
  late int _selectedIndex = 0;
  late List<String> hintText = ["Soru sor","Hikayeyi tahmin et"];
  List<String> possibleAns = <String>['Evet', 'Hayır', 'Alakasız'];
  Map<int,Color> colorMap = {0:Colors.green,1:Colors.red,2:Colors.amberAccent,3:Colors.blueGrey};
  Map<int,IconData> iconMap = {0:Icons.check_circle,1:Icons.cancel,2:Icons.block,3:Icons.hourglass_bottom};
  TextEditingController qFieldController = TextEditingController();
  final ScrollController _controller =  ScrollController();

  void _scrollDown() {
    if(_controller.hasClients) {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
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
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
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
                      s.completedGames[widget.index]["questions"]?.sort((a, b) => (a["answer"] as int).compareTo((b["answer"] as int)));
                      return s.completedGames[widget.index]["questions"]?.isNotEmpty ?? false ? ListView.builder(
                        itemCount: s.completedGames[widget.index]["questions"]?.length,
                        shrinkWrap: false,
                        controller: _controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, top: 10, bottom: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[

                                    Icon(iconMap[s.completedGames[widget.index]["questions"]?[index]["answer"]]),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color:  colorMap[s.completedGames[widget.index]["questions"]?[index]["answer"]],
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                          s.completedGames[widget.index]["questions"]?[index]["question"] ??
                                              "",
                                          style: const TextStyle(fontSize: 15)),

                                    ),
                                  ]

                              ),
                            ),
                          );
                        },
                      ): Container();
                    }
                ),
              ),
            if(_selectedIndex != 0)
              Expanded(
                child: Consumer<AppContext>(
                    builder : (context,s,_) {
                      s.completedGames[widget.index]["answers"]?.sort((a, b) => (a["isCorrect"] as int).compareTo((b["isCorrect"] as int)));
                      return s.completedGames[widget.index]["answers"]?.isNotEmpty ?? false ? ListView.builder(
                        itemCount: s.completedGames[widget.index]["answers"]?.length,
                        shrinkWrap: false,
                        controller: _controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, top: 10, bottom: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[

                                    Icon(iconMap[s.completedGames[widget.index]["answers"]?[index]["isCorrect"]]),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color:  colorMap[s.completedGames[widget.index]["answers"]?[index]["isCorrect"]],
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                          s.completedGames[widget.index]["answers"]?[index]["answer"] ??
                                              "",
                                          style: const TextStyle(fontSize: 15)),

                                    ),
                                  ]

                              ),
                            ),
                          );
                        },
                      ): Container();
                    }
                ),
              ),

          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: const Color(0xFF39AEA9),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Sorular',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
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
