
import '../../../../config.dart';

class CallContactList extends StatelessWidget {
  const CallContactList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallListController>(builder: (callCtrl) {

      if (callCtrl.contactList.isEmpty) {
        callCtrl.getAllRegister();

      }

      return AgoraToken(
        scaffold: PickupLayout(
          scaffold: GetBuilder<AppController>(builder: (appCtrl) {
            return Scaffold(
                backgroundColor: appCtrl.appTheme.whiteColor,
                appBar: AppBar(
                    centerTitle: false,
                    automaticallyImplyLeading: false,
                    leading: Icon(Icons.arrow_back,
                            color: appCtrl.appTheme.whiteColor)
                        .inkWell(onTap: () => Get.back()),
                    backgroundColor: appCtrl.appTheme.primary,
                    title: Text(fonts.selectContacts.tr,
                        style: AppCss.poppinsMedium18
                            .textColor(appCtrl.appTheme.whiteColor))),
                body: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      if (callCtrl.contactList.isNotEmpty)
                        Column(children: [
                          ...callCtrl.contactList.asMap().entries.map((e) {
                            return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection(collectionName.users)
                                    .doc(e.value.id)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  String image = "", desc = "";
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.exists) {
                                      image =
                                          snapshot.data!.data()!["image"] ?? "";
                                      desc = snapshot.data!
                                              .data()!["statusDesc"] ??
                                          "";
                                    }
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CommonImage(
                                                    image: image,
                                                    name: e.value.name),
                                                const HSpace(Sizes.s10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e.value.name ?? "",
                                                      style: AppCss
                                                          .poppinsMedium14
                                                          .textColor(appCtrl
                                                              .appTheme
                                                              .blackColor),
                                                    ),
                                                    const VSpace(Sizes.s5),
                                                    Text(
                                                      desc,
                                                      style: AppCss
                                                          .poppinsMedium12
                                                          .textColor(appCtrl
                                                              .appTheme
                                                              .txtColor),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  svgAssets.callFilled,
                                                  colorFilter: ColorFilter.mode(
                                                      appCtrl.appTheme.primary,
                                                      BlendMode.srcIn),
                                                ).inkWell(onTap: () {
                                                  callCtrl.callFromList(false,
                                                      snapshot.data!.data());
                                                }),
                                                const HSpace(Sizes.s12),
                                                SvgPicture.asset(
                                                        svgAssets
                                                            .videoCallFilled,
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                                appCtrl.appTheme
                                                                    .primary,
                                                                BlendMode
                                                                    .srcIn))
                                                    .inkWell(onTap: () {
                                                  callCtrl.callFromList(true,
                                                      snapshot.data!.data());
                                                })
                                              ],
                                            )
                                          ],
                                        ).marginSymmetric(vertical: Insets.i10),
                                        Divider(
                                          color: appCtrl
                                              .appTheme.lightDividerColor
                                              .withOpacity(.2),
                                        )
                                      ],
                                    ).marginSymmetric(horizontal: Insets.i20);
                                  } else {
                                    return Container();
                                  }
                                });
                          }).toList()
                        ])
                    ]).marginSymmetric(vertical: Insets.i10)));
          }),
        ),
      );
    });
  }
}
