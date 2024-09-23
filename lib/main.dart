import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:komatsu_diagnostic/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCGc3Y1v4-iib5ayywFuunIIttYIhPfb0c",
      appId: "1:612392661218:android:9f0928b7841be33990aebb",
      messagingSenderId: "612392661218",
      projectId: "komatsu-diagnostic",
      storageBucket: "gs://komatsu-diagnostic.appspot.com",
    ),
  );

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  runApp(const MaterialApp(
    title: "Komatsu Diagnostic",
    home: SplashScreen(),
  ));
}
