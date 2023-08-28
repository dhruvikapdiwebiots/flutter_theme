

import 'package:provider/provider.dart';

import '../../../../../config.dart';
import '../../../../../controllers/fetch_contact_controller.dart';

class AddParticipants extends StatelessWidget {
  final groupChatCtrl = Get.isRegistered<AddParticipantsController>()
      ? Get.find<AddParticipantsController>()
      : Get.put(AddParticipantsController());

  AddParticipants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddParticipantsController>(builder: (_) {

      return  WillPopScope(
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
                    child:Consumer<FetchContactController>(
                        builder: (context, registerAvailableContact, child) {

                          return Stack(children: [
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
                                              return e.value["phone"] != appCtrl.user["phone"]?   SelectedUsers(
                                                data: e.value,
                                                onTap: () {
                                                  groupChatCtrl.selectedContact.remove(e.value);
                                                  groupChatCtrl.update();
                                                },
                                              ):Container();
                                            }).toList(),
                                          ),
                                        ),
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
                          ]);
                        }
                    )),
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
      );
    });
  }
}
