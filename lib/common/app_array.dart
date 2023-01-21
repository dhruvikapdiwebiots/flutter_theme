
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
    {'icon': Icons.message, 'title': "chats"},
    {'icon': Icons.image, 'title': "status"},
    {'icon': Icons.image, 'title': "calls"},
  ];

  //action list
  var actionList = [
    {'title': "newBroadCast"},
    {'title': "newGroup"},
    {'title': "setting"},
  ];


  //statusAction list
  var statusAction = [

    {'title': "setting"},
  ];

  //callAction list
  var callsAction = [

    {'title': "clearLogs"},
    {'title': "setting"}
  ];

  //setting list
  var settingList = [
    {'icon': Icons.message, 'title': "chats"},
    {'icon': Icons.delete_forever, 'title': "deleteAccount"},
    {'icon': Icons.logout, 'title': "logout"},
  ];
}