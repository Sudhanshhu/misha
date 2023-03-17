import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_todo_for_job/firebase_service/todo_service.dart';
import 'package:just_todo_for_job/models/todo_model.dart';
import 'package:just_todo_for_job/widget/custom_text_form.dart';

import '../firebase_service/firebase_storage_api.dart';
import '../utils/const.dart';

class AddTodo extends StatefulWidget {
  static const routeName = "addTodoPage";
  const AddTodo({super.key});

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  UploadTask? task;
  File? file;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  // Pick an image
  getImage() async {
    bool? pickImageByCamera = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text("Pick image"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("From Image")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("From Gallery")),
          ],
        );
      },
    );
    if (pickImageByCamera != null) {
      final XFile? image = pickImageByCamera
          ? await _picker.pickImage(source: ImageSource.camera)
          : await _picker.pickImage(source: ImageSource.gallery);

      // Capture a photo
      file = File(image!.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Todo"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            form(),
            if (file != null) Image.file(file!),
            OutlinedButton(
                onPressed: () {
                  getImage();
                },
                child: const Text("Pick image")),
            OutlinedButton(
                onPressed: () async {
                  bool isValid = _formKey.currentState!.validate();
                  if (!isValid) {
                    showsnackBar(
                        title: "Please enter all compulsory fields",
                        color: Colors.red);
                    return;
                  }
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    TodoModel todo = TodoModel(
                        title: titleController.text,
                        id: Todoservice.getId(),
                        dateTime: DateTime.now().toIso8601String(),
                        isCompleted: false);
                    Todoservice.addNewTodo(todo)
                        .then((value) => Navigator.of(context).pop());
                  } catch (e) {}
                },
                child: const Text("Submit"))
          ],
        ),
      ),
    );
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextForm(
              controller: titleController,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return "Please enter title";
                }
                return null;
              },
              hintText: "Enter title"),
          CustomTextForm(
              controller: descriptionController,
              validator: (String? value) {
                return null;
              },
              hintText: "Enter description")
        ],
      ),
    );
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return SizedBox(
              height: 100,
              child: Column(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Uploading  images"),
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      );

  Future sendMessage() async {
    String uploadedFileUrlList = "";
    if (file != null) {
      try {
        final url = await uploadFile(file!);
        if (url.isNotEmpty) {
          uploadedFileUrlList = url;
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<String> uploadFile(File uploadingFile) async {
    final fileName = DateTime.now().toIso8601String();

    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, uploadingFile);
    setState(() {});

    if (task == null) return "";
    try {
      final snapshot = await task!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      print('Download-Link: $urlDownload');
      return urlDownload;
    } catch (e) {
      return "";
    }
  }
}
