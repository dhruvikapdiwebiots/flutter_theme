import '../../../../config.dart';

class GroupChatMessageAppBar extends StatelessWidget with PreferredSizeWidget {
  final String? name, image;
  final VoidCallback? callTap,moreTap,videoTap;

  const GroupChatMessageAppBar({Key? key, this.name, this.callTap, this.image,this.videoTap,this.moreTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  AppBar(
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
                  spreadRadius: 1,
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
        ],
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            CommonImage(image: image, name: name,height: Sizes.s40,width: Sizes.s40),
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
                  const GroupUserLastSeen()
                ]).marginSymmetric(vertical: Insets.i2)
          ],
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(Sizes.s85);
}
