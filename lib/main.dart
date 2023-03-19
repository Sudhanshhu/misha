import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:just_todo_for_job/ui/add_todo_page.dart';
import 'package:just_todo_for_job/ui/home_page.dart';
import 'package:just_todo_for_job/ui/text_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      routes: {
        "addTodoPage": (context) => const AddTodo(),
        "htmlEditorExample": (context) => const HtmlEditorExample()
      },
      home: const HomePage(),
    );
  }
}
