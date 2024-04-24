import 'dart:developer';

import 'package:family_chat/Screen/home_screen.dart';
import 'package:family_chat/Screen/auth/login_ui_screen.dart';
import 'package:flutter/material.dart';
import 'package:family_chat/main.dart';

import 'package:family_chat/Api/api.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1300),(){

      if(Api.auth.currentUser != null) {
        //details of user
        log("User ${Api.auth.currentUser}");
        //navigate to home screen if user already login
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
            const HomeScreen()));
      }else{

        //navigate to login screen if user not found
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
            const LoginUI()));
      }
      });
  }



  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned
            (
               width: mq.width*.5,
              top: mq.height*.35,
              right: mq.width*.25,
              child: Image.asset("assets/images/chat.png")),
          Positioned(
              bottom: mq.height*.05,
              width: mq.width*.9,
              height: mq.height*.07,
              left: mq.width*.05,




          child: const Text("Made by Vivek Mishra 👨🏻‍💻",
            textAlign: TextAlign.center,
            style: TextStyle(

              color: Colors.orange,
            fontSize: 25
          ),))

        ],
      ),
    );
  }
}
