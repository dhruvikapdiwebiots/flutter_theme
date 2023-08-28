import 'dart:developer';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:provider/provider.dart';

import '../../../config.dart';

class AllContactList extends StatefulWidget {
  AllContactList({Key? key}) : super(key: key);

  @override
  State<AllContactList> createState() => _AllContactListState();
}

class _AllContactListState extends State<AllContactList> {
  final contactCtrl = Get.put(AllContactListController());
  final scrollController = ScrollController();
  int inviteContactsCount = 30;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  String? sharedSecret;
  String? privateKey;

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent / 2 &&
        !scrollController.position.outOfRange) {
      setStateIfMounted(() {
        inviteContactsCount = inviteContactsCount + 250;
      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<FetchContactController>(
        builder: (context, registerAvailableContact, _child) {
      return Scaffold(
          backgroundColor: appCtrl.appTheme.bgColor,
          appBar: AppBar(
              title: Text(fonts.contact.tr,
                  style: AppCss.poppinsblack16
                      .textColor(appCtrl.appTheme.whiteColor)),
              automaticallyImplyLeading: false,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: appCtrl.appTheme.whiteColor),
                  onPressed: () {
                    Get.back();
                    contactCtrl.searchText.text = "";
                  })),
          body: Stack(
            children: [
              ListView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 15, top: 0),
                physics: const BouncingScrollPhysics(),
                children: [
                  CommonTextBox(
                          labelText: fonts.mobileNumber.tr,
                          controller: contactCtrl.searchText,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                          onChanged: (val) => contactCtrl.fetchPage(0, val),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: appCtrl.appTheme.primary)),
                          maxLength: 10,
                          suffixIcon:
                              Icon(Icons.search, color: appCtrl.appTheme.blackColor)
                                  .inkWell(onTap: () {}))
                      .marginAll(Insets.i15),
                  contactCtrl.searchText.text.isEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(0),
                          itemCount:
                              registerAvailableContact.contactList!.length,
                          itemBuilder: (context, idx) {
                            MapEntry user = registerAvailableContact
                                .contactList!.entries
                                .elementAt(idx);
                            String phone = user.key;
                            return Stack(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                      radius: Sizes.s20,
                                      child: Text(
                                        registerAvailableContact.getInitials(user.value),
                                      )),
                                  title: Text(
                                    user.value,
                                  ),
                                  onTap: () async {
                                    isLoading =true;setState(() {

                                    });
                                    FlutterContacts.getContacts(
                                        withPhoto: true, withProperties: true, withThumbnail: true)
                                        .then((Iterable<Contact> contacts) async {

                                          List<Contact> contactList = contacts.where((c) => c.phones.isNotEmpty).toList();
                                          int index =contactList.indexWhere((element) => phoneNumberExtension(element
                                              .phones[0].normalizedNumber)
                                              .toString() ==
                                              phone);
                                          isLoading =false;setState(() {

                                          });
                                          Get.back(result: contactList[index]);


                                    });

                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 22.0, vertical: 0.0),
                                ),
                              ],
                            );
                          },
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(0),
                          itemCount: contactCtrl.searchList!.length,
                          itemBuilder: (context, idx) {
                            MapEntry user =
                                contactCtrl.searchList!.entries.elementAt(idx);
                            String phone = user.key;
                            log("phone : $phone");
                            return Stack(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                      radius: Sizes.s20,
                                      child: Text(
                                        registerAvailableContact.getInitials(user.value),
                                      )),
                                  title: Text(
                                    user.value,
                                  ),
                                  onTap: () async {
                                    var contacts =
                                        (await FlutterContacts.getContacts(
                                            withPhoto: true,
                                            withProperties: true,
                                            withThumbnail: true));

                                    for (Contact p in contacts
                                        .where((c) => c.phones.isNotEmpty)) {
                                      if (phoneNumberExtension(
                                                  p.phones[0].normalizedNumber)
                                              .toString() ==
                                          user.key) {
                                        Get.back(result: p);
                                      }
                                    }
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 22.0, vertical: 0.0),
                                ),
                              ],
                            );
                          },
                        )
                ],
              ),
              if(isLoading)
                CommonLoader(
                  isLoading: isLoading,
                ),
            ],
          ));
    });
  }
}
