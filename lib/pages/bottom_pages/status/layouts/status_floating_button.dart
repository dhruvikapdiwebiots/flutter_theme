import 'dart:developer';


import '../../../../config.dart';


class StatusFloatingButton extends StatelessWidget {
  const StatusFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: Sizes.s40,
            margin: const EdgeInsets.only(bottom: Insets.i15),
            child: FloatingActionButton(
                backgroundColor: const Color(0xff999EA6),
                child: SvgPicture.asset(svgAssets.edit, height: Sizes.s15),
                onPressed: () => Get.to(const TextStatus())!.then((value) {
                      log("value : $value");
                    })),
          ),
          FloatingActionButton(
            onPressed: ()=> statusCtrl.pickAssets(),
            backgroundColor: appCtrl.appTheme.primary,
            child: Container(
              width: Sizes.s52,
              height: Sizes.s52,
              padding: const EdgeInsets.all(Insets.i12),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    appCtrl.isTheme
                        ? appCtrl.appTheme.primary.withOpacity(.8)
                        : appCtrl.appTheme.lightPrimary,
                    appCtrl.appTheme.primary
                  ])),
              child: SvgPicture.asset(svgAssets.camera, height: Sizes.s15),
            ),
          ),
        ],
      );
    });
  }
}
