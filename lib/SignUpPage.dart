
// ignore_for_file: file_names

import 'package:chatkarlo/CompleteProfile.dart';
import 'package:chatkarlo/UIHelper.dart';
import 'package:chatkarlo/usermodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // ignore: non_constant_identifier_names
  TextEditingController CpasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    // ignore: non_constant_identifier_names
    String Cpassword = CpasswordController.text.trim();

    if (email == "" || password == "" || Cpassword == "") {
      UIHelper.showAlertdialog(
          context, "Incomplete Data", "print fill all the fields");
    }
     else if (password != Cpassword) {
      UIHelper.showAlertdialog(context, "Password Mismatch",
          "The Passwords you Entered do not Match!");
    } 
    else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    // ignore: non_constant_identifier_names
    UserCredential? Credential;

    UIHelper.showLoadingDialog(context, "Creating new account..");

    try {
      Credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);


      UIHelper.showAlertdialog(
          context, "An Error Occured", ex.message.toString());
    }

    if (Credential != null) {
      String uid = Credential.user!.uid;
      usermodel newUser = usermodel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        // ignore: avoid_print
        print("New User Created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return CompleteProfile(
              Usermodel: newUser, firebaseUser: Credential!.user!);
        }
      )
    );
   }
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
                      fontWeight: FontWeight.bold),
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
                  decoration: InputDecoration(
                    labelText: "Password"
                    ),
                ),
                
                // ignore: prefer_const_constructors
                SizedBox(
                  height: 15,
                ),


                TextField(
                  controller: CpasswordController,
                  obscureText: true,
                  // ignore: prefer_const_constructors
                  decoration: InputDecoration(
                    labelText: " Confirm Password"
                    ),
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
                  child: Text("Sign Up"),
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
              "Already have an account?",
              // ignore: prefer_const_constructors
              style: TextStyle(
                fontSize: 20),
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              // ignore: prefer_const_constructors
              child: Text(
                "Log In",
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
