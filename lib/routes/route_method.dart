//app file


import '../config.dart';
import 'route_name.dart';

RouteName _routeName = RouteName();

class AppRoute {
  final List<GetPage> getPages = [
    GetPage(name: _routeName.intro, page: () => Intro()),
    GetPage(name: _routeName.login, page: () => Login()),
    GetPage(name: _routeName.forgotPassword, page: () => ForgotPassword()),
    GetPage(name: _routeName.signup, page: () => Signup()),
    GetPage(name: _routeName.phone, page: () => Phone()),
    GetPage(name: _routeName.otp, page: () => Otp()),
    GetPage(name: _routeName.dashboard, page: () =>const Dashboard()),
    GetPage(name: _routeName.editProfile, page: () => EditProfile()),
    GetPage(name: _routeName.chat, page: () => Chat()),
    GetPage(name: _routeName.setting, page: () => Setting()),
  ];
}
