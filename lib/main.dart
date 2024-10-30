import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCUxCuFY0NHDeXyUIYVqtJytwuOIRjBTVw",
      authDomain: "snakegame-56806.firebaseapp.com",
      projectId: "snakegame-56806",
      storageBucket: "snakegame-56806.appspot.com",
      messagingSenderId: "705412356306",
      appId: "1:705412356306:web:0c1af60ce0a0ea7493b50b",
      measurementId: "G-G14W1P9CHW"
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake game',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

 