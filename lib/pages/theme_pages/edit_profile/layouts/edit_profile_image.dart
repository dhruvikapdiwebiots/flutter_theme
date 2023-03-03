import 'package:figma_squircle/figma_squircle.dart';

import '../../../../config.dart';

class EditProfileImage extends StatelessWidget {
  const EditProfileImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      builder: (editCtrl) {
        return  CachedNetworkImage(
            imageUrl: editCtrl.imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              height: Sizes.s110,
              width:  Sizes.s110,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                  color: appCtrl.appTheme.contactBgGray,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 22, cornerSmoothing: 1),
                  ),
                  image: DecorationImage(
                      fit: BoxFit.fill, image: NetworkImage('${editCtrl.imageUrl}'))),
            ),
            placeholder: (context, url) => Container(
              height: Sizes.s110,
              width:  Sizes.s110,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                  color: (colors.toList()..shuffle()).first,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 22, cornerSmoothing: 1),
                  ),
                  image: DecorationImage(
                      fit: BoxFit.fitWidth, image: NetworkImage(editCtrl.imageUrl))),
              child: Text(
                  editCtrl.user["name"].length > 2
                      ? editCtrl.user["name"]
                      .replaceAll(" ", "")
                      .substring(0, 2)
                      .toUpperCase()
                      : editCtrl.user["name"][0],
                  style: AppCss.poppinsblack16
                      .textColor(appCtrl.appTheme.white)),
            ),
            errorWidget: (context, url, error) => Container(
              height: Sizes.s110,
              width:  Sizes.s110,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                  color: (colors.toList()..shuffle()).first,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 22, cornerSmoothing: 1),
                  ),
                  image: DecorationImage(
                      fit: BoxFit.fitWidth, image: NetworkImage(editCtrl.imageUrl))),
              child: Text(
                editCtrl.user["name"].length > 2
                    ? editCtrl.user["name"]
                    .replaceAll(" ", "")
                    .substring(0, 2)
                    .toUpperCase()
                    : editCtrl.user["name"][0],
                style:
                AppCss.poppinsblack16.textColor(appCtrl.appTheme.white),
              ),
            ));
      }
    );
  }
}
