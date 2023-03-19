import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:just_todo_for_job/models/todo_model.dart';
import 'package:just_todo_for_job/ui/add_todo_page.dart';

import '../firebase_service/todo_service.dart';
import '../utils/const.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("addTodoPage");
          // Navigator.of(context).pushNamed("htmlEditorExample");
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
                ? ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                          key: UniqueKey(),
                          startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: slideAblePane(snapshot, index)),
                          endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: slideAblePane(snapshot, index)),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      AddTodo(todo: snapshot.data![index])));
                            },
                            leading: Checkbox(
                                value: snapshot.data![index].isCompleted,
                                onChanged: (value) {
                                  try {
                                    Todoservice.updateTodo(snapshot.data![index]
                                        .copyWith(isCompleted: value ?? false));
                                  } catch (e) {
                                    showsnackBar(
                                        title: "Something went wrong",
                                        color: Colors.red);
                                  }
                                }),
                            title: Text(snapshot.data![index].title),
                          ));
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

  List<Widget> slideAblePane(
      AsyncSnapshot<List<TodoModel>> snapshot, int index) {
    return [
      SlidableAction(
        onPressed: (context) async {
          bool? confirmed = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text("Do you want to delete this Todo"),
                  actions: [
                    OutlinedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text("Yes")),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text("No"))
                  ],
                );
              });

          if (confirmed == true) {
            try {
              await Todoservice.deleteTodo(snapshot.data![index]);

              showsnackBar(
                title: "Successfully deleted",
              );
            } catch (e) {
              showsnackBar(
                  title: "Something went wrong in deleting Todo",
                  color: Colors.red);
            }
          }
        },
        backgroundColor: const Color(0xFFFE4A49),
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
      ),
    ];
  }
}
