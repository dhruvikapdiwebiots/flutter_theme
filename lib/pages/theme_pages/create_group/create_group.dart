
import '../../../config.dart';

class GroupChat extends StatelessWidget {
  final groupChatCtrl = Get.put(CreateGroupController());

  GroupChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateGroupController>(builder: (_) {
      return WillPopScope(
        onWillPop: () async {
          groupChatCtrl.selectedContact = [];
          groupChatCtrl.update();
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              // leadingWidth: 40,
              title: Text( groupChatCtrl.isGroup ? fonts.selectContacts.tr: "Broadcast",
                  style: AppCss.poppinsMedium18
                      .textColor(appCtrl.appTheme.whiteColor)),
            ),
            floatingActionButton: groupChatCtrl.selectedContact.isNotEmpty
                ? FloatingActionButton(
              onPressed: () => groupChatCtrl.addGroupBottomSheet(),
              backgroundColor: appCtrl.appTheme.primary,
              child: const Icon(Icons.arrow_right_alt),
            )
                : Container(),
            body: SafeArea(
                child: Stack(
                  children: [
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
                                        onTap: () {
                                          if (groupChatCtrl.selectedContact
                                              .contains(e.value)) {
                                            groupChatCtrl.selectedContact.remove(e.value);
                                          } else {
                                            groupChatCtrl.selectedContact.add(e.value);
                                          }
                                          groupChatCtrl.update();
                                        },
                                        isExist: groupChatCtrl.selectedContact
                                            .contains(e.value),
                                        data: e.value);
                                  }).toList()
                                ])
                            ])),
                    if(groupChatCtrl.isLoading)
                      LoginLoader(isLoading: groupChatCtrl.isLoading,)
                  ],
                ))),
      );
    });
  }
}
