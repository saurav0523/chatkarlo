// ignore: file_names
// ignore_for_file: prefer_const_constructors, duplicate_ignore, file_names

import 'dart:developer';

import 'package:chatkarlo/main.dart';
import 'package:chatkarlo/messageModel.dart';
import 'package:chatkarlo/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chatRoomModel.dart';

class ChatRoomPage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final usermodel TargetUser;
  final ChatRoomModel chatroom;
  // ignore: non_constant_identifier_names
  final usermodel Usermodel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      // ignore: non_constant_identifier_names
      required this.TargetUser,
      required this.chatroom,
      // ignore: non_constant_identifier_names
      required this.Usermodel,
      required this.firebaseUser});

  @override
  // ignore: library_private_types_in_public_api
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {

  TextEditingController messageController = TextEditingController();

  void sendmessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      messageModel newmessage = messageModel(
          messageid: uuid.v1(),
          sender: widget.Usermodel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false
          );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newmessage.messageid)
          .set(newmessage.toMap());

      widget.chatroom.lastmessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("message sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [

            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.TargetUser.profilepic.toString()),
            ),

            // ignore: prefer_const_constructors
            SizedBox(
              width: 10,
            ),

            Text(widget.TargetUser.fullname.toString()),
          ],
        ),
      ),
      body: SafeArea(
        // ignore: avoid_unnecessary_containers
        child: Container(
          child: Column(
            children: [


              Expanded(
                child: Container(
                  // ignore: prefer_const_constructors
                  padding: EdgeInsets.symmetric(horizontal: 12
                  ),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(widget.chatroom.chatroomid)
                        .collection("messages")
                        .orderBy("createdon", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot datasnapshot =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                            reverse: true,
                            itemCount: datasnapshot.docs.length,
                            itemBuilder: (context, index) {
                              messageModel currentmessage = messageModel
                                  .fromMap(datasnapshot.docs[index].data()
                                      as Map<String, dynamic>);

                              return Row(
                                mainAxisAlignment: (currentmessage.sender ==
                                        widget.Usermodel.uid)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                      // ignore: prefer_const_constructors
                                      margin: EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      // ignore: prefer_const_constructors
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (currentmessage.sender ==
                                                widget.Usermodel.uid)
                                            ? Colors.grey
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        currentmessage.text.toString(),
                                        // ignore: prefer_const_constructors
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                   ),
                                ],
                              );
                            },
                          );
                        } 
                        else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                "An Error occured! Please check your internet connection"),
                          );
                        } 
                        else {
                          return Center(
                            child: Text("say hi to your new friend"),
                          );
                        }
                      }
                      else{
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                 ),
              ),
            ),

              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                   vertical: 5
                   ),

                child: Row(
                  children: [

                    Flexible(
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter message"
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendmessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
