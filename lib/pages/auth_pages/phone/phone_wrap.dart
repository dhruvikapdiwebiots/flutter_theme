import 'dart:developer';

import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/controllers/recent_chat_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config.dart';

class PhoneWrap extends StatelessWidget {

  const PhoneWrap({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, AsyncSnapshot<SharedPreferences> snapData) {
          log("SNAP 111: ${snapData.hasData}");
          if (snapData.hasData) {
            appCtrl.pref = snapData.data;
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => FetchContactController()),
                ChangeNotifierProvider(create: (_) => RecentChatController()),
              ],
              child: PhoneLogin(preferences: snapData.data,)
            );
          } else {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => FetchContactController()),
                ChangeNotifierProvider(create: (_) => RecentChatController()),
              ],
              child: Scaffold(
                  backgroundColor: appCtrl.appTheme.primary,
                  body: Center(
                      child: Image.asset(
                        imageAssets.splashIcon,
                        // replace your Splashscreen icon
                        width: Sizes.s210,
                      ))),
            );
          }
        });
  }
}
