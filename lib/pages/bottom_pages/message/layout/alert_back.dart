import 'package:flutter/services.dart';

import '../../../../config.dart';

class AlertBack extends StatelessWidget {
  const AlertBack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text(fonts.alert.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  <Widget>[
          Text(fonts.areYouSure.tr),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(fonts.close.tr),
        ),
        TextButton(
          onPressed: () async {
            SystemNavigator.pop();
          },
          child:  Text(fonts.yes.tr),
        ),
      ],
    );
  }
}
