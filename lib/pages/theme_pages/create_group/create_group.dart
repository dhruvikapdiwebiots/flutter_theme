

import '../../../config.dart';

class GroupChat extends StatelessWidget {
  final groupChatCtrl =  Get.isRegistered<CreateGroupController>() ? Get.find<CreateGroupController>() : Get.put(CreateGroupController());

  GroupChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateGroupController>(builder: (_) {
      groupChatCtrl.isGroup = Get.arguments ?? false;

      return  AgoraToken(
        scaffold: PickupLayout(
          scaffold: WillPopScope(
            onWillPop: () async {
              groupChatCtrl.selectedContact = [];
              groupChatCtrl.update();
              return true;
            },
            child: Scaffold(
                backgroundColor: appCtrl.appTheme.whiteColor,
                appBar: AppBar(
                    centerTitle: false,
                    automaticallyImplyLeading: false,
                    actions: [ Icon(
                      Icons.refresh,
                      color: appCtrl.appTheme.white,
                    ).marginSymmetric(horizontal: Insets.i15).inkWell(
                        onTap: () => groupChatCtrl.refreshContacts())],
                    leading: Icon(Icons.arrow_back,color: appCtrl.appTheme.whiteColor).inkWell(onTap: ()=> Get.back()),
                    backgroundColor: appCtrl.appTheme.primary,
                    title: Text(
                        groupChatCtrl.isGroup
                            ? fonts.selectContacts.tr
                            : fonts.broadCast.tr,
                        style: AppCss.poppinsMedium18
                            .textColor(appCtrl.appTheme.whiteColor))),
                floatingActionButton: groupChatCtrl.selectedContact.isNotEmpty
                    ? FloatingActionButton(
                        onPressed: () => groupChatCtrl.addGroupBottomSheet(),
                        backgroundColor: appCtrl.isTheme
                            ? appCtrl.appTheme.secondary
                            : appCtrl.appTheme.primary,
                        child:  Icon(Icons.arrow_right_alt,color: appCtrl.appTheme.whiteColor))
                    : Container(),
                body: Stack(children: [
                  SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        if (groupChatCtrl.selectedContact.isNotEmpty)
                          const SelectedContactList(),
                        if (groupChatCtrl.contactList.isNotEmpty)
                          Column(children: [
                            ...groupChatCtrl.contactList.asMap().entries.map((e) {
                              return AllRegisteredContact(
                                  onTap: () => groupChatCtrl.selectUserTap(e.value),
                                  isExist: groupChatCtrl.selectedContact.any(
                                      (file) => file["phone"] == e.value["phone"]),
                                  data: e.value);
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
                ])),
          ),
        ),
      );
    });
  }
}
