

import '../config.dart';

class SocialLayout extends StatelessWidget {
  const SocialLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
        builder: (loginCtrl) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
             /* LoginWidget().commonSocial(imageAssets.facebook, onTap: () =>
                  loginCtrl.loginWithFB(),padding:Insets.i5
              )*/

              LoginWidget().commonSocial(imageAssets.gmail, onTap: () =>
                  loginCtrl.initiateSignIn("G"),padding: Insets.i10
              ),
              /*   Padding(
                  padding: EdgeInsets.all(0),
                  child: IconButton(
                    iconSize: 44.0,
                    onPressed: () => _signInAnonymously(),
                    icon: Icon(Icons.account_circle, color: appCtrl.appTheme.primary),
                  ),
                ),*/

              LoginWidget().commonSocial(imageAssets.phone, onTap: () =>
                  Get.toNamed(routeName.phone),padding: Insets.i10
              ),
            ],
          );
        }
    );
  }
}
