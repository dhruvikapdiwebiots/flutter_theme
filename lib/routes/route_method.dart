//app file





import 'package:flutter_theme/pages/theme_pages/all_contact/all_contact_list.dart';
import 'package:flutter_theme/pages/theme_pages/audio_call/audio_call.dart';
import '../pages/bottom_pages/dashboard/dashboard.dart';
import '../config.dart';
import '../pages/theme_pages/video_call/video_call.dart';
import 'route_name.dart';

RouteName _routeName = RouteName();

class AppRoute {
  final List<GetPage> getPages = [
    GetPage(name: _routeName.intro, page: () => const Intro()),
    GetPage(name: _routeName.login, page: () => Login()),
    GetPage(name: _routeName.forgotPassword, page: () => ForgotPassword()),
    GetPage(name: _routeName.signup, page: () => Signup()),
    GetPage(name: _routeName.phone, page: () => Phone()),
    GetPage(name: _routeName.otp, page: () => Otp()),
    GetPage(name: _routeName.dashboard, page: () =>const Dashboard()),
    GetPage(name: _routeName.editProfile, page: () => EditProfile()),
    GetPage(name: _routeName.chat, page: () =>const Chat()),
    GetPage(name: _routeName.setting, page: () => Setting()),
    GetPage(name: _routeName.contactList, page: () => ContactList()),
    GetPage(name: _routeName.allContactList, page: () => AllContactList()),
    GetPage(name: _routeName.groupChat, page: () => GroupChat()),
    GetPage(name: _routeName.groupChatMessage, page: () =>const GroupChatMessage()),
    GetPage(name: _routeName.confirmationScreen, page: () =>const ConfirmStatusScreen()),
    GetPage(name: _routeName.statusView, page: () =>const StatusScreenView()),
    GetPage(name: _routeName.otherSetting, page: () =>const OtherSetting()),
    GetPage(name: _routeName.broadcastChat, page: () =>const BroadcastChat()),
    GetPage(name: _routeName.videoCall, page: () => const VideoCall()),
    GetPage(name: _routeName.audioCall, page: () =>  AudioCall()),
  ];
}
