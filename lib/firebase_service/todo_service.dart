import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_todo_for_job/models/todo_model.dart';

class Todoservice {
  final _db = FirebaseFirestore.instance;

  CollectionReference todoPath() {
    return _db.collection("id");
  }

  static String getId() {
    return FirebaseFirestore.instance.collection("todo").doc().id;
  }

  static Future<void> addNewTodo(TodoModel todoModel) async {
    await FirebaseFirestore.instance
        .collection("todo")
        .doc(todoModel.id)
        .set(todoModel.toMap());
  }

  static Future<void> updateTodo(TodoModel todoModel) async {
    await FirebaseFirestore.instance
        .collection("todo")
        .doc(todoModel.id)
        .update(todoModel.toMap());
  }

  static Stream<List<TodoModel>> todosStream() {
    Stream<QuerySnapshot<Object?>> stream =
        FirebaseFirestore.instance.collection("todo").snapshots();
    return stream.map((event) => event.docs
        .map((e) => TodoModel.fromMap(e.data() as Map<String, dynamic>))
        .toList());
  }
}
