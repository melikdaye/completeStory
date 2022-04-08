import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/createGame.dart';
import 'package:incomplete_stories/login.dart';
import 'package:incomplete_stories/myGames.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/searchGame.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';
import 'package:incomplete_stories/services/authService.dart';
void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => AppContext.empty(), child:  MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Initialize FlutterFire
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return const Text("error", textDirection: TextDirection.ltr);
          }
          // Once complete, sho your application
          if (snapshot.connectionState == ConnectionState.done) {
            late dynamic uid = Provider.of<AppContext>(context, listen: true).uid;
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or simply save your changes to "hot reload" in a Flutter IDE).
                // Notice that the counter didn't reset back to zero; the application
                // is not restarted.
                primarySwatch: Colors.blueGrey,
              ),

              home: uid!=null ? const MyGames() : const LoginPage(),
            );
          }
          return const Text("waiting", textDirection: TextDirection.ltr);
        });
  }
}
