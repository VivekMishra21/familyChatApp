import 'dart:developer';

import 'package:flutter/services.dart';

import 'package:family_chat/Screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:family_chat/Widget/chat_user_card.dart';
import 'package:family_chat/main.dart';
import 'package:family_chat/Api/api.dart';
import 'package:family_chat/Models/chat_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:family_chat/Screen/profile_screen.dart';
import 'package:family_chat/helper/dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];

  // for storing a searchesItems
  final List<ChatUser> _searchText = [];

  //for stoing search status
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Api.userInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (Api.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Api.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          Api.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        //click a screen hide a keyboard
        onTap: () => FocusScope.of(context).unfocus(),

        //back when not seraching anything when search first close searching then exit a app
        child: Builder(builder: (context) {
          return GestureDetector(
            //for hiding keyboard when a tap is detected on screen
            onTap: FocusScope.of(context).unfocus,
            child: PopScope(
              // onWillPop: () {
              //   if (_isSearching) {
              //     setState(() {
              //       _isSearching = !_isSearching;
              //     });
              //     return Future.value(false);
              //   } else {
              //     return Future.value(true);
              //   }
              // },

              //if search is on & back button is pressed then close search
              //or else simple close current screen on back button click
              canPop: !_isSearching,
              onPopInvoked: (_) async {
                if (_isSearching) {
                  setState(() => _isSearching = !_isSearching);
                } else {
                  Navigator.of(context).pop();
                }
              },

              child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    //for search input field

                    leading: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.home,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    title: _isSearching
                        ? TextField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: " Search Name",
                            ),
                            // click on text bar automatically cursor show
                            autofocus: true,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 0.7,
                            ),
                            //when search text changes then updates search list
                            onChanged: (val) {
                              //search logic
                              _searchText.clear();
                              for (var i in list) {
                                if (i.name
                                        .toLowerCase()
                                        .contains(val.toLowerCase()) ||
                                    i.email
                                        .toLowerCase()
                                        .contains(val.toLowerCase())) {
                                  _searchText.add(i);
                                  setState(() {
                                    _searchText;
                                  });
                                }
                              }
                            },
                          )
                        : const Text("Family Chat"),

                    actions: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                          });
                        },
                        icon: Icon(
                          //icon change whn click
                          _isSearching ? Icons.search_off : Icons.search,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        //only go our information
                                        ProfileScreen(
                                          user: Api.me,
                                        )));
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  floatingActionButton: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FloatingActionButton(
                      onPressed: () async {
                        _addChatUserDialog();
                      },
                      backgroundColor: Colors.black,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  body: StreamBuilder(
                      stream: Api.getMyUserId(),
                      //get id of only known users
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                                child: CircularProgressIndicator());
                          //if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            return StreamBuilder(
                                //for using getalluser function from api folder
                                stream: Api.getAllUser(snapshot.data?.docs
                                        .map((e) => e.id)
                                        .toList() ??
                                    []),

                                //get only those user, who's ids are provided

                                builder: (context, snapshot) {
                                  //check data load or already load
                                  switch (snapshot.connectionState) {
                                    //if data is loading
                                    case ConnectionState.waiting:
                                    case ConnectionState.none:
                                    // return const Center(
                                    //   child: CircularProgressIndicator(),
                                    // );

                                    //if some or all data load it show it
                                    case ConnectionState.active:
                                    case ConnectionState.done:
                                      final data = snapshot.data?.docs;
                                      list = data
                                              ?.map((e) =>
                                                  ChatUser.fromJson(e.data()))
                                              .toList() ??
                                          [];
                                      //if no user found in database then
                                      if (list.isNotEmpty) {
                                        return ListView.builder(
                                            //if seraching on show search text else showing list chat
                                            itemCount: _isSearching
                                                ? _searchText.length
                                                : list.length,
                                            padding: EdgeInsets.only(
                                                top: mq.height * 0.01),
                                            itemBuilder: (context, index) {
                                              //show the list
                                              return ChatUserCard(
                                                user: _isSearching
                                                    ? _searchText[index]
                                                    : list[index],
                                              );
                                              return Text(
                                                  "Name : ${list[index]}");
                                            });
                                      } else {
                                        return const Center(
                                          child: Text(
                                            "No Connection Found ",
                                            style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      }
                                  }
                                });
                        }
                      })),
            ),
          );
        }));
  }

// for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await Api.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.snapBar(context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
