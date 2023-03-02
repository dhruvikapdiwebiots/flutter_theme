import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_theme/config.dart';

class CommonImage extends StatelessWidget {
  final String? image, name;
final bool isStatusPage;
  const CommonImage({Key? key, this.image, this.name,this.isStatusPage = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return image != ""
        ? CachedNetworkImage(
            imageUrl: image!,
            imageBuilder: (context, imageProvider) => Container(
                  height: isStatusPage ? Sizes.s50 :Sizes.s45,
                  width: isStatusPage ? Sizes.s50 :Sizes.s45,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                      color: appCtrl.appTheme.contactBgGray,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 12, cornerSmoothing: 1),
                      ),
                      image: DecorationImage(
                          fit: BoxFit.fill, image: NetworkImage('$image'))),
                ),
            placeholder: (context, url) => Container(
                  height: isStatusPage ? Sizes.s50 :Sizes.s45,
                  width: isStatusPage ? Sizes.s50 :Sizes.s45,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                      color: (colors.toList()..shuffle()).first,
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
                      style: AppCss.poppinsblack16
                          .textColor(appCtrl.appTheme.white)),
                ),
            errorWidget: (context, url, error) => Container(
                  height: isStatusPage ? Sizes.s50 :Sizes.s45,
                  width: isStatusPage ? Sizes.s50 :Sizes.s45,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                      color: (colors.toList()..shuffle()).first,
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
            height: isStatusPage ? Sizes.s50 :Sizes.s45,
            width: isStatusPage ? Sizes.s50 :Sizes.s45,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
                color: (colors.toList()..shuffle()).first,
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                )),
            child: Text(
              name!.length > 2
                  ? name!.replaceAll(" ", "").substring(0, 2).toUpperCase()
                  : name![0],
              style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.white),
            ),
          );
  }
}
