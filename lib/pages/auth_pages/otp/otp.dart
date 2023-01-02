import 'package:flutter_theme/config.dart';


class Otp extends StatelessWidget {
  final otpCtrl = Get.put(OtpController());

  Otp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(builder: (_) {
      return GetBuilder<PhoneController>(
        builder: (phoneCtrl) {
          return Scaffold(
            backgroundColor: appCtrl.appTheme.whiteColor,
            appBar: AppBar(
              backgroundColor: appCtrl.appTheme.whiteColor,
              elevation: 0,
              automaticallyImplyLeading:  false,
              leading: Icon(Icons.arrow_back,color: appCtrl.appTheme.blackColor,),
            ),
            body: Container(

              padding: const EdgeInsets.symmetric(
                  horizontal: Insets.i20, vertical: Insets.i20),
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(imageAssets.otp,fit: BoxFit.fitWidth,width: MediaQuery.of(context).size.width,).paddingSymmetric(vertical: Insets.i20),
                    const VSpace(Sizes.s15),
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
              ),
            ),
          );
        }
      );
    });
  }
}
