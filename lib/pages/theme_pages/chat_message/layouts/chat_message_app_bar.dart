import 'dart:developer';

import 'package:figma_squircle/figma_squircle.dart';

import '../../../../config.dart';

class ChatMessageAppBar extends StatelessWidget with PreferredSizeWidget {
  final String? name, image, userId;
  final VoidCallback? callTap, videoTap;
  final GestureTapCallback?  moreTap;
  final bool isBlock;

  const ChatMessageAppBar(
      {Key? key,
      this.name,
      this.image,
      this.userId,
      this.callTap,
      this.moreTap,
      this.isBlock = false,
      this.videoTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
    return GetBuilder<ChatController>(
      builder: (chatCtrl) {
        return AppBar(
            backgroundColor: appCtrl.appTheme.whiteColor,
            shadowColor: const Color.fromRGBO(49, 100, 189, 0.08),
            bottomOpacity: 0.0,
            shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 20, cornerSmoothing: 1)),
            automaticallyImplyLeading: false,
            leadingWidth: Sizes.s70,
            toolbarHeight: Sizes.s90,
            titleSpacing: 0,
            leading: SvgPicture.asset(
                    appCtrl.isRTL ? svgAssets.arrowForward : svgAssets.arrowBack,
                    height: Sizes.s18)
                .paddingAll(Insets.i10)
                .decorated(
                    borderRadius: BorderRadius.circular(AppRadius.r10),
                    boxShadow: [
                      const BoxShadow(
                          offset: Offset(0, 2),
                          blurRadius: 5,
                          spreadRadius: 2,
                          color: Color.fromRGBO(0, 0, 0, 0.05))
                    ],
                    color: appCtrl.appTheme.whiteColor)
                .marginOnly(right: Insets.i10, top: Insets.i22, bottom: Insets.i22,left: Insets.i20)
                .inkWell(onTap: () => Get.back()),
            actions: [
              SvgPicture.asset(svgAssets.video, height: Sizes.s20)
                  .paddingAll(Insets.i10)
                  .decorated(
                      color: appCtrl.appTheme.white,
                      boxShadow: [
                        const BoxShadow(
                            offset: Offset(0, 2),
                            blurRadius: 5,
                            spreadRadius: 1,
                            color: Color.fromRGBO(0, 0, 0, 0.05))
                      ],
                      borderRadius: BorderRadius.circular(AppRadius.r10))
                  .marginSymmetric(vertical: Insets.i22)
                  .inkWell(onTap: videoTap),
              SvgPicture.asset(svgAssets.search, height: Sizes.s20)
                  .paddingAll(Insets.i10)
                  .decorated(
                      color: appCtrl.appTheme.white,
                      boxShadow: [
                        const BoxShadow(
                            offset: Offset(0, 2),
                            blurRadius: 5,
                            spreadRadius: 1,
                            color: Color.fromRGBO(0, 0, 0, 0.05))
                      ],
                      borderRadius: BorderRadius.circular(AppRadius.r10))
                  .marginSymmetric(horizontal: Insets.i10, vertical: Insets.i22)
                  .inkWell(onTap: callTap),
              PopupMenuButton(
                color: appCtrl.appTheme.whiteColor,
                padding: EdgeInsets.zero,
                iconSize: Sizes.s20,
                onSelected: (result) {
                  log("CAA");
                  chatCtrl.blockUser();
                },

                offset: Offset(0.0, appBarHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                itemBuilder: (ctx) => [
                  _buildPopupMenuItem(isBlock ? fonts.block.tr : fonts.unblock.tr,
                      isBlock ? svgAssets.unBlock : svgAssets.block, 2),
                ],
                child: SvgPicture.asset(svgAssets.more, height: Sizes.s22)
                    .paddingAll(Insets.i10),
              )
                  .decorated(
                      color: appCtrl.appTheme.white,
                      boxShadow: [
                        const BoxShadow(
                            offset: Offset(0, 2),
                            blurRadius: 5,
                            spreadRadius: 1,
                            color: Color.fromRGBO(0, 0, 0, 0.05))
                      ],
                      borderRadius: BorderRadius.circular(AppRadius.r10))
                  .marginSymmetric(vertical: Insets.i25)
                  .marginOnly(right: Insets.i20)
            ],
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ImageLayout(id: userId, isImageLayout: true,),
                const HSpace(Sizes.s8),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name ?? "",
                        textAlign: TextAlign.center,
                        style: AppCss.poppinsSemiBold14
                            .textColor(appCtrl.appTheme.blackColor),
                      ),
                      const VSpace(Sizes.s6),
                      const UserLastSeen()
                    ]).marginSymmetric(vertical: Insets.i2)
              ],
            ));
      }
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(Sizes.s85);

  PopupMenuItem _buildPopupMenuItem(
      String title, String iconData, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        children: [
          SvgPicture.asset(iconData),
          const HSpace(Sizes.s5),
          Text(title),
        ],
      ),
    );
  }
}
