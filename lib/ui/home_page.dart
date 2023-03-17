import 'package:flutter/material.dart';
import 'package:just_todo_for_job/utils/const.dart';

import '../firebase_service/todo_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("addTodoPage");
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("To Dos"),
      ),
      body: StreamBuilder(
        stream: Todoservice.todosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return (snapshot.data != null && snapshot.data!.isNotEmpty)
                ? ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: snapshot.data![index].isCompleted,
                        title: Text(
                          snapshot.data![index].title,
                          style: snapshot.data![index].isCompleted
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough)
                              : null,
                        ),
                        onChanged: (value) {
                          try {
                            Todoservice.updateTodo(snapshot.data![index]
                                .copyWith(isCompleted: value));
                          } catch (e) {
                            showsnackBar(
                                title: "Something went wrong",
                                color: Colors.red);
                          }
                        },
                      );
                    },
                  )
                : const Center(child: Text("No Todos found please add some"));
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          return const Center(child: Text("Loading"));
        },
      ),
    );
  }
}
