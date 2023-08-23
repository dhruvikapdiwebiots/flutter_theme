

import 'package:flutter_theme/pages/theme_pages/contact_list/fetch_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config.dart';
import '../../../theme_pages/contact_list/new_contact_check.dart';

class MessageFloatingButton extends StatelessWidget {
  final SharedPreferences? prefs;
  const MessageFloatingButton({Key? key,this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
      return FloatingActionButton(
          onPressed: () async {

            /* Get.to(() =>  NewContact(),
                  transition: Transition.downToUp);*/
            Navigator.push(
                context, MaterialPageRoute(builder: (context) =>  FetchContact(prefs: prefs,)));
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
