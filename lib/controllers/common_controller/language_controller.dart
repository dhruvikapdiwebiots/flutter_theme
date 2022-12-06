import '../../config.dart';

class LanguageController extends GetxController {
  final storage = GetStorage();

  //language selection
  languageSelection(e) async {
    if (e['name'] == "english" ||
        e['name'] == 'अंग्रेजी' ||
        e['name'] == 'انجليزي' ||
        e['name'] == '영어' ||
        e['name'] == 'Anglais') {
      var locale = const Locale("en", 'US');
      Get.updateLocale(locale);
      Get.forceAppUpdate();
      appCtrl.languageVal = "en";
      storage.write(Session.languageCode, "en");
      storage.write(Session.countryCode, "US");
    } else if (e['name'] == "arabic" ||
        e['name'] == 'अरबी' ||
        e['name'] == 'عربي' ||
        e['name'] == '아랍어' ||
        e['name'] == 'arabe') {
      var locale = const Locale("ar", 'AE');
      Get.updateLocale(locale);
      Get.forceAppUpdate();
      appCtrl.languageVal = "ar";
      storage.write(Session.languageCode, "ar");
      storage.write(Session.countryCode, "AE");
    } else if (e['name'] == "korean" ||
        e['name'] == 'कोरियाई' ||
        e['name'] == 'كوري' ||
        e['name'] == '한국어' ||
        e['name'] == 'coréen') {
      var locale = const Locale("ko", 'KR');
      Get.updateLocale(locale);
      Get.forceAppUpdate();
      appCtrl.languageVal = "ko";
      storage.write(Session.languageCode, "ko");
      storage.write(Session.countryCode, "KR");
    } else if (e['name'] == "hindi" ||
        e['name'] == 'हिंदी' ||
        e['name'] == 'هندي' ||
        e['name'] == '힌디어' ||
        e['name'] == 'hindi') {
      appCtrl.languageVal = "hi";
      var locale = const Locale("hi", 'IN');
      Get.updateLocale(locale);
      Get.forceAppUpdate();
      storage.write(Session.languageCode, "hi");
      storage.write(Session.countryCode, "IN");
    } else if (e['name'] == "french" ||
        e['name'] == 'Français' ||
        e['name'] == 'فرنسي' ||
        e['name'] == 'फ्रेंच' ||
        e['name'] == '프랑스 국민') {
      appCtrl.languageVal = "fr";
      var locale = const Locale("fr", 'FR');
      Get.updateLocale(locale);
      Get.forceAppUpdate();
      storage.write(Session.languageCode, "fr");
      storage.write(Session.countryCode, "FR");
    }
    update();
    appCtrl.update();

    Get.forceAppUpdate();

    Get.forceAppUpdate();
    Get.back();
  }
}
