
import 'package:flutter/material.dart';
import 'package:incomplete_stories/lobby.dart';
import 'package:incomplete_stories/services/authService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late dynamic playerName ;
  final AuthService _auth = AuthService();
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
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  <Widget>[
            SizedBox(
              width: 300,
              child:
              TextField(
                onChanged: (text) {
                  setState(() {
                    playerName = text;
                  });;
                },
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  hintText: "player123",
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  suffixIcon: IconButton(icon: const Icon(Icons.chevron_right), onPressed: () async{
                    dynamic result = await _auth.signInAnonymous();
                    if (result == null){
                      print("error");
                    }else{

                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return  LobbyPage(title: playerName ?? result.uid);
                      }));
                    }
                    },),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}