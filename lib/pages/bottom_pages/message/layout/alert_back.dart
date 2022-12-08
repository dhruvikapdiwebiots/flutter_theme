import 'package:flutter/services.dart';

import '../../../../config.dart';

class AlertBack extends StatelessWidget {
  const AlertBack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alert!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text("Are you sure you want to exit from the app"),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () async {
            SystemNavigator.pop();
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
