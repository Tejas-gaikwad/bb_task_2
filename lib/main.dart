import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home/info_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: "AIzaSyCZtkA9YUgl0BKLvhm15oIfrsOH6AvQsT0",
      appId: "1:64658336848:android:c993c5a982032b4b597555",
      messagingSenderId: "64658336848",
      projectId: "bb-task-2",
      storageBucket: "bb-task-2.appspot.com",
    ));

    runApp(const MyApp());
  } catch (e) {
    print("error -----   $e");
    return;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: InfoFormScreen(),
    );
  }
}
