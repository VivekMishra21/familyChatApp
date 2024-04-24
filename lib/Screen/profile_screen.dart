import 'dart:developer';
import 'dart:io';

import 'package:family_chat/Screen/auth/login_ui_screen.dart';
import 'package:family_chat/Screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:family_chat/Models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_chat/main.dart';
import 'package:family_chat/Api/api.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:family_chat/helper/dialog.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hidding keyboad when click screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Profile"),
          leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()));
            },
            icon: const Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),

        //for user logout
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            onPressed: () async {
              //for showing progress dialog
              Dialogs.showCirclecularBar(context);
              await Api.updateActiveStatus(false);

              //sign out from app
              await Api.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //for hidding the progrss bar
                  Navigator.pop(context);



                  //for moving to homescreen
                  Navigator.pop(context);

                  Api.auth=FirebaseAuth.instance;

                  //replacing homescreen to loginscreen
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const LoginUI()));
                });
              });
            },
            backgroundColor: Colors.black,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 25,
            ),
            label: const Text(
              "LogOut",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),

        //user profile pic
        body: Form(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .06,
                  ),
                  Stack(
                    children: [
                      //profile picture
                      _image != null
                          ?
                          //local image
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          :
                          //image from server
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 1),
                              child: CachedNetworkImage(
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet();
                          },
                          elevation: 5,
                          child: const Icon(
                            Icons.edit,
                            size: 30,
                            color: Colors.black,
                          ),
                          shape: const CircleBorder(),
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),

                  SizedBox(
                    height: mq.height * .03,
                  ),
                  //user email field
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black54, fontSize: 18),
                  ),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  //user name
                  TextFormField(
                    //for initial value
                    initialValue: widget.user.name,
                    onSaved: (val) => Api.me.name = val ?? " ",
                    //check input or not if input is valid return null else return text required field
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required field",
                    decoration: InputDecoration(
                      //all line cover
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      //for icon
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      //for hint
                      hintText: "eg. Mark Wood",
                      //for label name
                      label: const Text("Name"),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  //about user
                  TextFormField(
                    initialValue: widget.user.about,
                    //user input valid save in val variable
                    onSaved: (val) => Api.me.about = val ?? " ",
                    //check input or not if input is valid return null else return text required field
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      prefixIcon: const Icon(
                        Icons.info_outline,
                        color: Colors.black,
                      ),
                      hintText: "eg. Tell me about",
                      label: const Text("About"),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .07,
                  ),
                  //for update
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();

                        //update user
                        Api.updateUserInfo().then((value) {
                          Dialogs.snapBar(
                              context, "Profile Updated Successfully!'");
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        minimumSize: Size(mq.width * .5, mq.height * .05),
                        backgroundColor: Colors.black),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 25,
                    ),
                    label: const Text(
                      "Update",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22.0), topRight: Radius.circular(22.0)),
        ),
        builder: (_) {
          //for make gallery camera option
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: mq.height * 0.04, bottom: mq.height * 0.05),
            children: [
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      //pick photo from gallery
                      onPressed: () async {
                        //for select image from gallery
                        final ImagePicker picker = ImagePicker();
// Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery,imageQuality: 90);
                        if (image != null) {
                          log("image path ${image.path} -- Mime Type: ${image.mimeType}");
                          setState(() {
                            _image = image.path;
                          });
                          Api.updateProfilePic(File(_image!));
                          //for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        fixedSize: Size(mq.width * .3, mq.height * .15),
                      ),
                      child: Image.asset("assets/images/gallery.png")),
                  ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? photo =
                            await picker.pickImage(source: ImageSource.camera,imageQuality: 90);

                        if (photo != null) {
                          log("phoot path ${photo.path} -- Mime Type: ${photo.mimeType}");
                          setState(() {
                            _image = photo.path;
                          });
                          //set profile pic
                          Api.updateProfilePic(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        fixedSize: Size(mq.width * .3, mq.height * .15),
                      ),
                      child: Image.asset("assets/images/camera.png")),
                ],
              )
            ],
          );
        });
  }
}
