import 'package:flutter/cupertino.dart';

import '../../../../config.dart';

class CurrentUserEmptyStatus extends StatelessWidget {
  final GestureTapCallback? onTap;
  const CurrentUserEmptyStatus({Key? key,this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListTile(
          onTap: onTap,
          title: Text(
            fonts.yourStatus.tr,
          ),
          leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                    backgroundImage:
                    AssetImage(imageAssets.user),
                    radius: 30),
                Icon(CupertinoIcons.add_circled_solid,
                    color: appCtrl.appTheme.whiteColor)
              ])),
    );
  }
}
