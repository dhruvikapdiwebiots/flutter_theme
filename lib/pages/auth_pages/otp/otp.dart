import 'package:flutter_theme/config.dart';


class Otp extends StatelessWidget {
  final otpCtrl = Get.put(OtpController());

  Otp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(builder: (_) {
      return Scaffold(
          backgroundColor: appCtrl.appTheme.accent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Column(children: <Widget>[
                VSpace(MediaQuery.of(context).padding.top),
                //back button
                CommonWidget().backIcon(),
                const Padding(
                    padding:  EdgeInsets.all(Insets.i40),
                    child:  OtpBody())
              ]),
              if(otpCtrl.isLoading)
                LoginLoader(isLoading: otpCtrl.isLoading,)
            ],
          ));
    });
  }
}
