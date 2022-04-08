import 'package:flutter/material.dart';
import 'package:incomplete_stories/myGames.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late dynamic playerName;
  late dynamic email;
  final DatabaseService _databaseService = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 200,
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
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  onChanged: (text) {
                    setState(() {
                      email = text;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    hintText: "player123@mail.com",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    prefixIcon: const Icon(Icons.mail),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () async {
                        bool result  = _databaseService.createUser(email, playerName) as bool;
                        if (result) {

                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return  const MyGames();
                          }));
                        } else {
                          print("error");
                        }
                      },
                    ),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
