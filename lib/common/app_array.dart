import 'dart:ui';

import '../config.dart';

class AppArray{
  //language list
  var languageList = [
    {'name': 'english', 'locale': const Locale('en', 'US')},
    {'name': 'arabic', 'locale': const Locale('ar', 'AE')},
    {'name': 'hindi', 'locale': const Locale('hi', 'IN')},
    {'name': 'korean', 'locale': const Locale('ko', 'KR')}
  ];

  //bottom list
  var bottomList = [
    {'icon': Icons.image, 'title': "status"},
    {'icon': Icons.message, 'title': "chats"},
    {'icon': Icons.call, 'title': "calls"},
  ];

  //action list
  var actionList = [
    {'title': "broadCast"},
    {'title': "newGroup"},
    {'title': "setting"},
  ];

  //setting list
  var settingList = [
    {'icon': Icons.message, 'title': "chats"},
    {'icon': Icons.delete_forever, 'title': "deleteAccount"},
    {'icon': Icons.logout, 'title': "logout"},
    {'icon': Icons.supervised_user_circle_sharp, 'title': "inviteFriend"},
  ];
}