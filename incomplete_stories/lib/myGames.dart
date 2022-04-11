import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/listItem.dart';
import 'package:incomplete_stories/models/gameRoom.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';

import 'Components/bottomBar.dart';

class MyGames extends StatefulWidget {
  const MyGames({Key? key}) : super(key: key);

  @override
  State<MyGames> createState() => _MyGamesState();
}

class _MyGamesState extends State<MyGames> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Color(0xFFFB3640) ,
            toolbarHeight: 0,
            bottom : TabBar(
            onTap : (int value) async {

            },
            tabs: const[
              Tab(icon: Icon(Icons.gamepad_outlined), text: "Oynadıklarım"),
              Tab(icon: Icon(Icons.people), text: "Oynattıklarım",),
              Tab(icon: Icon(Icons.videogame_asset_off), text: "Bitenler"),
            ],
          ),
        ),
        body:  TabBarView(
          children: [
              Consumer<AppContext>(
              builder : (context,s,_) {
                return Column(
                  children: [
                    LimitedBox(
                      child:
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: s.preGames.keys.length,
                          itemBuilder: (_, index) {
                            return listItem(s.preGames[s.preGames.keys
                                .toList()[index]] as GameRoom, _databaseService,
                                context, 1, null);
                          }
                      ),
                    ),
                    LimitedBox(child:
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: s.playingGames.keys.length,
                        itemBuilder: (_, index) {
                          return listItem(s.playingGames[s.playingGames.keys
                              .toList()[index]] as GameRoom, _databaseService,
                              context, 4,
                              s.qPlayedGames[s.playingGames.keys.toList()[index]]);
                        }
                    ),
                    ),
                  ],
                );
              }
            ),
            Consumer<AppContext>(
              builder : (context,s,_) {
                return Column(
                  children: [
                    LimitedBox(
                        child:
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: s.preManagedGames.keys.length,
                            itemBuilder: (_, index) {
                              return listItem(
                                  s.preManagedGames[s.preManagedGames.keys
                                      .toList()[index]] as GameRoom,
                                  _databaseService, context, 2, null);
                            }
                        )
                    ),
                    LimitedBox(child:
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: s.playingManagedGames.keys.length,
                        itemBuilder: (_, index) {
                          return listItem(
                              s.playingManagedGames[s.playingManagedGames.keys
                                  .toList()[index]] as GameRoom,
                              _databaseService, context, 3,
                              s.qOfGames[s.playingManagedGames.keys
                                  .toList()[index]]);
                        }
                    )
                    ),
                  ],
                );
              },
           ),
        Consumer<AppContext>(
        builder : (context,s,_) {
          return ListView.builder(
              itemCount: s.completedGames.length,
              itemBuilder: (_, index) {
                return listItemCompleted(s.completedGames[index], _databaseService, context);
              }
          );
        },
        ),

          ],
        ),
        bottomNavigationBar:  BottomNavigator(),
      ),
    );
  }
}