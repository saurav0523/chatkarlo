// ignore_for_file: file_names, non_constant_identifier_names

import 'package:chatkarlo/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {


   static Future<usermodel?> getUserModelById(String uid) async {
    usermodel? Usermodel;

    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docSnap.data() != null) {
      Usermodel = usermodel.fromMap(docSnap.data() as Map<String, dynamic>);
    }

    return Usermodel;
  }


}
