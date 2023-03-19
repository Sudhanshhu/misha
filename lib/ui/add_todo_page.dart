import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_todo_for_job/firebase_service/todo_service.dart';
import 'package:just_todo_for_job/models/todo_model.dart';
import 'package:just_todo_for_job/widget/custom_text_form.dart';

import '../firebase_service/firebase_storage_api.dart';
import '../utils/const.dart';

class AddTodo extends StatefulWidget {
  final TodoModel? todo;
  static const routeName = "addTodoPage";
  const AddTodo({super.key, this.todo});

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  UploadTask? task;
  File? file;
  bool isLoading = false;
  bool toEdit = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String result = '';
  final HtmlEditorController controller = HtmlEditorController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    controller.disable();
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
                child: const Text("From Camera")),
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
  void initState() {
    if (widget.todo != null) {
      titleController.text = widget.todo?.title ?? "";
      descriptionController.text = widget.todo?.description ?? "";
      toEdit = true;
    }
    super.initState();
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
            HtmlEditor(
              controller: controller,
              otherOptions: const OtherOptions(height: 250),
              htmlToolbarOptions:
                  const HtmlToolbarOptions(defaultToolbarButtons: [
                FontButtons(
                    bold: true,
                    italic: true,
                    strikethrough: true,
                    subscript: false,
                    superscript: false,
                    clearAll: false),
                ListButtons(listStyles: false),
                InsertButtons(
                    hr: false,
                    picture: false,
                    audio: false,
                    otherFile: false,
                    table: false,
                    video: false)
              ]),
              htmlEditorOptions: HtmlEditorOptions(
                initialText: widget.todo?.description ?? "",
                hint: 'Your text here...',
                shouldEnsureVisible: true,
                mobileContextMenu: ContextMenu(),
                disabled: widget.todo != null ? true : false,
              ),
            ),
            if (file != null) SizedBox(height: 250, child: Image.file(file!)),
            if (widget.todo != null &&
                widget.todo!.imageUrl != null &&
                widget.todo!.imageUrl!.isNotEmpty)
              SizedBox(
                  height: 250, child: Image.network(widget.todo!.imageUrl!)),
            if (!toEdit)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                child: ElevatedButton(
                    onPressed: () {
                      getImage();
                    },
                    child: const Text("Pick image")),
              ),
            if (task != null) buildUploadStatus(task!),
            if (!toEdit)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
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
                        var txt = await controller.getText();
                        if (txt.contains('src="data:')) {
                          txt =
                              '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                        }
                        result = txt;
                        String imageUrl = "";
                        descriptionController.text = result;
                        if (file != null) {
                          imageUrl = await uploadFile(file!);
                        }
                        TodoModel todo = TodoModel(
                            title: titleController.text,
                            description: descriptionController.text,
                            imageUrl: imageUrl,
                            id: Todoservice.getId(),
                            dateTime: DateTime.now().toIso8601String(),
                            isCompleted: false);
                        Todoservice.addNewTodo(todo)
                            .then((value) => Navigator.of(context).pop());
                      } catch (e) {
                        showsnackBar(
                            title: "Something went wrong in adding todo",
                            color: Colors.red);
                      }
                    },
                    child: const Text("Submit")),
              )
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
              enabled: !toEdit,
              // initValue: widget.todo?.title ?? "",
              controller: titleController,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return "Please enter title";
                }
                return null;
              },
              hintText: "Enter title"),
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
