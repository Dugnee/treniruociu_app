// login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'workouts_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _kraunama = false;

  Future<void> _prisijungtiSuGoogle() async {
    setState(() => _kraunama = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _kraunama = false);
        return; // Atšaukta
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() => _kraunama = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nepavyko prisijungti: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _kraunama
            ? CircularProgressIndicator()
            : ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text('Prisijungti su Google'),
                onPressed: _prisijungtiSuGoogle,
              ),
      ),
    );
  }
}
