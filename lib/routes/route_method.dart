//app file

import 'package:flutter_theme/extensions/tklmn.dart';
import 'package:flutter_theme/pages/auth_pages/phone/phone_wrap.dart';
import 'package:flutter_theme/pages/bottom_pages/call_list/layouts/call_contact_list.dart';
import 'package:flutter_theme/pages/theme_pages/all_contact/all_contact_list.dart';
import 'package:flutter_theme/pages/theme_pages/broadcast_chat/layouts/broadcast_profile/broadcast_search_user.dart';
import 'package:flutter_theme/pages/theme_pages/broadcast_chat/layouts/broadcast_profile/broadcast_profile.dart';
import 'package:flutter_theme/pages/theme_pages/chat_message/layouts/chat_user_profile/chat_user_profile.dart';
import 'package:flutter_theme/pages/theme_pages/fingerprint_and_lock_security/fingerprint_and_lock_security.dart';
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_profile/group_profile.dart';
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_profile/search_user.dart';
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/my_message_viewer.dart';
import 'package:flutter_theme/pages/theme_pages/new_contact/new_contact.dart';
import 'package:flutter_theme/pages/theme_pages/video_call/video_call.dart';
import 'package:flutter_theme/widgets/background_list.dart';
import '../pages/bottom_pages/dashboard/dashboard.dart';
import '../config.dart';
import '../pages/bottom_pages/status/layouts/my_status.dart';
import '../pages/theme_pages/audio_call/audio_call.dart';
import '../pages/theme_pages/group_chat_message/layouts/group_profile/add_participants.dart';
import '../pages/theme_pages/web_view.dart';
import 'route_name.dart';

RouteName _routeName = RouteName();

class AppRoute {
  final List<GetPage> getPages = [
    GetPage(name: _routeName.intro, page: () => const Intro()),
    GetPage(name: _routeName.phone, page: () => PhoneLogin()),
    GetPage(name: _routeName.phoneWrap, page: () =>const PhoneWrap()),
    GetPage(name: _routeName.otp, page: () => Otp()),
    GetPage(name: _routeName.dashboard, page: () =>const Dashboard()),
    GetPage(name: _routeName.editProfile, page: () => EditProfile()),
    GetPage(name: _routeName.chat, page: () =>const Chat()),
    GetPage(name: _routeName.setting, page: () => Setting()),
    GetPage(name: _routeName.contactList, page: () => const ContactList()),
    GetPage(name: _routeName.allContactList, page: () => const AllContactList()),
    GetPage(name: _routeName.groupChat, page: () => GroupChat()),
    GetPage(name: _routeName.groupChatMessage, page: () =>const GroupChatMessage()),
    GetPage(name: _routeName.confirmationScreen, page: () =>const ConfirmStatusScreen()),
    GetPage(name: _routeName.statusView, page: () =>const StatusScreenView()),
    GetPage(name: _routeName.broadcastChat, page: () =>const BroadcastChat()),
    GetPage(name: _routeName.backgroundList, page: () => const BackgroundList()),
    GetPage(name: _routeName.fingerLock, page: () =>  FingerPrintLock()),
    GetPage(name: _routeName.myStatus, page: () => const MyStatus()),
    GetPage(name: _routeName.chatUserProfile, page: () => const ChatUserProfile()),
    GetPage(name: _routeName.groupProfile, page: () => const GroupProfile()),
    GetPage(name: _routeName.broadcastProfile, page: () => const BroadcastProfile()),
    GetPage(name: _routeName.addParticipants, page: () =>  AddParticipants()),
    GetPage(name: _routeName.searchUser, page: () => const SearchUser()),
    GetPage(name: _routeName.broadcastSearchUser, page: () => const BroadcastSearchUser()),
    GetPage(name: _routeName.myMessageViewer, page: () => const MyMessageViewer()),
    GetPage(name: _routeName.callContactList, page: () => const CallContactList()),
    GetPage(name: _routeName.videoCall, page: () => const VideoCall()),
    GetPage(name: _routeName.audioCall, page: () => const AudioCall()),
    GetPage(name: _routeName.webView, page: () => const CheckoutWebView()),
    GetPage(name: _routeName.language, page: () =>  LanguageScreen()),
    GetPage(name: _routeName.addContact, page: () =>  NewContact()),
    GetPage(name: _routeName.jk, page: () => const CallFunc()),

  ];
}
