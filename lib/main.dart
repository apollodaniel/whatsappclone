import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Login.dart';

import 'Home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseFirestore.instance
      .collection("users")
      .doc("001")
      .set({"nome": "apollo"});

  runApp(MaterialApp(
    home: const Login(),
    theme: ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.green,
        secondary: Colors.greenAccent
      )
    ),
    debugShowCheckedModeBanner: false,
  ));
}
