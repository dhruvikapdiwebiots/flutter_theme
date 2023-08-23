

import 'package:flutter_theme/widgets/common_photo_view.dart';

import '../../../../../config.dart';

class CenterPositionImage extends StatelessWidget {
  final int topAlign;
  final bool isSliverAppBarExpanded, isGroup, isBroadcast;
  final String? image, name;
  final GestureTapCallback? onTap;

  const CenterPositionImage(
      {Key? key,
      this.topAlign = 5,
      this.isSliverAppBarExpanded = false,
      this.isGroup = false,
      this.isBroadcast = false,
      this.onTap,
      this.image,
      this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / topAlign,
      child: AnimatedOpacity(
          duration: const Duration(milliseconds: 4),
          opacity: isSliverAppBarExpanded ? 0 : 1,
          child: Stack(
            children: [
              isBroadcast
                  ? Container(
                      height: Sizes.s110,
                      width: Sizes.s110,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                          color: appCtrl.appTheme.secondary,
                          shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                  cornerRadius: 22, cornerSmoothing: 1))),
                      child: SvgPicture.asset(svgAssets.audio))
                  : CachedNetworkImage(
                      imageUrl: image!,
                      imageBuilder: (context, imageProvider) => Container(
                          height: Sizes.s110,
                          width: Sizes.s110,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                              color: appCtrl.appTheme.contactBgGray,
                              shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                      cornerRadius: 22, cornerSmoothing: 1)),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage('$image')))).inkWell(onTap: ()=> Get.to(CommonPhotoView(image: image,))),
                      placeholder: (context, url) => Container(
                            height: Sizes.s110,
                            width: Sizes.s110,
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              color: appCtrl.appTheme.secondary,
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                    cornerRadius: 22, cornerSmoothing: 1),
                              ),
                            ),
                            child: Text(
                                name != null
                                    ? name!.length > 2
                                        ? name!
                                            .replaceAll(" ", "")
                                            .substring(0, 2)
                                            .toUpperCase()
                                        : name![0]
                                    : "C",
                                style: AppCss.poppinsblack16
                                    .textColor(appCtrl.appTheme.white)),
                          ),
                      errorWidget: (context, url, error) => Container(
                            height: Sizes.s110,
                            width: Sizes.s110,
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              color: appCtrl.appTheme.secondary,
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                    cornerRadius: 22, cornerSmoothing: 1),
                              ),
                            ),
                            child: Text(
                              name != null && name != ""
                                  ? name!.length > 2
                                      ? name!
                                          .replaceAll(" ", "")
                                          .substring(0, 2)
                                          .toUpperCase()
                                      : name![0]
                                  : "C",
                              style: AppCss.poppinsblack16
                                  .textColor(appCtrl.appTheme.white),
                            ),
                          )),
              if (isGroup)
                Positioned(
                    bottom: 0,
                    right: -2,
                    child: Container(
                      padding: EdgeInsets.all(Insets.i1),
                      decoration: ShapeDecoration(
                          color: appCtrl.appTheme.whiteColor,
                          shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                  cornerRadius: 8, cornerSmoothing: 1))),
                      child: Container(
                        padding: EdgeInsets.all(Insets.i5),
                        decoration: ShapeDecoration(
                            color: appCtrl.appTheme.primary,
                            shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                    cornerRadius: 8, cornerSmoothing: 1))),
                        child: SvgPicture.asset(
                          svgAssets.camera,
                          height: Sizes.s22,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ).inkWell(onTap: onTap))
            ],
          ).height(Sizes.s120).width(Sizes.s115)),
    );
  }
}
