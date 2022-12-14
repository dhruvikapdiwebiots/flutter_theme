import 'package:contacts_service/contacts_service.dart';

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
          child: contactCtrl.contacts != null
              ? ListView.builder(
                  itemCount: contactCtrl.contacts?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    Contact c = contactCtrl.contacts!.elementAt(index);
                    return ListTile(
                      onTap: () {
                        var id = contactCtrl.contacts!
                            .indexWhere((c) => c.identifier == c.identifier);
                        contactCtrl.contacts![id] = c;
                        Get.back(result: c);
                      },
                      leading: (c.avatar != null && c.avatar!.isNotEmpty)
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(c.avatar!))
                          : CircleAvatar(child: Text(c.initials())),
                      title: Text(c.displayName ?? ""),
                      subtitle: Text(c.phones![0].value ?? ""),
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      );
    });
  }
}