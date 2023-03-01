
import 'package:flutter_theme/config.dart';

extension CommonExtension on Widget{
  // decoration
  Widget commonDecoration() => Container(child: this).decorated(
      color: appCtrl.appTheme.whiteColor,
      borderRadius: BorderRadius.circular(AppRadius.r10),
      boxShadow: [
        const BoxShadow(
            color: Color.fromRGBO(49, 100, 189, 0.08),
            offset: Offset(0, 2),
            blurRadius: 15)
      ]);
}