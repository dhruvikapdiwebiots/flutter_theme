import 'dart:io';

import '../../../config.dart';

class ContactList extends StatelessWidget {
  final contactCtrl = Get.put(ContactListController());

  ContactList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContactListController>(builder: (_) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
              title: Text(fonts.contact.tr),
              automaticallyImplyLeading: false,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: appCtrl.appTheme.whiteColor),
                  onPressed: () {
                    Get.back();
                    contactCtrl.searchText.text = "";
                    contactCtrl.contactList = [];
                    contactCtrl.searchContactList = [];
                  })),
          body: SafeArea(
              child: Stack(
            children: [
              contactCtrl.contactList.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          CommonTextBox(
                              labelText: fonts.mobileNumber.tr,
                              controller: contactCtrl.searchText,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.name,
                              onChanged: (val) {
                                contactCtrl.searchContact(val, false);
                                contactCtrl.update();
                              },
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appCtrl.appTheme.primary)),
                              maxLength: 10,
                              suffixIcon: Icon(Icons.search,
                                      color: appCtrl.appTheme.blackColor)
                                  .inkWell(
                                      onTap: () => contactCtrl.searchContact(
                                          contactCtrl.searchText.text,
                                          true))).marginAll(Insets.i15),
                          SingleChildScrollView(
                            child: contactCtrl.searchContactList!.isNotEmpty &&
                                    contactCtrl.searchText.text.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        contactCtrl.searchContactList!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Contact c = contactCtrl.searchContactList!
                                          .elementAt(index);
                                      return c.phones!.isNotEmpty
                                          ? ListTile(
                                              onTap: () {
                                                var id = contactCtrl
                                                    .searchContactList!
                                                    .indexWhere((c) =>
                                                        c.identifier ==
                                                        c.identifier);
                                                contactCtrl
                                                    .searchContactList![id] = c;
                                                Get.back(result: c);
                                              },
                                              leading: (c.avatar != null &&
                                                      c.avatar!.isNotEmpty)
                                                  ? CircleAvatar(
                                                      backgroundImage:
                                                          MemoryImage(
                                                              c.avatar!))
                                                  : CircleAvatar(
                                                      child: Text(c.displayName!
                                                          .substring(0, 2)
                                                          .toUpperCase())),
                                              title: Text(c.displayName ?? ""),
                                              subtitle: Text(
                                                  c.phones![0].value ?? ""),
                                              trailing: StreamBuilder(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .where("phone",
                                                          isEqualTo:
                                                              phoneNumberExtension(
                                                                  c.phones![0]
                                                                      .value))
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.data != null) {
                                                      if (!snapshot.data!.docs
                                                          .isNotEmpty) {
                                                        return Text(
                                                                fonts.invite.tr)
                                                            .inkWell(onTap:
                                                                () async {
                                                          if (Platform
                                                              .isAndroid) {
                                                            final uri = Uri(
                                                              scheme: "sms",
                                                              path:
                                                                  phoneNumberExtension(c
                                                                      .phones![
                                                                          0]
                                                                      .value),
                                                              queryParameters: <
                                                                  String,
                                                                  String>{
                                                                'body': Uri
                                                                    .encodeComponent(
                                                                        'Download the ChatBox App'),
                                                              },
                                                            );
                                                            await launchUrl(
                                                                uri);
                                                          }
                                                        });
                                                      } else {
                                                        return Container();
                                                      }
                                                    } else {
                                                      return Container();
                                                    }
                                                  }).width(Sizes.s40),
                                            )
                                          : Container();
                                    },
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: contactCtrl.contactList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Contact c = contactCtrl.contactList
                                          .elementAt(index);
                                      return c.phones!.isNotEmpty
                                          ? ListTile(
                                              onTap: () {
                                                var id = contactCtrl.contactList
                                                    .indexWhere((c) =>
                                                        c.identifier ==
                                                        c.identifier);
                                                contactCtrl.contactList[id] = c;
                                                Get.back(result: c);
                                              },
                                              leading: (c.avatar != null &&
                                                      c.avatar!.isNotEmpty)
                                                  ? CircleAvatar(
                                                      backgroundImage:
                                                          MemoryImage(
                                                              c.avatar!))
                                                  : CircleAvatar(
                                                      child: Text(c.displayName!
                                                                  .length >
                                                              2
                                                          ? c.displayName!
                                                              .replaceAll(
                                                                  " ", "")
                                                              .substring(0, 2)
                                                              .toUpperCase()
                                                          : c.displayName![0])),
                                              title: Text(c.displayName ?? ""),
                                              subtitle: Text(
                                                  c.phones![0].value ?? ""),
                                              trailing: StreamBuilder(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .where("phone",
                                                          isEqualTo:
                                                              phoneNumberExtension(
                                                                  c.phones![0]
                                                                      .value))
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.data != null) {
                                                      if (!snapshot.data!.docs
                                                          .isNotEmpty) {
                                                        return Text(
                                                                fonts.invite.tr)
                                                            .inkWell(onTap:
                                                                () async {
                                                          if (Platform
                                                              .isAndroid) {
                                                            final uri = Uri(
                                                              scheme: "sms",
                                                              path:
                                                                  phoneNumberExtension(c
                                                                      .phones![
                                                                          0]
                                                                      .value),
                                                              queryParameters: <
                                                                  String,
                                                                  String>{
                                                                'body': Uri
                                                                    .encodeComponent(
                                                                        'Download the ChatBox App'),
                                                              },
                                                            );
                                                            await launchUrl(
                                                                uri);
                                                          }
                                                        });
                                                      } else {
                                                        return Container();
                                                      }
                                                    } else {
                                                      return Container();
                                                    }
                                                  }).width(Sizes.s40),
                                            )
                                          : Container();
                                    },
                                  ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              if (contactCtrl.isLoading)
                LoginLoader(
                  isLoading: contactCtrl.isLoading,
                )
            ],
          )),
        ),
      );
    });
  }
}
