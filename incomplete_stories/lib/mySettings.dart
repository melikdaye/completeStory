import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/statistics.dart';
import 'package:incomplete_stories/login.dart';
import 'package:incomplete_stories/provider/provider.dart';
import 'package:incomplete_stories/services/authService.dart';
import 'package:incomplete_stories/services/databaseService.dart';
import 'package:provider/provider.dart';


class MySettings extends StatefulWidget {
  const MySettings({Key? key}) : super(key: key);

  @override
  State<MySettings> createState() => _MySettingsState();
}


class _MySettingsState extends State<MySettings> {

  TextEditingController qFieldController = TextEditingController();
  late bool edit = false;
  final DatabaseService _databaseService = DatabaseService();
  late bool _isSigningOut = false;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }


  @override
  void initState() {
    Provider.of<AppContext>(context, listen: false).getUserProps();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null){
      final image = NetworkImage(user.photoURL ?? "");
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFB3640),
        ),
        body: Container(
          color: Color(0xFFFFF6EA),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: Ink.image(
                          image: image,
                          fit: BoxFit.cover,
                          width: 128,
                          height: 128,
                          child: InkWell(onTap: () {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              buildName(user),
              const SizedBox(height: 24),
              NumbersWidget(),
              const SizedBox(height: 48),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: edit ? 68 : 88),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(edit)
                        Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: TextField(
                                maxLines: null,
                                controller: qFieldController,
                                keyboardType: TextInputType.multiline,
                                scrollPhysics: ScrollPhysics(),
                                decoration: InputDecoration(
                                    hintText: "Change Player Name",
                                    hintStyle: TextStyle(color: Colors.black54),
                                    border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(onPressed: () {
                              setState(() {
                                _databaseService.setPlayerName(
                                    user.uid , qFieldController.text);
                                Provider.of<AppContext>(context, listen: false)
                                    .setPlayerName(qFieldController.text);
                                edit = !edit;
                              });
                            }, icon: Icon(Icons.save)),
                            IconButton(onPressed: () {
                              setState(() {
                                edit = !edit;
                              });
                            }, icon: Icon(Icons.cancel))
                          ],
                        ),
                      if(!edit)
                        Consumer<AppContext>(builder: (context, s, _) {
                          return Row(
                            children: [
                              const Text("Oyuncu Adı :", style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 18),
                              Text(s.userProps["playerName"],
                                style: TextStyle(fontSize: 16),),
                              const SizedBox(width: 8),
                              IconButton(onPressed: () {
                                setState(() {
                                  edit = !edit;
                                });
                              }, icon: Icon(Icons.edit))
                            ],
                          );
                        }),
                      Consumer<AppContext>(builder: (context, s, _) {
                        return Row(
                          children: [
                            const Text("Kredi :", style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 18),
                            Text(s.userProps["credits"].toString(),
                              style: TextStyle(fontSize: 16),),
                            const SizedBox(width: 8),
                          ],
                        );
                      }),
                      const SizedBox(height: 50),
                      _isSigningOut
                          ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.redAccent,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            _isSigningOut = true;
                          });
                          await AuthService.signOut(context: context);
                          setState(() {
                            _isSigningOut = false;
                          });
                          Navigator.of(context)
                              .pushReplacement(_routeToSignInScreen());
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            'Oturumu Kapat',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }else{
      return Container();
    }
  }

  Widget buildName(User? user) => Column(
    children: [
      Text(
        user?.displayName ?? "",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(height: 4),
      Text(
        user?.email ?? "",
        style: TextStyle(color: Colors.grey),
      )
    ],
  );


}
