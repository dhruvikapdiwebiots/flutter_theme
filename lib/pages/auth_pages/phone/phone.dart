
import 'package:flip_card/flip_card.dart';

import '../../../config.dart';

class Phone extends StatelessWidget {
  final phoneCtrl = Get.put(PhoneController());

  Phone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return GetBuilder<PhoneController>(builder: (_) {
      return WillPopScope(
        onWillPop: ()async {
          return false;
        },
        child: Scaffold(
          body: Stack(children: [
            Container(
              height: Sizes.s450,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/login.png'),
                      fit: BoxFit.fill)),
            ),
            AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: phoneCtrl.visible ? 30 : 0,
                width: phoneCtrl.visible ? 80 : 0,
                height: 200,
                child: AnimatedOpacity(
                    // If the widget is visible, animate to 0.0 (invisible).
                    // If the widget is hidden, animate to 1.0 (fully visible).
                    opacity: phoneCtrl.visible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/light-1.png'))),
                    ))),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              top: phoneCtrl.visible ? 0 : -100,
              left: 140,
              width: 80,
              height: 150,
              child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/light-2.png'))),
              ),
            ),
            AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                right: 40,
                top: phoneCtrl.visible ? 40 : 0,
                width: 80,
                height: 150,
                child: Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/clock.png'))),
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FlipCard(
                  key: phoneCtrl.cardKey,
                  flipOnTouch: false,
                  front: Container(
                      margin: const EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.height * 0.5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: Insets.i20, vertical: Insets.i20),
                      decoration: BoxDecoration(
                        color: appCtrl.appTheme.whiteColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                      Form(
                        key: phoneCtrl.formKey,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const VSpace(Sizes.s15),
                          Text(fonts.yourPhone.tr,
                              style:
                              AppCss.poppinsblack20.textColor(appCtrl.appTheme.blackColor)),
                          const VSpace(Sizes.s15),
                          Text(fonts.phoneDesc.tr,
                              style: AppCss.poppinsMedium14
                                  .textColor(appCtrl.appTheme.blackColor.withOpacity(.5))
                                  .textHeight(1.2)
                                  .letterSpace(.1)),
                          const VSpace(Sizes.s45),
                          CommonTextBox(
                              labelText: fonts.mobileNumber.tr,
                              controller: phoneCtrl.phone,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              onTap: (){
                              },
                              onChanged: (val) {
                                if (val.length == 10) {
                                  phoneCtrl.isCorrect = true;
                                }else {
                                  phoneCtrl.isCorrect = false;
                                }
                                phoneCtrl.update();
                              },
                              validator: (val){
                                if(val!.isEmpty){
                                  return fonts.phoneError.tr;
                                } else  if (val.length < 10) {
                                  return fonts.phoneError.tr;
                                }else  if (val.length == 10) {
                                  return null;
                                }else{
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
                              errorText: phoneCtrl.mobileNumber ? fonts.phoneError.tr : null),
                          const VSpace(Sizes.s55),
                          Align(
                            alignment: Alignment.centerRight,
                            child:
                            Icon(Icons.arrow_forward, color: appCtrl.appTheme.whiteColor)
                                .paddingAll(Insets.i8)
                                .decorated(
                                color: appCtrl.appTheme.primary,
                                borderRadius: BorderRadius.circular(AppRadius.r50))
                                .inkWell(onTap: () =>phoneCtrl.checkValidation()),
                          )
                        ]),
                      )),
                  back:Otp(),
                ),
              ],
            )
          ]),
        ),
      );
    });
  }
}
