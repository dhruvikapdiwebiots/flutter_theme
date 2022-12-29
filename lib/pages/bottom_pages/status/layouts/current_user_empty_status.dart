import 'package:flutter/cupertino.dart';

import '../../../../config.dart';

class CurrentUserEmptyStatus extends StatelessWidget {
  final GestureTapCallback? onTap;

  const CurrentUserEmptyStatus({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: onTap,
        title: Text(
          fonts.yourStatus.tr,
        ),
        leading: Stack(alignment: Alignment.bottomRight, children: [
          Image.asset(imageAssets.user).paddingAll(Insets.i15).decorated(
              color: appCtrl.appTheme.grey.withOpacity(.4),
              shape: BoxShape.circle),
          Icon(CupertinoIcons.add_circled_solid,
                  color: appCtrl.appTheme.whiteColor)
              .paddingAll(.5)
              .decorated(
                  color: appCtrl.appTheme.darkGray, shape: BoxShape.circle)
        ]));
  }
}
