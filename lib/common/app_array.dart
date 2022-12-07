import 'dart:ui';

import '../config.dart';

class AppArray{
  //language list
  var languageList = [
    {'name': 'english', 'locale': const Locale('en', 'US')},
    {'name': 'arabic', 'locale': const Locale('ar', 'AE')},
    {'name': 'hindi', 'locale': const Locale('hi', 'IN')},
    {'name': 'korean', 'locale': const Locale('ko', 'KR')},
    {'name': 'french', 'locale': const Locale('fr', 'FR')}
  ];

  var bottomList = [
    {'icon': Icons.home, 'title': "home"},
    {'icon': Icons.settings, 'title': "settings"},
  ];
}