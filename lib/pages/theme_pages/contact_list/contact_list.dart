import '../../../config.dart';

class ContactList extends StatelessWidget {
  final contactCtrl = Get.put(ContactListController());

  ContactList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContactListController>(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            fonts.contact.tr,
          ),
        ),
        body: SafeArea(
          child: contactCtrl.contactList != null
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      CommonTextBox(
                              labelText: fonts.mobileNumber.tr,
                              controller: contactCtrl.searchText,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.name,
                              onChanged: (val) {
                                if (val.isEmpty) {
                                  contactCtrl.searchContactList = [];
                                } else {
                                  contactCtrl.searchContact(val);
                                }
                                contactCtrl.update();
                              },
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appCtrl.appTheme.primary)),
                              maxLength: 10,
                              suffixIcon: Icon(Icons.call,
                                  color: appCtrl.appTheme.blackColor))
                          .marginAll(Insets.i15),
                      SingleChildScrollView(
                        child: contactCtrl.searchContactList!.isNotEmpty &&
                                contactCtrl.searchText.text.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    contactCtrl.searchContactList!.length,
                                itemBuilder: (BuildContext context, int index) {
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
                                            contactCtrl.searchContactList![id] =
                                                c;
                                            Get.back(result: c);
                                          },
                                          leading: (c.avatar != null &&
                                                  c.avatar!.isNotEmpty)
                                              ? CircleAvatar(
                                                  backgroundImage:
                                                      MemoryImage(c.avatar!))
                                              : CircleAvatar(
                                                  child: Text(c.initials())),
                                          title: Text(c.displayName ?? ""),
                                          subtitle:
                                              Text(c.phones![0].value ?? ""),
                                        )
                                      : Container();
                                },
                              )
                            : contactCtrl.contactList!.isEmpty
                                ? Container()
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        contactCtrl.contactList?.length ?? 0,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Contact c = contactCtrl.contactList!
                                          .elementAt(index);
                                      return c.phones!.isNotEmpty
                                          ? ListTile(
                                              onTap: () {
                                                var id = contactCtrl
                                                    .contactList!
                                                    .indexWhere((c) =>
                                                        c.identifier ==
                                                        c.identifier);
                                                contactCtrl.contactList![id] =
                                                    c;
                                                Get.back(result: c);
                                              },
                                              leading: (c.avatar != null &&
                                                      c.avatar!.isNotEmpty)
                                                  ? CircleAvatar(
                                                      backgroundImage:
                                                          MemoryImage(
                                                              c.avatar!))
                                                  : CircleAvatar(
                                                      child:
                                                          Text(c.initials())),
                                              title: Text(c.displayName ?? ""),
                                              subtitle: Text(
                                                  c.phones![0].value ?? ""),
                                            )
                                          : Container();
                                    },
                                  ),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      );
    });
  }
}
