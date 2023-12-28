import 'dart:developer';

import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:provider/provider.dart';

import '../../../config.dart';

class GroupChat extends StatelessWidget {
  final groupChatCtrl = Get.isRegistered<CreateGroupController>()
      ? Get.find<CreateGroupController>()
      : Get.put(CreateGroupController());

  GroupChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateGroupController>(builder: (_) {

      log("groupChatCtrl.isAddUser : ${groupChatCtrl.isAddUser}");
      return WillPopScope(
        onWillPop: () async {
          groupChatCtrl.selectedContact = [];
          groupChatCtrl.update();

          return true;
        },
        child: GetBuilder<AppController>(builder: (appCtrl) {
          return  Consumer<FetchContactController>(
              builder: (context, registerAvailableContact, child) {

                return Scaffold(
                    backgroundColor: appCtrl.appTheme.whiteColor,
                    appBar: AppBar(
                        centerTitle: false,
                        automaticallyImplyLeading: false,

                        leading: Icon(Icons.arrow_back,
                            color: appCtrl.appTheme.whiteColor)
                            .inkWell(onTap: () => Get.back()),
                        backgroundColor: appCtrl.appTheme.primary,
                        title: Text(
                            groupChatCtrl.isAddUser
                                ? fonts.addContact.tr
                                : groupChatCtrl.isGroup
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
                        child: Icon(Icons.arrow_right_alt,
                            color: appCtrl.appTheme.whiteColor))
                        : Container(),
                    body: Stack(children: [
                      SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (groupChatCtrl.selectedContact.isNotEmpty)
                                   SelectedContactList(selectedContact: groupChatCtrl.selectedContact,onTap: (p0) {
                                     groupChatCtrl.selectedContact.remove(p0);
              groupChatCtrl.update();
                                   },),
                                if (registerAvailableContact.registerContactUser.isNotEmpty)
                                  Column(children: [
                                    ...registerAvailableContact.registerContactUser
                                        .asMap()
                                        .entries
                                        .map((e) {
                                      return AllRegisteredContact(
                                          onTap: () =>
                                              groupChatCtrl.selectUserTap(e.value),
                                          isExist: groupChatCtrl.selectedContact.any(
                                                  (file) =>
                                              file["phone"] == e.value.phone),
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
                    ]));
              }
          );
        }),
      );
    });
  }
}
