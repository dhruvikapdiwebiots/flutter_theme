import 'dart:io';

import 'package:flutter_contacts/flutter_contacts.dart' as contact;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
          backgroundColor: appCtrl.appTheme.whiteColor,
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
              Column(
                children: [
                  CommonTextBox(
                      labelText: fonts.mobileNumber.tr,
                      controller: contactCtrl.searchText,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.name,
                      onChanged: (val) {
                        contactCtrl.fetchPage(0, val);
                        contactCtrl.update();
                      },
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: appCtrl.appTheme.primary)),
                      maxLength: 10,
                      suffixIcon: Icon(Icons.search,
                          color: appCtrl.appTheme.blackColor)
                          .inkWell(
                          onTap: () => contactCtrl.fetchPage(0,
                              contactCtrl.searchText.text))).marginAll(Insets.i15),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          Future.sync(() => contactCtrl.pagingController.refresh()),
                      child: PagedListView<int, contact.Contact>(
                        pagingController: contactCtrl.pagingController,
                        builderDelegate: PagedChildBuilderDelegate<contact.Contact>(
                            itemBuilder: (context, item, index) => ListTile(
                                  onTap: () {
                                    var id = contactCtrl.contactList
                                        .indexWhere((c) => c.id == c.id);
                                    contactCtrl.contactList[id] = item;
                                    Get.back(result: item);
                                  },
                                  leading: (item.photo != null &&
                                          item.photo!.isNotEmpty)
                                      ? CircleAvatar(
                                          backgroundImage: MemoryImage(item.photo!))
                                      : CircleAvatar(
                                          child: Text(item.displayName.length > 2
                                              ? item.displayName
                                                  .replaceAll(" ", "")
                                                  .substring(0, 2)
                                                  .toUpperCase()
                                              : item.displayName[0])),
                                  title: Text(item.displayName ?? ""),
                                  subtitle: Text(item.phones[0].number ?? ""),
                                  trailing: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .where("phone",
                                              isEqualTo: phoneNumberExtension(
                                                  item.phones[0].number))
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.data != null) {
                                          if (!snapshot.data!.docs.isNotEmpty) {
                                            return Text(fonts.invite.tr).inkWell(
                                                onTap: () async {
                                              if (Platform.isAndroid) {
                                                final uri = Uri(
                                                  scheme: "sms",
                                                  path: phoneNumberExtension(
                                                      item.phones[0].number),
                                                  queryParameters: <String, String>{
                                                    'body': Uri.encodeComponent(
                                                        'Download the ChatBox App'),
                                                  },
                                                );
                                                await launchUrl(uri);
                                              }
                                            });
                                          } else {
                                            return Container();
                                          }
                                        } else {
                                          return Container();
                                        }
                                      }).width(Sizes.s40),
                                )),
                      ),
                    ),
                  ),
                ],
              ),

            ],
          )),
        ),
      );
    });
  }
}
