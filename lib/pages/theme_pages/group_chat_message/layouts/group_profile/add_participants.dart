import 'dart:developer';

import '../../../../../config.dart';

class AddParticipants extends StatelessWidget {
  final groupChatCtrl = Get.isRegistered<AddParticipantsController>()
      ? Get.find<AddParticipantsController>()
      : Get.put(AddParticipantsController());

  AddParticipants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddParticipantsController>(builder: (_) {
      var data = Get.arguments ?? "";
      log("data : $data");
      groupChatCtrl.existsUser = data["exitsUser"];
      groupChatCtrl.groupId = data["groupId"];
      groupChatCtrl.update();
      return AgoraToken(
        scaffold: PickupLayout(
          scaffold: WillPopScope(
            onWillPop: () async {
              groupChatCtrl.selectedContact = [];
              groupChatCtrl.update();
              Get.back();
              return true;
            },
            child: GetBuilder<AppController>(builder: (appCtrl) {
              return Scaffold(
                  backgroundColor: appCtrl.appTheme.whiteColor,
                  appBar: AppBar(
                      centerTitle: false,
                      automaticallyImplyLeading: false,
                      actions: [
                        Icon(
                          Icons.refresh,
                          color: appCtrl.appTheme.white,
                        ).marginSymmetric(horizontal: Insets.i15).inkWell(
                            onTap: () => groupChatCtrl.getFirebaseContact())
                      ],
                      leading: Icon(Icons.arrow_back,
                              color: appCtrl.appTheme.whiteColor)
                          .inkWell(onTap: () => Get.back()),
                      backgroundColor: appCtrl.appTheme.primary,
                      title: Text(fonts.addContact.tr,
                          style: AppCss.poppinsMedium18
                              .textColor(appCtrl.appTheme.whiteColor))),
                  floatingActionButton: groupChatCtrl.selectedContact.isNotEmpty
                      ? FloatingActionButton(
                          onPressed: () => groupChatCtrl.addGroupBottomSheet(),
                          backgroundColor: appCtrl.isTheme
                              ? appCtrl.appTheme.secondary
                              : appCtrl.appTheme.primary,
                          child: Icon(Icons.arrow_right_alt,
                              color: appCtrl.appTheme.whiteColor))
                      : Container(),
                  body: Stack(children: [
                    SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          if (groupChatCtrl.selectedContact.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: groupChatCtrl.selectedContact.asMap().entries.map((e) {
                                  return SelectedUsers(
                                    data: e.value,
                                    onTap: () {
                                      groupChatCtrl.selectedContact.remove(e.value);
                                      groupChatCtrl.update();
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          if (groupChatCtrl.contactList.isNotEmpty)
                            Column(children: [
                              ...groupChatCtrl.contactList
                                  .asMap()
                                  .entries
                                  .map((e) {
                                return ListTile(
                                  onTap: () {
                                    log("DDD");
                                    bool isAvailable = groupChatCtrl.existsUser.where((element) => element["phone"] == e.value["phone"]).isNotEmpty;
                                    if(!isAvailable) {
                                      groupChatCtrl.selectUserTap(e.value);
                                    }

                                  },
                                  trailing: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: appCtrl.appTheme.borderGray,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Icon(
                                        groupChatCtrl.existsUser
                                            .where((element) =>
                                        element["phone"] ==
                                            e.value["phone"])
                                            .isNotEmpty
                                            ? Icons.check
                                            : null,
                                        size: 19.0,
                                      )),
                                  leading: CommonImage(
                                      image: e.value["image"],
                                      name: e.value["name"]),
                                  title: Text(e.value["name"] ?? ""),
                                  subtitle: Text(groupChatCtrl.existsUser
                                          .where((element) =>
                                              element["phone"] ==
                                              e.value["phone"])
                                          .isNotEmpty
                                      ? "Already Exists"
                                      : e.value["statusDesc"]),
                                );
                              }).toList()
                            ])
                        ])),
                    if (groupChatCtrl.isLoading)
                      Container(
                        height: MediaQuery.of(context).size.height,
                        color: appCtrl.appTheme.grey.withOpacity(.2),
                        child: Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    appCtrl.appTheme.primary))),
                      )
                  ]));
            }),
          ),
        ),
      );
    });
  }
}
