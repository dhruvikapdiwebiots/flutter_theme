

import '../../../../config.dart';

class PhoneBody extends StatelessWidget {
  const PhoneBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PhoneController>(
      builder: (phoneCtrl) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedAlign(
                  alignment: phoneCtrl.visible
                      ? Alignment.bottomLeft
                      : Alignment.centerRight,
                  duration: const Duration(seconds: 1),
                  child: Text(fonts.yourPhone.tr,
                      style: AppCss.poppinsblack20.textColor(
                          appCtrl.appTheme.blackColor))),
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
              //phone input box
              const PhoneInputBox(),
              const VSpace(Sizes.s10),
              if (phoneCtrl.mobileNumber)
                AnimatedOpacity(
                    duration: const Duration(seconds: 3),
                    opacity: phoneCtrl.mobileNumber ? 1.0 : 0.0,
                    child: Text(fonts.phoneError.tr,
                        style: AppCss.poppinsMedium12
                            .textColor(appCtrl.appTheme.redColor))
                        .alignment(Alignment.centerRight)),
              const VSpace(Sizes.s55),
              CommonButton(
                  title: fonts.requestOTP.tr,
                  radius: AppRadius.r50,
                  height: Sizes.s50,
                  color: appCtrl.isTheme
                      ? appCtrl.appTheme.white
                      : appCtrl.appTheme.primary,
                  onTap: () => phoneCtrl.checkValidation(),
                  style: AppCss.poppinsMedium16
                      .textColor(appCtrl.appTheme.whiteColor))
            ]);
      }
    );
  }
}
