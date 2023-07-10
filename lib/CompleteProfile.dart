// ignore_for_file: non_constant_identifier_names, prefer_const_constructors_in_immutables, file_names

import 'dart:developer';
import 'dart:io';
import 'package:chatkarlo/UIHelper.dart';
import 'package:chatkarlo/homepage.dart';
import 'package:chatkarlo/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final usermodel Usermodel;
  final User firebaseUser;

  CompleteProfile(
      {Key? key, required this.Usermodel, required this.firebaseUser})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    File? croppedImage;
    await ImageCropper()
        .cropImage(
            sourcePath: file.path,
            // ignore: prefer_const_constructors
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 20)
        .then((value) {
      croppedImage = File(value!.path);
    });

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage!.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // ignore: prefer_const_constructors
            title: Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  // ignore: prefer_const_constructors
                  leading: Icon(Icons.photo_album),
                  // ignore: prefer_const_constructors
                  title: Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  // ignore: prefer_const_constructors
                  leading: Icon(Icons.camera_alt),
                  // ignore: prefer_const_constructors
                  title: Text("Take a photo"),
                ),
              ],
            ),
          );
        });
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();

    if (fullname == "" || imageFile == null) {
      log("Please fill all the fields");
      UIHelper.showAlertdialog(context, "Incomplete Data",
          "Please fill all the fields and upload a profile picture");
    }
     else {
      // log("Uploading data..");
      uploadData();
    }
  }

  void uploadData() async {

    UIHelper.showLoadingDialog(context, "Uploading image..");

    UploadTask uploadTask = FirebaseStorage.instance.ref("profilepictures").child(widget.Usermodel.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = fullNameController.text.trim();

    widget.Usermodel.fullname = fullname;
    widget.Usermodel.profilepic = imageUrl;

    await FirebaseFirestore.instance.collection("users").doc(widget.Usermodel.uid).set(widget.Usermodel.toMap()).then((value) {

       log("Data uploaded!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return homepage(
              Usermodel: widget.Usermodel, firebaseUser: widget.firebaseUser);
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        // ignore: prefer_const_constructors
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          // ignore: prefer_const_constructors
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              // ignore: prefer_const_constructors
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                // ignore: prefer_const_constructors
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (imageFile != null) ?
                      FileImage(imageFile!)
                          : null,
                  child:
                  (imageFile == null) ?
                      // ignore: prefer_const_constructors
                       Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
                ),
              ),
              
              // ignore: prefer_const_constructors
              SizedBox(
                height: 20,
              ),

              TextField(
                controller: fullNameController,
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),
              // ignore: prefer_const_constructors
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
                // ignore: prefer_const_constructors
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
