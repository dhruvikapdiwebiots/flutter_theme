import 'dart:developer';

import 'package:figma_squircle/figma_squircle.dart';

import '../../../../config.dart';

class ImageLayout extends StatelessWidget {
  final String? id;
  final bool isLastSeen,isImageLayout ;

  const ImageLayout({Key? key, this.id, this.isLastSeen = true,this.isImageLayout = false })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("IO : $id;");
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("id", isEqualTo: id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (!snapshot.data!.docs.isNotEmpty) {
              return Stack(
                children: [
                  Container(
                      decoration: ShapeDecoration(
                          color: appCtrl.appTheme.grey.withOpacity(.4),
                          shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                  cornerRadius: 12, cornerSmoothing: 1))),
                      child: Image.asset(
                        imageAssets.user,
                        height: isImageLayout ?Sizes.s40 : Sizes.s45,
                        width:isImageLayout ?Sizes.s40 :  Sizes.s45,
                        color: appCtrl.appTheme.whiteColor,
                      ).paddingAll(Insets.i15)),
                  if (isLastSeen)
                    if ((snapshot.data!).docs[0]["status"] != "Offline")
                      Positioned(
                        right: 3,
                        bottom: 10,
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(Icons.circle,
                                    color: appCtrl.appTheme.greenColor,
                                    size: Sizes.s12)
                                .paddingAll(Insets.i2)
                                .decorated(
                                    color: appCtrl.appTheme.whiteColor,
                                    shape: BoxShape.circle)),
                      )
                ],
              );
            } else {
              return Stack(
                children: [
                  CommonImage(
                      height: isImageLayout ?Sizes.s40 : Sizes.s45,
                      width:isImageLayout ?Sizes.s40 :  Sizes.s45,
                      image: (snapshot.data!).docs[0]["image"],
                      name: (snapshot.data!).docs[0]["name"]),
                  if (isLastSeen)
                    Positioned(
                      right: -2,
                      bottom: 0,
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.circle,
                                  color: appCtrl.appTheme.greenColor,
                                  size: Sizes.s12)
                              .paddingAll(Insets.i2)
                              .decorated(
                                  color: appCtrl.appTheme.whiteColor,
                                  shape: BoxShape.circle)),
                    )
                ],
              );
            }
          } else {
            return Container(
              height: isImageLayout ?Sizes.s40 : Sizes.s45,
              width:isImageLayout ?Sizes.s40 :  Sizes.s45,
              decoration: ShapeDecoration(
                  color: appCtrl.appTheme.grey.withOpacity(.4),
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 12, cornerSmoothing: 1))),
              child: Image.asset(
                imageAssets.user,
                height: isImageLayout ?Sizes.s40 : Sizes.s45,
                width:isImageLayout ?Sizes.s40 :  Sizes.s45,
                color: appCtrl.appTheme.whiteColor,
              ).paddingAll(Insets.i15),
            );
          }
        });
  }
}
