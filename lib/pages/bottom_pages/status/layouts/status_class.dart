import 'package:flutter_theme/config.dart';

class StatusClass {
  Widget titleLayout(title) => Row(children: [
        Text(title.toString().tr,
            style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.txtColor)),
        const HSpace(Sizes.s12),
        Expanded(
            child: Divider(
                color: appCtrl.appTheme.primary.withOpacity(.2), thickness: 1))
      ]).paddingSymmetric(horizontal: Insets.i12);
}
