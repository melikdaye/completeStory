import 'package:flutter/material.dart';
import 'package:incomplete_stories/Components/googleSignInButton.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFA41B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Image.asset(
                        'assets/questionMark2.png',
                        colorBlendMode: BlendMode.srcATop,
                        height: 260,
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0 ,left: 40.0,bottom: 0.0),
                        child: Text(
                          'Eksik',
                          style: GoogleFonts.gloriaHallelujah(color: Color(0xFFFF1E56),fontWeight: FontWeight.bold,fontSize: 50),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0.0 ,right: 40.0,bottom: 0.0),
                        child: Text(
                          'Hikayeler',
                          style:  GoogleFonts.gloriaHallelujah(color: Color(0xFFFF1E56),fontWeight: FontWeight.bold,fontSize: 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              GoogleSignInButton(),

            ],
          ),
        ),
      ),
    );
  }
}
