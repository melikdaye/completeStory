import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/createGame.dart';
import 'package:incomplete_stories/login.dart';
import 'package:incomplete_stories/myGames.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/searchGame.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      ChangeNotifierProvider(create: (context) => AppContext(),
      child: const MyApp())
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        // Initialize FlutterFire
        future: Firebase.initializeApp(),
    builder: (context, snapshot) {
    // Check for errors
    if (snapshot.hasError) {
      return const Text("error",textDirection: TextDirection.ltr);
    }
    // Once complete, sho your application
    if (snapshot.connectionState == ConnectionState.done) {

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
    home: const MyGames(title: 'Complete Story'),

    );
    };
    return const Text("waiting",textDirection: TextDirection.ltr);
    }
    );
  }
}


