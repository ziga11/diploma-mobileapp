import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/shared/widgets/form_field.dart';

class ToggleFormField extends DiplomaFormField {
  final bool initialVisibleText;

  const ToggleFormField({
    super.key,
    required super.label,
    required super.controller,
    this.initialVisibleText = true,
  }) : super(suffixIcon: null);

  @override
  State<ToggleFormField> createState() => ToggleFormFieldState();
}

class ToggleFormFieldState extends State<ToggleFormField> {
  late bool visibleText;

  @override
  void initState() {
    super.initState();
    visibleText = widget.initialVisibleText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: Theme.of(context).textTheme.displaySmall,
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelStyle:
            TextStyle(fontWeight: FontWeight.bold, color: ColorTheme.white),
        floatingLabelAlignment: FloatingLabelAlignment.center,
        labelStyle: TextStyle(color: ColorTheme.white),
        hintText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(visibleText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              visibleText = !visibleText;
            });
          },
        ),
      ),
      obscureText: visibleText,
      textAlign: TextAlign.center,
      controller: widget.controller,
    );
  }
}
