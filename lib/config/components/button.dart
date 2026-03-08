import 'package:flutter/material.dart';

import '../color/colors.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  const RoundButton({required this. title, required this.onPress,super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.red
        ),
        child: Center(
          child: Text(title),
        ),
      ),
    );
  }
}
