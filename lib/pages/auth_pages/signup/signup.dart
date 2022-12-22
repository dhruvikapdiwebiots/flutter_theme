import '../../../config.dart';

class Signup extends StatelessWidget {
  final signupCtrl = Get.put(SignupController());

  Signup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupController>(builder: (_) {
      return Scaffold(
        key: signupCtrl.scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Column(children: <Widget>[
          VSpace(MediaQuery.of(context).padding.top),
          //back button
          CommonWidget().backIcon(),
          Expanded(
              child: SingleChildScrollView(
                  child: Stack(
                    alignment: Alignment.center,
                      children: <Widget>[
            const SignupBody(),
            if (signupCtrl.isLoading)
              LoginLoader(isLoading: signupCtrl.isLoading).height(MediaQuery.of(context).size.height)
          ])))
        ]),
      );
    });
  }
}
