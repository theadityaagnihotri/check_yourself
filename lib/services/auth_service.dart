import 'package:check_yourself/services/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  getUserFromToken() async {
    final accessToken = await SharedPref().getAccessToken();
    if (accessToken != null) {
      try {
        final credential =
            GoogleAuthProvider.credential(accessToken: accessToken);
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        return userCredential.user;
      } on FirebaseAuthException catch (e) {
        print('Firebase sign-in error: ${e.code}');
      }
    }
    return null;
  }

  Future<UserCredential?> signinwithgoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Signing in with Google..."),
              ],
            ),
          );
        },
      );

      final GoogleSignInAccount? guser = await GoogleSignIn().signIn();
      if (guser == null) {
        Navigator.pop(context);
        return null;
      }

      final GoogleSignInAuthentication gauth = await guser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gauth.accessToken,
        idToken: gauth.idToken,
      );
      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.pop(context);

      return result;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }
}
