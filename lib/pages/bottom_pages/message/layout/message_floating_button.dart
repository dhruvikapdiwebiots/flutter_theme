

import 'package:flutter_theme/pages/theme_pages/contact_list/fetch_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config.dart';

class MessageFloatingButton extends StatelessWidget {
  final SharedPreferences? prefs;
  const MessageFloatingButton({Key? key,this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
      return FloatingActionButton(
          onPressed: () async {

             Get.to(() =>  FetchContact(prefs: prefs,),
                  transition: Transition.downToUp);

          },
          backgroundColor: appCtrl.appTheme.primary,
          child: Container(
              width: Sizes.s52,
              height: Sizes.s52,
              padding: const EdgeInsets.all(Insets.i8),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    appCtrl.isTheme
                        ? appCtrl.appTheme.primary.withOpacity(.8)
                        : appCtrl.appTheme.lightPrimary,
                    appCtrl.appTheme.primary
                  ])),
              child: SvgPicture.asset(svgAssets.add, height: Sizes.s15)));
    });
  }
}
