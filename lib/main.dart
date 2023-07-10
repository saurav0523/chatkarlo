import 'package:chatkarlo/FirebaseHelper.dart';
import 'package:chatkarlo/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatkarlo/homepage.dart';
import 'package:uuid/uuid.dart';
import 'package:chatkarlo/LoginPage.dart';

var uuid = const Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    usermodel? thisUsermodel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUsermodel != null) {
      runApp(
          MyAppLoggedIn(Usermodel: thisUsermodel, firebaseUser: currentUser));
    }
     else {
      runApp(const MyApp());
    }
  } 
  else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ignore: prefer_const_constructors
      home: LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final usermodel Usermodel;
  final User firebaseUser;

  const MyAppLoggedIn(
      // ignore: non_constant_identifier_names
      { super.key, required this.Usermodel, required this.firebaseUser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homepage(
        Usermodel: Usermodel,
        firebaseUser: firebaseUser,
      ),
    );
  }
}
