import 'package:flutter/material.dart';

import '../utils/const.dart';

class CustomTextForm extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final int? maxLine;

  const CustomTextForm({
    Key? key,
    required this.controller,
    required this.validator,
    required this.hintText,
    this.maxLine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        maxLines: maxLine,
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide:
                    BorderSide(color: AppConst.primaryColor // borderColor,
                        )),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide:
                    const BorderSide(color: Colors.indigo // borderColor,
                        )),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            hintText: hintText,
            suffixIcon: IconButton(
                onPressed: () {
                  controller.clear();
                },
                icon: const Icon(Icons.clear))),
      ),
    );
  }
}
