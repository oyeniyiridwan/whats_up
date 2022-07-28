import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsup/auth_card.dart';

class Authentication extends StatefulWidget {
  const Authentication({Key? key}) : super(key: key);

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool _isLoading = false;
  void _submit(String email, String username, String password, Select select,
      File pickedImage, BuildContext context) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    final _auth = FirebaseAuth.instance;
    UserCredential result;
    try {
      if (select == Select.login) {
        result = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        result = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        final ref = FirebaseStorage.instance
            .ref()
            .child("user image")
            .child(result.user!.uid + ".jpg");
        await ref.putFile(pickedImage);
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(_auth.currentUser!.uid)
            .set({"username": username, "email": email, "imageUrl": url});
      }
    } on PlatformException catch (error) {
      setState(() {
        _isLoading = false;
      });
      var message = "Pls check your credentials...";
      if (error.message != null) {
        message = error.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Text(message),
        duration: const Duration(seconds: 3),
      ));
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      var message = "unable to ${select == Select.login ? "login" : "SignUp"}";
      print(error);
      if (error.toString().contains("already")) {
        message = "You re already registered, pls Login...";
      } else if (error.toString().contains("network")) {
        message = "Pls check your internet connection";
      } else if (error.toString().contains("badly")) {
        message = "Invalid email address";
      } else if (error.toString().contains("invalid")) {
        message = "wrong password";
      } else if (error.toString().contains("no user record")) {
        message = "Not registered, pls SignUp";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Text(message),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xffFFFFFF),
                    Colors.blue,
                    Colors.grey,
                    Colors.blueGrey,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 0.25, 0.5, 0.75])),
          child: SingleChildScrollView(
            child: SizedBox(
              height: height + 30,
              width: width,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AuthCard(
                  isLoading: _isLoading,
                  submit: _submit,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

enum Select { login, signup }
