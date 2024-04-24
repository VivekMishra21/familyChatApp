import 'dart:developer';

import 'package:family_chat/Screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:family_chat/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:family_chat/helper/dialog.dart';
import 'package:family_chat/Api/api.dart';

class LoginUI extends StatefulWidget {
  const LoginUI({super.key});

  @override
  State<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  bool _isAnimated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(microseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });

    setState(() {});
  }

  _handleGoogleclick() {
    //showing circular bar
    Dialogs.showCirclecularBar(context);
    _signInWithGoogle().then((user) async {
      //hiding circular bar
      Navigator.pop(context);
      if (user != null) {
        log("User: ${user.user}");
        log("UserAdditionalInformation:${user.additionalUserInfo}");

        //check user exits or nor
        if ((await Api.userExits())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          //if user not exits then create a user then navigate a homescreen
          await Api.createUser().then((value) => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen())));
        }
      }
    });
  }

  // return null also
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Api.auth.signInWithCredential(credential);
    }
    //catch error in function
    catch (e) {
      log("_signInWithGoogle $e");
      Dialogs.snapBar(context, "something went wrong check internet");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Welcome Family Chat",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(children: [
        AnimatedPositioned(
            top: mq.height * .08,
            width: mq.width * .50,
            height: mq.height * 0.50,
            left: _isAnimated ? mq.width * 0.25 : -mq.width * 0.50,
            duration: const Duration(seconds: 1),
            child: Image.asset("assets/images/mess.png")),
        Positioned(
            bottom: mq.height * .09,
            width: mq.width * .9,
            height: mq.height * .07,
            left: mq.width * .05,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen),
                onPressed: () {
                  _handleGoogleclick();
                },
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/images/search.png",
                    width: mq.width * 0.10,
                  ),
                ),
                label: RichText(
                  text:
                      const TextSpan(style: TextStyle(fontSize: 20), children: [
                    TextSpan(text: "Login With "),
                    TextSpan(
                        text: "Google",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ))),
      ]),
    );
  }
}
