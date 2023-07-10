// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:developer';
import 'package:chatkarlo/ChatRoomPage.dart';
import 'package:chatkarlo/chatRoomModel.dart';
import 'package:chatkarlo/main.dart';
import 'package:chatkarlo/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final usermodel Usermodel;
  final User firebaseUser;

  const SearchPage(
      // ignore: non_constant_identifier_names
      {super.key, required this.Usermodel, required this.firebaseUser});

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController searchController = TextEditingController();

  // ignore: non_constant_identifier_names
  Future<ChatRoomModel?> getChatroomModel(usermodel Targetuser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.Usermodel.uid}", isEqualTo: true)
        .where("participants.${Targetuser.uid}", isEqualTo: true)
        .get();

    // ignore: prefer_is_empty
    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingchatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingchatroom;

    } 
    else {
      ChatRoomModel newchatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastmessage: "",
        participants: {
          widget.Usermodel.uid.toString(): true,
          Targetuser.uid.toString(): true,
        },

       users: [widget.Usermodel.uid.toString(), Targetuser.uid.toString()],
        createdon: DateTime.now()
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newchatroom.chatroomid)
          .set(newchatroom.toMap());

      chatRoom = newchatroom;

      log("New chatroom Created");
    }
    
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ignore: prefer_const_constructors
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          // ignore: prefer_const_constructors
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                    labelText: "Email Address"
                ),
              ),
              
              // ignore: prefer_const_constructors
              SizedBox(
                height: 24,
              ),
              
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
                // ignore: prefer_const_constructors
                child: Text("search"),
              ),
              
              // ignore: prefer_const_constructors
              SizedBox(
                height: 22,
              ),
              
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("email", isEqualTo: searchController.text)
                      // .where("email", isNotEqualTo: widget.Usermodel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        // ignore: prefer_is_empty
                        if (dataSnapshot.docs.length > 0) {
                          Map<String, dynamic> userMap = dataSnapshot.docs[0]
                              .data() as Map<String, dynamic>;

                          usermodel searchUser = usermodel.fromMap(userMap);

                          return ListTile(
                            onTap: () async {
                              ChatRoomModel? chatroomModel = await getChatroomModel(searchUser);

                                  if(chatroomModel != null){

                              Navigator.of(context).pop();

                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ChatRoomPage(
                                  TargetUser: searchUser,
                                  firebaseUser: widget.firebaseUser,
                                  Usermodel: widget.Usermodel,
                                  chatroom: chatroomModel,
                                );
                              }
                              
                          )
                              );
                             }
                            },
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(searchUser.profilepic!),
                              backgroundColor: Colors.grey[500],
                            ),

                            title: Text(searchUser.fullname!),
                            subtitle: Text(searchUser.email!),
                            // ignore: prefer_const_constructors
                            trailing: Icon(Icons.keyboard_arrow_right),
                          );
                        } 
                        else {
                          // ignore: prefer_const_constructors
                          return Text("No Results Found");
                        }

                      } 
                      else if (snapshot.hasError) {
                        // ignore: prefer_const_constructors
                        return Text("An Error Occured");
                      } 
                      else {
                        // ignore: prefer_const_constructors
                        return Text("No Results Found");
                      }
                    }
                     else {
                      // ignore: prefer_const_constructors
                      return CircularProgressIndicator();
                    }
                  }
                 ),
            ],
          ),
        ),
      ),
    );
  }
}
