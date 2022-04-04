import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInAnonymous() async {

    try {
       final User? user = (await _auth.signInAnonymously()).user;
       return user;
    }catch(e){
        print(e.toString());
        return null;

    }
  }

}