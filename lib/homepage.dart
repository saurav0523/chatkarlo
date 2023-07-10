// ignore_for_file: camel_case_types, prefer_const_constructors, duplicate_ignore, non_constant_identifier_names

import 'package:chatkarlo/ChatRoomPage.dart';
import 'package:chatkarlo/FirebaseHelper.dart';
import 'package:chatkarlo/LoginPage.dart';
import 'package:chatkarlo/SearchPage.dart';
import 'package:chatkarlo/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:chatkarlo/UIHelper.dart';
import 'chatRoomModel.dart';
// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';

class homepage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final usermodel Usermodel;
  final User firebaseUser;

  // ignore: non_constant_identifier_names
  const homepage(
      {super.key, required this.Usermodel, required this.firebaseUser});

  @override
  // ignore: library_private_types_in_public_api
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: duplicate_ignore
      appBar: AppBar(
        centerTitle: true,
        // ignore: prefer_const_constructors
        title: Text("Chat Karlo"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // ignore: use_build_context_synchronously
              Navigator.popUntil(context, (route) => route.isFirst);
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        // ignore: avoid_unnecessary_containers
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("users", arrayContains: widget.Usermodel.uid).orderBy("createdon")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomsnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomsnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel(
                        chatroomid: chatRoomsnapshot.docs[index].id,
                        lastmessage: (chatRoomsnapshot.docs[index].data()
                            as Map<String, dynamic>)["lastmessage"],
                        participants: (chatRoomsnapshot.docs[index].data()
                            as Map<String, dynamic>)["participants"],
                      );


                              
                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;

                      List<String> participantskeys =
                          participants.keys.toList();

                      participantskeys.remove(widget.Usermodel.uid);

                      return FutureBuilder(
                        future: FirebaseHelper.getUserModelById(
                            participantskeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData.data != null) {
                              // ignore: non_constant_identifier_names
                              usermodel Targetuser = userData.data as usermodel;

                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        TargetUser: Targetuser,
                                        chatroom: chatRoomModel,
                                        Usermodel: widget.Usermodel,
                                        firebaseUser: widget.firebaseUser,
                                      );
                                    }),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      Targetuser.profilepic.toString()),
                                ),
                                title: Text(Targetuser.fullname.toString()),
                                // subtitle: Container(
                                //   child: Text(chatRoomModel.lastmessage ?? " ") ?

                                subtitle: (chatRoomModel.lastmessage
                                            .toString() !=
                                        "") ?
                                    Text(
                                        chatRoomModel.lastmessage.toString())
                                    : Text(
                                        "Say Hi To Your New Friend!",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                                ),
                                      ),



                          );

                            } 
                            else {
                              return Container();
                            }
                          }
                           else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                }
                 else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                 else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              } 
              else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                Usermodel: widget.Usermodel, firebaseUser: widget.firebaseUser);
          }
        )
      );
    },
        child: Icon(Icons.search)
      ),
    );
  }
}
