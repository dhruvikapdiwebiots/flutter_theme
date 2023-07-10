import '../../../../config.dart';

class BroadCastAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? name, nameList;

  const BroadCastAppBar({Key? key, this.name, this.nameList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return AppBar(
          backgroundColor: appCtrl.appTheme.whiteColor,
          shadowColor: const Color.fromRGBO(255, 255, 255, 0.08),
          bottomOpacity: 0.0,
          elevation: 18,
          shape: SmoothRectangleBorder(
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 20, cornerSmoothing: 1)),
          automaticallyImplyLeading: false,
          leadingWidth: Sizes.s70,
          toolbarHeight: Sizes.s90,
          titleSpacing: 0,
          leading: SvgPicture.asset(
                  appCtrl.isRTL ? svgAssets.arrowForward : svgAssets.arrowBack,
                  color: appCtrl.appTheme.blackColor,
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
              .marginOnly(
                  right: Insets.i10,
                  top: Insets.i22,
                  bottom: Insets.i22,
                  left: Insets.i20)
              .inkWell(onTap: () => Get.back()),
          title: Row(
            children: [
              Container(
                height: Sizes.s40,
                width: Sizes.s40,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                    color: const Color(0xff3282B8),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 12, cornerSmoothing: 1),
                    ),
                    image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: NetworkImage('${chatCtrl.pName}'))),
                child: Text(
                  name!.length > 2
                      ? name!.replaceAll(" ", "").substring(0, 2).toUpperCase()
                      : name![0],
                  style:
                      AppCss.poppinsblack16.textColor(appCtrl.appTheme.white),
                ),
              ),
              const HSpace(Sizes.s10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  name ?? "",
                  textAlign: TextAlign.center,
                  style: AppCss.poppinsBold16
                      .textColor(appCtrl.appTheme.blackColor),
                ),
                const VSpace(Sizes.s10),
                Text(
                  nameList!,
                  style: AppCss.poppinsMedium14
                      .textColor(appCtrl.appTheme.blackColor),
                )
              ]),
            ],
          ).inkWell(onTap: ()=> Get.toNamed(routeName.broadcastProfile)));
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(Sizes.s85);
}
