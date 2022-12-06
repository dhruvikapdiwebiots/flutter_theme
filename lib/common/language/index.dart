import 'package:get/get.dart';
import 'ar.dart';
import 'en.dart';
import 'fr.dart';
import 'hi.dart';
import 'kr.dart';

class Language extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en,
        'hi_IN': hi,
        'ar_AE': ar,
        'ko_KR': kr,
        'fr_FR': fr,
      };
}
