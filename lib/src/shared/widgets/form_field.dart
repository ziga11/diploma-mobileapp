import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';

class DiplomaFormField extends StatefulWidget {
  final String label;
  final Icon? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextEditingController controller;

  const DiplomaFormField(
      {super.key,
      required this.label,
      this.suffixIcon,
      required this.controller,
      this.readOnly = false,
      this.onTap,
      this.focusNode});

  @override
  State<DiplomaFormField> createState() => DiplomaFormFieldState();
}

class DiplomaFormFieldState extends State<DiplomaFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      style: Theme.of(context).textTheme.displaySmall,
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelStyle:
            TextStyle(fontWeight: FontWeight.bold, color: ColorTheme.white),
        floatingLabelAlignment: FloatingLabelAlignment.center,
        labelStyle: TextStyle(color: ColorTheme.white),
        hintText: widget.label,
        suffixIcon: widget.suffixIcon,
      ),
      onTap: widget.onTap,
      textAlign: TextAlign.center,
      controller: widget.controller,
    );
  }
}
