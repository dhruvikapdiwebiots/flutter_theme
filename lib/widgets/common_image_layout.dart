import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/widgets/common_photo_view.dart';

class CommonImage extends StatelessWidget {
  final String? image, name;
  final double height, width;

  const CommonImage(
      {Key? key,
      this.image,
      this.name,
      this.width = Sizes.s45,
      this.height = Sizes.s45})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return image != "" && image != null
        ? CachedNetworkImage(
            imageUrl: image!,
            imageBuilder: (context, imageProvider) => Container(
                  height: height,
                  width: width,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                      color: appCtrl.appTheme.contactBgGray,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 12, cornerSmoothing: 1),
                      ),
                      image: DecorationImage(
                          fit: BoxFit.fill, image: NetworkImage('$image'))),
                ).inkWell(onTap: (){
                  Get.to(CommonPhotoView(image: image));
            }),
            placeholder: (context, url) => Container(
                  height: height,
                  width: width,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                      color: const Color(0xff3282B8),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 12, cornerSmoothing: 1),
                      ),
                      image: DecorationImage(
                          fit: BoxFit.fitWidth, image: NetworkImage('$image'))),
                  child: Text(
                      name != null ?  name!.length > 2
                          ? name!
                              .replaceAll(" ", "")
                              .substring(0, 2)
                              .toUpperCase()
                          : name![0] : "C",
                      style: AppCss.poppinsblack16
                          .textColor(appCtrl.appTheme.white)),
                ),
            errorWidget: (context, url, error) => Container(
                  height: height,
                  width: width,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                      color: const Color(0xff3282B8),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 12, cornerSmoothing: 1),
                      ),
                      image: DecorationImage(
                          fit: BoxFit.fitWidth, image: NetworkImage('$image'))),
                  child: Text(
                    name!.length > 2
                        ? name!
                            .replaceAll(" ", "")
                            .substring(0, 2)
                            .toUpperCase()
                        : name![0],
                    style:
                        AppCss.poppinsblack16.textColor(appCtrl.appTheme.white),
                  ),
                ))
        : Container(
            height: height,
            width: width,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
                color: const Color(0xff3282B8),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                )),
            child: Text(
                name!= null?  name!.isNotEmpty?   name!.length > 2
                  ? name!.replaceAll(" ", "").substring(0, 2).toUpperCase()
                  : name![0] : "C" :"C",
              style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.white),
            ),
          );
  }
}
