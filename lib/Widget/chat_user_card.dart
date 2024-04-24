import 'package:family_chat/Api/api.dart';
import 'package:family_chat/Widget/dialogs/profile_dialogs.dart';
import 'package:family_chat/helper/my_date_util.dart';
import 'package:flutter/material.dart';
import 'package:family_chat/main.dart';
import 'package:family_chat/Models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_chat/Screen/chatscreen.dart';
import 'package:family_chat/Models/message.dart';

//build custome widget

//chat ca

class ChatUserCard extends StatefulWidget {
  //accept detail from chatuser model

  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info if null no response
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      //fix width card size
      margin: EdgeInsets.symmetric(horizontal: mq.width * .05, vertical: 5),
      elevation: 0.5,

      child: InkWell(
        onTap: () {
          //enter a chat
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChatScreen(
                        user: widget.user,
                      )));
        },
        child: StreamBuilder(
          stream: Api.getLastMessages(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];

            return ListTile(

                //user profile pic
                leading: InkWell(
                  onTap: (){
                    showDialog(context: context, builder: (_)=>ProfileDialog(user:widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .5),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                //show user name from database
                title: Text(
                  widget.user.name,
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
                //last msg
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 2),
                  //if msg not null show last msg
                  //if unread image show image
                  child: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? "image"
                            : _message!.msg
                        : widget.user.about,
                    style: const TextStyle(color: Colors.black),
                    maxLines: 1,
                  ),
                ),
                //is mssge null show nthing hid green color
                trailing: _message == null
                    ? null
                    :
                    //last seen not see
                    _message!.read.isEmpty && _message!.fromId != Api.cu.uid
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(10)),
                            //message sent time
                          )
                        : Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: const TextStyle(color: Colors.black),
                          )

                // trailing: const Text("12:00 pm",style: TextStyle(
                //   color: Colors.black54
                // ),),
                );
          },
        ),
      ),
    );
  }
}
