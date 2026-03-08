import 'package:flutter/material.dart';

import '../color/colors.dart';

class InternetExceptionWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  const InternetExceptionWidget({
    this.title = "Unable to show. Sorry for inconvenience",
    required this.onPress,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          const Icon(
            Icons.cloud_off,
            color: Colors.red,
            size: 50,
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(top: 30),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(fontSize: 20.0),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          ElevatedButton(
            onPressed: onPress,
            child: Text(
                'Retry',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
            ),
          ),
        ],
      ),
    );
  }
}
