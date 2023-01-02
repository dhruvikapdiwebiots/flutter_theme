import 'package:flip_card/flip_card.dart';

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
              child: Form(
                key: phoneCtrl.formKey,
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(imageAssets.login1,fit: BoxFit.fitWidth,width: MediaQuery.of(context).size.width,).paddingSymmetric(vertical: Insets.i20),
                        const VSpace(Sizes.s15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fonts.yourPhone.tr,
                                style: AppCss.poppinsblack20
                                    .textColor(appCtrl.appTheme.blackColor)),
                            const VSpace(Sizes.s15),
                            Text(fonts.phoneDesc.tr,
                                style: AppCss.poppinsMedium14
                                    .textColor(
                                        appCtrl.appTheme.blackColor.withOpacity(.5))
                                    .textHeight(1.2)
                                    .letterSpace(.1)),
                            const VSpace(Sizes.s45),
                            CommonTextBox(
                                labelText: fonts.mobileNumber.tr,
                                controller: phoneCtrl.phone,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: appCtrl.appTheme.primary),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r50)),
                                onTap: () {},
                                onChanged: (val) {
                                  if (val.length == 10) {
                                    phoneCtrl.isCorrect = true;
                                    phoneCtrl.dismissKeyboard();
                                  } else {
                                    phoneCtrl.isCorrect = false;
                                  }
                                  phoneCtrl.update();
                                },
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return fonts.phoneError.tr;
                                  } else if (val.length < 10) {
                                    return fonts.phoneError.tr;
                                  } else if (val.length == 10) {
                                    return null;
                                  } else {
                                    return null;
                                  }
                                },
                                suffixIcon: phoneCtrl.isCorrect
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                errorText: phoneCtrl.mobileNumber
                                    ? fonts.phoneError.tr
                                    : null),
                            const VSpace(Sizes.s55),
                            CommonButton(
                                title: "Request OTP",
                                radius: AppRadius.r50,
                                onTap: () => phoneCtrl.checkValidation() ,
                                style: AppCss.poppinsMedium18
                                    .textColor(appCtrl.appTheme.whiteColor)),
                          ],
                        ).paddingAll(Insets.i15)
                        /* Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward,
                                  color: appCtrl.appTheme.whiteColor)
                              .paddingAll(Insets.i8)
                              .decorated(
                                  color: appCtrl.appTheme.primary,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r50))
                              .inkWell(onTap: () => phoneCtrl.checkValidation()),
                        )*/
                      ]),
                ),
              )),
        ),
      );
    });
  }
}
