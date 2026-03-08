import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final double size;
  const LoadingScreen({this.size = 60, super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.size,
        width: widget.size,
        child: Platform.isAndroid
            ? CircularProgressIndicator(
          color: Colors.blue,
        )
            : CupertinoActivityIndicator(
          color: Colors.blue,
        )
    );
  }
}
