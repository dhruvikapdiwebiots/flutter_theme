import '../../../config.dart';

class ContactList extends StatelessWidget {
  final PhotoUrl? message;

  const ContactList({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
      return GetBuilder<ContactListController>(builder: (contactCtrl) {
        return AgoraToken(
            scaffold: PickupLayout(
                scaffold: WillPopScope(
                    onWillPop: () async {
                      return false;
                    },
                    child: Stack(children: [
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
                                Icon(Icons.refresh,
                                        color: appCtrl.appTheme.blackColor)
                                    .paddingAll(Insets.i10)
                                    .decorated(
                                        color: appCtrl.appTheme.white,
                                        boxShadow: [
                                          const BoxShadow(
                                              offset: Offset(0, 2),
                                              blurRadius: 5,
                                              spreadRadius: 1,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.08))
                                        ],
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r10))
                                    .marginSymmetric(vertical: Insets.i5)
                                    .paddingSymmetric(
                                        vertical: Insets.i14,
                                        horizontal: Insets.i15)
                                    .inkWell(onTap: () async {
                                  contactCtrl.isLoading = true;
                                  contactCtrl.update();
                                  var dashboardCtrl =
                                      Get.find<DashboardController>();
                                  dashboardCtrl.checkContactList();
                                  await Future.delayed(Durations.s2);
                                  contactCtrl.isLoading = false;
                                  contactCtrl.update();
                                })
                              ],
                              leading: const BackIcon()),
                          body: contactCtrl.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Stack(children: [
                                  SingleChildScrollView(
                                      child: Column(children: [
                                    CommonTextBox(
                                            labelText: fonts.mobileNumber.tr,
                                            controller:
                                                dashboardCtrl.searchText,
                                            textInputAction:
                                                TextInputAction.done,
                                            keyboardType: TextInputType.name,
                                            onChanged: (val) =>
                                                contactCtrl.onSearch(val),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appCtrl
                                                        .appTheme.primary),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.r8)),
                                            suffixIcon: Icon(Icons.search,
                                                    color: appCtrl
                                                        .appTheme.blackColor)
                                                .inkWell(onTap: () {}))
                                        .marginAll(Insets.i15),
                                    Text(fonts.registerUser.tr)
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
                                          ])
                                  ]))
                                ]))
                    ]))));
      });
    });
  }
}
