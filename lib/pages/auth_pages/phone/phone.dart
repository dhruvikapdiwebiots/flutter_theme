import '../../../config.dart';

class Phone extends StatelessWidget {
  final phoneCtrl = Get.put(PhoneController());

  Phone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PhoneController>(builder: (_) {
      return Scaffold(
        backgroundColor: appCtrl.appTheme.accent,
        resizeToAvoidBottomInset: false,
        body: Column(children: <Widget>[
          VSpace(MediaQuery.of(context).padding.top),
          //back icon
          CommonWidget().backIcon(),
          Padding(
              padding: const EdgeInsets.all(Insets.i40),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    LoginWidget().logoImage(),
                    const VSpace(Sizes.s20),
                    Text(fonts.phoneDesc.tr,
                        textAlign: TextAlign.center,
                        style: AppCss.poppinsMedium16
                            .textColor(appCtrl.appTheme.primary).textHeight(1.2).letterSpace(.1)),
                    const VSpace(Sizes.s30),
                    CommonTextBox(
                        labelText: fonts.mobileNumber.tr,
                        focusNode: phoneCtrl.phoneFocus,
                        controller: phoneCtrl.phone,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        errorText: phoneCtrl.mobileNumber
                            ? fonts.phoneError.tr
                            : null),
                    const VSpace(Sizes.s30),
                    CommonButton(
                        title: fonts.next.tr,
                        radius: AppRadius.r25,
                        onTap: ()=>phoneCtrl.checkValidation(),
                        style: AppCss.poppinsMedium16
                            .textColor(appCtrl.appTheme.accent)),
                    const VSpace(Sizes.s10)
                  ])),
        ]),
      );
    });
  }
}
