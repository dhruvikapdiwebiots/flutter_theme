import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/theme_pages/group_chat/layouts/create_group.dart';

class GroupChatController extends GetxController {
  List<Contact>? contacts;
  List selectedContact = [];
  List contactList = [];
  final formKey = GlobalKey<FormState>();
  File? image;
  XFile? imageFile;
  TextEditingController txtGroupName = TextEditingController();

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts = (await ContactsService.getContacts(
        withThumbnails: false, iOSLocalizedLabels: false));

    contacts = contacts;
    update();

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        contact.avatar = avatar;
        update();
      });
    }
    getFirebaseContact();
  }

  getFirebaseContact() async {
    final msgList = await FirebaseFirestore.instance.collection("users").get();

    for (final user in msgList.docs) {
      for (final contact in contacts!) {
        String phone = contact.phones![0].value.toString();
        if (phone.length > 10) {
          if (phone.contains(" ")) {
            phone = phone.replaceAll(" ", "");
          }
          if (phone.contains("-")) {
            phone = phone.replaceAll("-", "");
          }
          if (phone.contains("+")) {
            phone = phone.replaceAll("+91", "");
          }
        }
        if (phone == user.data()["phone"]) {
          final storeUser = appCtrl.storage.read("user");
          if (user.data()["id"] != storeUser["id"]) {
            contactList.add(user.data());
          }
        }
      }
    }
    update();
  }

// GET IMAGE FROM GALLERY
  Future getImage(source) async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source))!;
    if (imageFile != null) {
      update();
      uploadFile();
    }
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    var file = File(imageFile!.path);
    image = File(imageFile!.path);
  }

  //image picker option
  imagePickerOption(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return ImagePickerLayout(cameraTap: () {
            getImage(ImageSource.camera);
            Get.back();
          }, galleryTap: () {
            getImage(ImageSource.gallery);
            Get.back();
          });
        });
  }

  void updateContact() async {
    Contact ninja = contacts!
        .firstWhere((contact) => contact.familyName!.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    refreshContacts();
  }

  addGroupBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: Get.context!,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return const CreateGroup();
        });
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    refreshContacts();
  }
}
