import 'dart:developer';
import 'dart:io';

import 'package:family_chat/Models/chat_user.dart';
import 'package:family_chat/Models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class Api {
  //make object of all packages

  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for databases
  static FirebaseFirestore fire = FirebaseFirestore.instance;

  //for access firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //return to current user
  static User get cu => auth.currentUser!;

  // for storing self information
  static ChatUser me = ChatUser(
      id: cu.uid,
      name: cu.displayName.toString(),
      email: cu.email.toString(),
      about: "Hey, I'm using Family Chat App!",
      image: cu.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;

        print("Push Token : $t");
      }
    });
    // for handling foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for sending push notification (Updated Codes)
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name, //our name should be send
            "body": msg,
          },
        }
      };

      // Firebase Project > Project Settings > General Tab > Project ID
      const projectID = 'family-chat-76b56';
    } catch (e) {
      log("sendpushnotification : $e");
    }
  }

  //checking user exists or not
  static Future<bool> userExits() async {
    return (await fire.collection("user").doc(cu.uid).get()).exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data =
        await fire.collection('user').where('email', isEqualTo: email).get();

    print('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != cu.uid) {
      //user exists

      print('user exists: ${data.docs.first.data()}');

      fire
          .collection('user')
          .doc(cu.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // show user information in profile screen
  static Future<void> userInfo() async {
    await fire.collection("user").doc(cu.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        //for setting user status is active
        Api.updateActiveStatus(true);
      } else {
        await createUser().then((value) => userInfo());
      }
    });
  }

  //for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        image: cu.photoURL.toString(),
        name: cu.displayName.toString(),
        about: "Hey",
        createdAt: time,
        isOnline: false,
        lastActive: time,
        id: auth.currentUser!.uid,
        pushToken: "",
        email: cu.email.toString());
    //to set a data
    return (await fire.collection("user").doc(cu.uid).set(chatuser.toJson()));
  }

  //for getting Id of knowns user from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    //for where feild using here not show login id only show another users
    return Api.fire
        .collection("user")
        .doc(cu.uid)
        .collection("my_users")
        .snapshots();
  }

  //for getting all user from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userIds) {
    print("\nuserIds : $userIds");
    //for where feild using here not show login id only show another users
    return Api.fire
        .collection("user")
        .where("id", whereIn: userIds.isEmpty ? [" "] : userIds)
        .snapshots();
  }
//not load our user all user loaded

//now we update our name and about in firebase database
//
  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await fire
        .collection("user")
        .doc(chatUser.id)
        .collection("my_users")
        .doc(cu.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  static Future<void> updateUserInfo() async {
    await fire.collection('user').doc(cu.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  //updating a profile pic in storage

  static Future<void> updateProfilePic(File file) async {
    //getting image file extension
    final extn = file.path.split('.').last;
    print('Extension : $extn');

    //storage file ref with path
    final ref = storage.ref().child("profile_picture/${cu.uid}.$extn");

    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: "image/$extn")).then(
        (p0) => print("Data Transferred ; ${p0.bytesTransferred / 1000} kb"));

    //updating image in firestore
    me.image = await ref.getDownloadURL();
    await fire.collection("user").doc(cu.uid).update({"image": me.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser a) {
    return fire.collection('user').where('id', isEqualTo: a.id).snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    fire.collection('user').doc(cu.uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      'pushToken': me.pushToken,
    });
  }

  //chat screen related api

  //chat(collection) > coversayion_id (doc) > messages(collection) > message (doc)

  //useful for getting coversation id
  static String getCoversationID(String id) =>
      cu.uid.hashCode <= id.hashCode ? "${cu.uid}_$id" : "${id}_${cu.uid}";
  //for getting all messages of a specific conversation form firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser cu) {
    return fire
        .collection("chats/${getCoversationID(cu.id)}/messages/")
        .orderBy("sent", descending: true)
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(ChatUser a, String msg, Type type) async {
    //message sending time also used id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        msg: msg, toId: a.id, read: "", type: type, sent: time, fromId: cu.uid);
    final ref = fire.collection("chats/${getCoversationID(a.id)}/messages/");
    await ref.doc(time).set(message.toJson()).then(
        (value) => sendPushNotification(me, type == Type.text ? msg : "image"));
  }

  //update read status of messages
  static Future<void> updatingReadStatus(Message message) async {
    fire
        .collection("chats/${getCoversationID(message.fromId)}/messages/")
        .doc(message.sent)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message for specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser a) {
    return fire
        .collection("chats/${getCoversationID(a.id)}/messages/")
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }

  //make function for send image in chat
  static Future<void> sendChatImage(ChatUser a, File file) async {
    //getting image file extension
    final extn = file.path.split('.').last;

    //get user uid and file extn
    final ref = storage.ref().child(
        "images/${getCoversationID(a.id)}/${DateTime.now().millisecondsSinceEpoch}.$extn");

    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: "image/$extn")).then(
        (p0) => print("Data Transferred ; ${p0.bytesTransferred / 1000} kb"));

    //updating image in firestore
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(a, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await fire
        .collection('chats/${getCoversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await fire
        .collection('chats/${getCoversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
