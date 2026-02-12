import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';

class DiplomaBtn extends StatelessWidget {
  final String title;
  final Color? bgColor;
  final Size? size;
  final bool isLoading;
  final double fontSize;
  final void Function()? onPressed;

  const DiplomaBtn({
    super.key,
    required this.title,
    this.onPressed,
    this.size,
    this.bgColor,
    this.fontSize = 20,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultSize = Size(width(context) * 0.9, height(context) * 0.1);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: size ?? defaultSize,
        maximumSize: size,
        backgroundColor: bgColor,
        shadowColor: bgColor,
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? AnimatedLotusLoader(size: (size?.height ?? defaultSize.height) / 2)
          : AutoSizeText(
              title,
              maxLines: 1,
              maxFontSize: 20,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
