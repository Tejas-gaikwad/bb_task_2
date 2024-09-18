import 'package:flutter/material.dart';

class CommonTextfield extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final TextEditingController? controller;
  final int? maxLines;
  final bool? enabled;
  const CommonTextfield({
    super.key,
    this.validator,
    required this.hintText,
    this.keyboardType,
    this.onSaved,
    this.controller,
    this.maxLines,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(8.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(8.0),
          ),
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          )),
      onSaved: onSaved,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}


//  (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter your age';
//         }
//         return null;
//       },