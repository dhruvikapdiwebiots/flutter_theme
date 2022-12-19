

import '../../../config.dart';

class Login extends StatelessWidget {
  final loginCtrl = Get.put(LoginController());

  Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (_) {
      return Scaffold(
        key: loginCtrl.scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
            decoration: BoxDecoration(color: appCtrl.appTheme.accent),
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Container(
                  decoration: BoxDecoration(color: appCtrl.appTheme.accent),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        loginCtrl.isLoading == false
                            ? const LoginBody()
                            : LoginLoader(isLoading: loginCtrl.isLoading,)
                      ])),
            ),
          ),
        ),
      );
    });
  }
}
