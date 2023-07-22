import 'dart:developer';
import '../../../config.dart';

class ContactList extends StatelessWidget {
  final PhotoUrl? message;

  const ContactList({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
      return GetBuilder<ContactListController>(builder: (contactCtrl) {
        return WillPopScope(
          onWillPop: () async {
            dashboardCtrl.searchText.text = "";
            dashboardCtrl.update();
            return true;
          },
          child: AgoraToken(
              scaffold: PickupLayout(
                  scaffold: Stack(children: [

            Scaffold(
                backgroundColor: appCtrl.appTheme.bgColor,
                appBar: AppBar(
                    automaticallyImplyLeading: false,
                    leadingWidth: Sizes.s80,
                    toolbarHeight: Sizes.s80,
                    elevation: 0,
                    backgroundColor: appCtrl.appTheme.bgColor,
                    title: Text(fonts.contact.tr,
                        style: AppCss.poppinsMedium16
                            .textColor(appCtrl.appTheme.primary)),
                    centerTitle: true,
                    actions: [
                      Icon(Icons.refresh, color: appCtrl.appTheme.blackColor)
                          .paddingAll(Insets.i10)
                          .decorated(
                              color: appCtrl.appTheme.white,
                              boxShadow: [
                                const BoxShadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                    color: Color.fromRGBO(0, 0, 0, 0.08))
                              ],
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10))
                          .marginSymmetric(vertical: Insets.i5)
                          .paddingSymmetric(
                              vertical: Insets.i14, horizontal: Insets.i15)
                          .inkWell(onTap: () async {
                        contactCtrl.refreshData();
                        contactCtrl.update();
                      })
                    ],
                    leading: const BackIcon()),
                body: Stack(children: [
                  if (contactCtrl.isLoading)
                    CommonLoader(
                      isLoading: contactCtrl.isLoading,
                    ),
                  SingleChildScrollView(
                      child: Column(children: [
                    CommonTextBox(
                        labelText: fonts.mobileNumber.tr,
                        controller: dashboardCtrl.searchText,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: appCtrl.appTheme.primary),
                            borderRadius: BorderRadius.circular(AppRadius.r8)),
                        suffixIcon: Icon(
                                dashboardCtrl.searchText.text.isNotEmpty
                                    ? Icons.cancel
                                    : Icons.search,
                                color: appCtrl.appTheme.blackColor)
                            .inkWell(onTap: () {
                          if (dashboardCtrl.searchText.text.isNotEmpty) {
                            contactCtrl.onSearch(dashboardCtrl.searchText.text);
                          } else {
                            dashboardCtrl.searchText.text = "";
                            dashboardCtrl.update();
                          }
                        })).marginAll(Insets.i15),
                    dashboardCtrl.searchText.text.isNotEmpty
                        ? Column(
                            children: [
                              Text(fonts.registerUser.tr)
                                  .paddingSymmetric(
                                      horizontal: Insets.i15,
                                      vertical: Insets.i10)
                                  .width(MediaQuery.of(context).size.width),
                              contactCtrl.registerList.isNotEmpty
                                  ? Column(children: [
                                      ...contactCtrl.registerList
                                          .asMap()
                                          .entries
                                          .map((item) => RegisterUser(
                                              message: message,
                                              userContactModel: item.value))
                                          .toList()
                                    ])
                                  : Container(),
                              Text(fonts.inviteUser.tr)
                                  .paddingSymmetric(
                                      horizontal: Insets.i15,
                                      vertical: Insets.i10)
                                  .width(MediaQuery.of(context).size.width),
                              contactCtrl.unRegisterList.isNotEmpty
                                  ? Column(children: [
                                      ...contactCtrl.unRegisterList
                                          .asMap()
                                          .entries
                                          .map((item) => UnRegisterUser(
                                              item: item.value,
                                              message: message))
                                          .toList()
                                    ])
                                  : Container()
                            ],
                          )
                        : Column(
                            children: [
                              Column(
                                children: [
                                  Text(fonts.registerUser.tr)
                                      .paddingSymmetric(
                                          horizontal: Insets.i15,
                                          vertical: Insets.i10)
                                      .width(MediaQuery.of(context).size.width),
                                  contactCtrl.allRegisterList.isNotEmpty
                                      ? Column(children: [
                                          ...contactCtrl.allRegisterList
                                              .asMap()
                                              .entries
                                              .map((item) => RegisterUser(
                                                  message: message,
                                                  userContactModel: item.value))
                                              .toList()
                                        ])
                                      : Container(),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(fonts.inviteUser.tr)
                                      .paddingSymmetric(
                                          horizontal: Insets.i15,
                                          vertical: Insets.i10)
                                      .width(MediaQuery.of(context).size.width),
                                  contactCtrl.allUnRegisterList.isNotEmpty
                                      ? Column(children: [
                                          ...contactCtrl.allUnRegisterList
                                              .asMap()
                                              .entries
                                              .map((item) => UnRegisterUser(
                                                  item: item.value,
                                                  message: message))
                                              .toList()
                                        ])
                                      : Container()
                                ],
                              )
                            ],
                          )

                    /*    Text(fonts.registerUser.tr)
                                      .paddingSymmetric(
                                          horizontal: Insets.i15,
                                          vertical: Insets.i10)
                                      .width(
                                          MediaQuery.of(context).size.width),
                                  contactCtrl.registerList!.isNotEmpty
                                      ? Column(children: [
                                          ...contactCtrl.registerList!
                                              .asMap()
                                              .entries
                                              .map((item) => RegisterUser(
                                                  message: message,
                                                  userContactModel:
                                                      item.value))
                                              .toList()
                                        ])
                                      : Column(children: [
                                          ...contactCtrl
                                              .registerContact!.userTitle!
                                              .asMap()
                                              .entries
                                              .map((item) => RegisterUser(
                                                  message: message,
                                                  userContactModel:
                                                      item.value))
                                              .toList()
                                        ]),
                                  Text(fonts.unRegisterUser.tr)
                                      .paddingSymmetric(
                                          horizontal: Insets.i15,
                                          vertical: Insets.i10)
                                      .width(
                                          MediaQuery.of(context).size.width),
                                  contactCtrl.unRegisterList!.isNotEmpty
                                      ? Column(children: [
                                          ...contactCtrl.unRegisterList!
                                              .asMap()
                                              .entries
                                              .map((item) => UnRegisterUser(
                                                  item: item.value,
                                                  message: message))
                                              .toList()
                                        ])
                                      : Column(children: [
                                          ...contactCtrl
                                              .unRegisterContact!.userTitle!
                                              .asMap()
                                              .entries
                                              .map((item) => UnRegisterUser(
                                                  item: item.value,
                                                  message: message))
                                              .toList()
                                        ])*/
                  ]))
                ]))
          ]))),
        );
      });
    });
  }
}
