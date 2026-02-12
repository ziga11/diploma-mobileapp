import 'package:flutter/material.dart';

double appBarHeight(BuildContext context) {
  final double topPadding = MediaQuery.of(context).padding.top;
  return AppBar().preferredSize.height + topPadding;
}

double width(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double height(BuildContext context) {
  return MediaQuery.of(context).size.height;
}
