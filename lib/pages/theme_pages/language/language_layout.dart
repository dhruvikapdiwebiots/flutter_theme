import 'package:flutter/cupertino.dart';
import '../../../../config.dart';

class LanguageLayout extends StatelessWidget {
  final dynamic value;
  final int? index, selectedIndex;
  final GestureTapCallback? onTap;

  const LanguageLayout(
      {super.key, this.value, this.index, this.onTap, this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Stack(alignment: Alignment.topLeft, children: [
        SizedBox(
                height: Sizes.s92,
                width: Sizes.s94,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /*Container(
                            height: Sizes.s34, width: Sizes.s34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
fit: BoxFit.cover,
                              image: NetworkImage(
                                  value["image"]
                              )
                            )
                          ),
                        )*/
                      CachedNetworkImage(
                        imageUrl: value["image"],
                        imageBuilder: (context, imageProvider) => Container(
                          height: Sizes.s34,
                          width: Sizes.s34,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover, image: imageProvider)),
                        ),
                        placeholder: (context, url) => Container(
                          height: Sizes.s34,
                          width: Sizes.s34,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: Sizes.s34,
                          width: Sizes.s34,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                      Divider(
                              height: 1,
                              color: appCtrl.appTheme.borderGray,
                              thickness: 1,
                              endIndent: 1,
                              indent: 1)
                          .paddingOnly(top: Insets.i12, bottom: Insets.i10),
                      Text(value["title"].toString().tr,
                          style: AppCss.poppinsSemiBold12
                              .textColor(appCtrl.appTheme.primary))
                    ]))
            .boxDecoration(
                color: selectedIndex == index
                    ? appCtrl.appTheme.primary.withOpacity(0.5)
                    : appCtrl.appTheme.borderGray),
        if (selectedIndex == index)
          Icon(CupertinoIcons.checkmark_alt_circle_fill,
                  color: appCtrl.appTheme.primary, size: Sizes.s18)
              .paddingAll(Insets.i6)
      ]).inkWell(onTap: onTap);
    });
  }
}

extension ChatzyExtensions on Widget {
  Widget boxDecoration({Color? color, double? bWidth}) =>
      SizedBox(child: this).decorated(
          color: appCtrl.appTheme.white,
          boxShadow: [
            BoxShadow(
                color: appCtrl.appTheme.borderGray.withOpacity(0.5),
                blurRadius: AppRadius.r5,
                spreadRadius: AppRadius.r2)
          ],
          border: Border.all(
              color: color ?? appCtrl.appTheme.borderGray, width: bWidth ?? 1),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.r8)));
}