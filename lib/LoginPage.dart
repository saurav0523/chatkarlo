// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:chatkarlo/SignUpPage.dart';
import 'package:chatkarlo/UIHelper.dart';
import 'package:chatkarlo/homepage.dart';
import 'package:chatkarlo/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // get Usermodel => null;

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {

      UIHelper.showAlertdialog( context,"Incomplete Data","Please Fill The Unfilled Data");
    } 
    else {
      Login(email, password);
    }
  }

  // ignore: non_constant_identifier_names
  void Login(String email, String password) async {
    // ignore: non_constant_identifier_names
    UserCredential? Credential;

    UIHelper.showLoadingDialog(context, "Logging In..");

    try {
      Credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex) {
      Navigator.pop(context);

      UIHelper.showAlertdialog(
          context, "An Error Occured", ex.message.toString());
    }

    if (Credential != null) {
      String uid = Credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      // ignore: non_constant_identifier_names
      usermodel  Usermodel =
          usermodel.fromMap(userData.data() as Map<String, dynamic>);

      // ignore: avoid_print
      print("Log In Successful");
      // ignore: use_build_context_synchronously
      Navigator.popUntil(context, (route) => route.isFirst);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return homepage(
              Usermodel: Usermodel, firebaseUser: Credential!.user!);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        // ignore: prefer_const_constructors
        padding: EdgeInsets.symmetric(
          horizontal: 45,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [


                Text(
                  "Chat karlo",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 42,
                      fontWeight: FontWeight.bold
                      ),
                ),
                // ignore: prefer_const_constructors
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: emailController,
                  // ignore: prefer_const_constructors
                  decoration: InputDecoration(labelText: "Email Address"
                  ),
                ),
                
                // ignore: prefer_const_constructors
                SizedBox(
                  height: 15,
                ),
                
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  // ignore: prefer_const_constructors
                  decoration: InputDecoration(labelText: "Password"),
                ),
                
                // ignore: prefer_const_constructors
                SizedBox(
                  height: 25,
                ),

                
                CupertinoButton(
                  onPressed: () {
                    checkValues();
                  },
                  color: Theme.of(context).colorScheme.secondary,
                  // ignore: prefer_const_constructors
                  child: Text("Log In"),
                ),
              ],
            ),
          ),
        ),
      )
    ),
      // ignore: avoid_unnecessary_containers
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            // ignore: prefer_const_constructors
            Text(
              "Don't have an account?",
              // ignore: prefer_const_constructors
              style: TextStyle(fontSize: 20),
            ),

            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const SignUpPage();
                  }
                ),
               );
              },
              // ignore: prefer_const_constructors
              child: Text(
                "Sign Up",
                // ignore: prefer_const_constructors
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
