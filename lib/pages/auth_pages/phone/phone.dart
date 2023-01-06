import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../config.dart';

class Phone extends StatelessWidget {
  final phoneCtrl = Get.put(PhoneController());

  Phone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PhoneController>(builder: (_) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: appCtrl.appTheme.whiteColor,
          body: Container(
              color: appCtrl.appTheme.whiteColor,
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOpacity(
                          opacity: phoneCtrl.visible ? 1.0 : 0.0,
                          duration: const Duration(seconds: 2),
                          child: Image.asset(
                            imageAssets.login1,
                            fit: BoxFit.fitWidth,
                            width: MediaQuery.of(context).size.width,
                          ).paddingSymmetric(vertical: Insets.i20)),
                      const VSpace(Sizes.s15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedAlign(
                              alignment: phoneCtrl.visible
                                  ? Alignment.bottomLeft
                                  : Alignment.centerRight,
                              duration: const Duration(seconds: 1),
                              child: Text(fonts.yourPhone.tr,
                                  style: AppCss.poppinsblack20
                                      .textColor(appCtrl.appTheme.blackColor))),
                          const VSpace(Sizes.s15),
                          AnimatedOpacity(
                              opacity: phoneCtrl.visible ? 1.0 : 0.0,
                              duration: const Duration(seconds: 2),
                              child: Text(fonts.phoneDesc.tr,
                                  style: AppCss.poppinsMedium14
                                      .textColor(appCtrl.appTheme.blackColor
                                          .withOpacity(.5))
                                      .textHeight(1.2)
                                      .letterSpace(.1))),
                          const VSpace(Sizes.s45),

                          Row(
                            children: [
                              Theme(
                                data: ThemeData(
                                    dialogTheme: DialogTheme(
                                        backgroundColor:
                                            appCtrl.appTheme.whiteColor)),
                                child: Expanded(
                                    child: InternationalPhoneNumberInput(
                                  onInputChanged: (PhoneNumber number) {
                                    phoneCtrl.dialCode = number.dialCode!;
                                    phoneCtrl.update();
                                    if(number.phoneNumber!.isNotEmpty){
                                      phoneCtrl.mobileNumber = false;
                                    }
                                    phoneCtrl.update();
                                  },
                                  onInputValidated: (bool value) {
                                    phoneCtrl.isCorrect = value;
                                    phoneCtrl.update();
                                    phoneCtrl.dismissKeyboard();
                                  },
                                  selectorConfig: const SelectorConfig(
                                      leadingPadding: 0,
                                      trailingSpace: false,
                                      selectorType:
                                          PhoneInputSelectorType.BOTTOM_SHEET),
                                  selectorButtonOnErrorPadding: 0,
                                  ignoreBlank: false,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  selectorTextStyle:
                                      const TextStyle(color: Colors.black),
                                  initialValue: phoneCtrl.number,
                                  textFieldController: phoneCtrl.phone,
                                  scrollPadding: EdgeInsets.zero,
                                  formatInput: false,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                  inputBorder: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      gapPadding: 0),
                                  onSaved: (PhoneNumber number) {

                                  },
                                )),
                              ),
                              if (phoneCtrl.isCorrect)
                                const Icon(Icons.check_circle,
                                    color: Colors.green)
                            ],
                          ).paddingSymmetric(horizontal: Insets.i15).decorated(
                              border: Border(
                                  bottom: BorderSide(
                                      color: appCtrl.appTheme.primary))),
                          const VSpace(Sizes.s10),
                          if (phoneCtrl.mobileNumber)
                            AnimatedOpacity(
                                duration: const Duration(seconds: 3),
                                opacity: phoneCtrl.mobileNumber ? 1.0 : 0.0,
                                child: Text(fonts.phoneError.tr,
                                        style: AppCss.poppinsMedium12
                                            .textColor(Colors.red))
                                    .alignment(Alignment.centerRight)),
                          const VSpace(Sizes.s55),
                          CommonButton(
                              title: fonts.requestOTP.tr,
                              radius: AppRadius.r50,
                              height: Sizes.s50,
                              onTap: () => phoneCtrl.checkValidation(),
                              style: AppCss.poppinsMedium16
                                  .textColor(appCtrl.appTheme.whiteColor)),
                        ],
                      ).paddingAll(Insets.i15)
                    ]),
              )),
        ),
      );
    });
  }
}
