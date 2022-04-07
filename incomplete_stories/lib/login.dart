import 'package:flutter/material.dart';
import 'package:incomplete_stories/services/authService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late dynamic playerName;

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    playerName = text;
                  });
                  ;
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
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () async {
                      dynamic result = await _auth.signInAnonymous();
                      if (result == null) {
                        print("error");
                      } else {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) {
                        //   return  LobbyPage(title: playerName ?? result.uid);
                        // }));
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
