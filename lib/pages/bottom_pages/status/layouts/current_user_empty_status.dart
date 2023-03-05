import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../../../../config.dart';

class CurrentUserEmptyStatus extends StatelessWidget {
  final GestureTapCallback? onTap;
  final String? currentUserId;

  const CurrentUserEmptyStatus({Key? key, this.onTap, this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("currentUserId :$currentUserId");
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("phone", isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListTile(
                onTap: onTap,
horizontalTitleGap: 10,
                title: Text((snapshot.data!).docs[0]["name"],style: AppCss.poppinsBold14.textColor(appCtrl.appTheme.blackColor),),
                subtitle: Text("Tap to add status update",style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.txtColor)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: Insets.i12),
                leading: Stack(children: [
                  CommonImage(
                    height: Sizes.s50,
                    width: Sizes.s50,
                    image: "",
                    name: (snapshot.data!).docs[0]["name"],
                  ),
                  Positioned(
                    right: -2,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: SvgPicture.asset(
                        svgAssets.add,
                        height: Sizes.s18,
                      )
                          .decorated(
                              color: appCtrl.appTheme.primary,
                              shape: BoxShape.circle)
                          .paddingAll(Insets.i2)
                          .decorated(
                              color: appCtrl.appTheme.white,
                              shape: BoxShape.circle),
                    ),
                  ),
                ]).width(Sizes.s50 ));
          } else {
            return Container();
          }
        });
  }
}
