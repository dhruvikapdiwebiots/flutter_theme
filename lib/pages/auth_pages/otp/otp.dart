import 'package:flutter_theme/config.dart';


class Otp extends StatelessWidget {
  final otpCtrl = Get.put(OtpController());

  Otp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(builder: (_) {
      return GetBuilder<PhoneController>(
        builder: (phoneCtrl) {
          return Container(
            width: MediaQuery.of(context).size.height * 0.5,
            margin: const EdgeInsets.all(Insets.i10),
            padding: const EdgeInsets.symmetric(
                horizontal: Insets.i20, vertical: Insets.i20),
            decoration: BoxDecoration(
              color: appCtrl.appTheme.whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_back).inkWell(onTap: (){
                  phoneCtrl.cardKey.currentState!.toggleCard();
                  phoneCtrl.update();
                }),
                Stack(
                  children: [
                    TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 1),
                        tween: Tween(begin: 0,end: otpCtrl.val),

                        builder: (context,value,child) {
                          return Transform(
                            transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(value),alignment: Alignment.bottomCenter,
                            child: Column(children: const <Widget>[

                              Padding(
                                  padding:  EdgeInsets.all(Insets.i40),
                                  child:  OtpBody())
                            ]),
                          );
                        }
                    ),
                    if(otpCtrl.isLoading)
                      LoginLoader(isLoading: otpCtrl.isLoading,)
                  ],
                ),
              ],
            ),
          );
        }
      );
    });
  }
}
