import 'dart:developer';

//import 'package:camera/camera.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/controllers/recent_chat_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  cameras = await availableCameras();
  Get.put(LoadingController());
  // Set the background messaging handler early on, as a named top-level function
  Get.put(AppController());
  Get.put(FirebaseCommonController());
  Get.put(CustomNotificationController());
  //Get.put(CustomNotificationController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    lockScreenPortrait();
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, AsyncSnapshot<SharedPreferences> snapData) {
          if (snapData.hasData) {
            log("HAS DATA ");
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => FetchContactController()),
                ChangeNotifierProvider(create: (_) => RecentChatController()),
              ],
              child: GetMaterialApp(
                builder: (context, widget) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: widget!,
                  );
                },
                debugShowCheckedModeBanner: false,
                translations: Language(),
                locale: const Locale('en', 'US'),
                fallbackLocale: const Locale('en', 'US'),
                // tran
                title: fonts.chatify.tr,
                home: Splash(pref: snapData.data!),
                getPages: appRoute.getPages,
                theme: AppTheme.fromType(ThemeType.light).themeData,
                darkTheme: AppTheme.fromType(ThemeType.dark).themeData,
                themeMode: ThemeService().theme,
              ),
            );
          } else {
            log("NO DATA ");
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => FetchContactController()),
                ChangeNotifierProvider(create: (_) => RecentChatController()),
              ],
              child: MaterialApp(
                  theme: AppTheme.fromType(ThemeType.light).themeData,
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                      backgroundColor: appCtrl.appTheme.primary,
                      body: Center(
                          child: Image.asset(
                        imageAssets.splashIcon,
                        // replace your Splashscreen icon
                        width: Sizes.s210,
                      )))),
            );
          }
        });
  }

  lockScreenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
