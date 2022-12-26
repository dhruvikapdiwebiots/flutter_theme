import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_theme/config.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateGroupController extends GetxController {
  List<Contact>? contacts;
  List selectedContact = [];
  List contactList = [];
  final formKey = GlobalKey<FormState>();
  File? image;
  XFile? imageFile;
  bool isLoading = false, isGroup = true;

  String imageUrl = "";
  TextEditingController txtGroupName = TextEditingController();
  final pickerCtrl = Get.isRegistered<PickerController>()
      ? Get.find<PickerController>()
      : Get.put(PickerController());
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());

  Future<void> refreshContacts() async {
    contacts = await permissionHandelCtrl.getContact();
    for (final contact in contacts!) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        contact.avatar = avatar;
        update();
      });
    }
    update();
    getFirebaseContact(contacts);
  }

  getFirebaseContact(contacts) async {
    final msgList = await FirebaseFirestore.instance.collection("users").get();

    for (final user in msgList.docs) {
      for (final contact in contacts!) {
        if (contact.phones!.isNotEmpty) {
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
    UploadTask uploadTask = reference.putFile(file);
    await uploadTask.then((res) {
      res.ref.getDownloadURL().then((downloadUrl) {
        imageUrl = downloadUrl;

        update();
      }, onError: (err) {
        update();
        Fluttertoast.showToast(msg: 'Image is Not Valid');
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

  addGroupBottomSheet() async {
    if (isGroup) {
      showModalBottomSheet(
          isScrollControlled: true,
          context: Get.context!,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          builder: (BuildContext context) {
// return your layout
            return isLoading
                ? LoginLoader(isLoading: isLoading)
                : const CreateGroup();
          });
    } else {
      final now = DateTime.now();
      String id = now.microsecondsSinceEpoch.toString();

      final user = appCtrl.storage.read("user");
      await Future.delayed(Durations.s3);
      await FirebaseFirestore.instance
          .collection('broadcast')
          .doc(id)
          .set({
        "users": selectedContact,
        "broadcastId": id,
        "createdBy": user,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      FirebaseFirestore.instance
          .collection('broadcastMessage')
          .doc(id)
          .collection("chat")
          .add({
        'sender': user["id"],
        'senderName': user["name"],
        'receiver': selectedContact,
        'content': "You created this broadcast",
        "broadcastId": id,
        'type': MessageType.messageType.name,
        'messageType': "sender",
        "status": "",
        'timestamp': DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
      });

      await FirebaseFirestore.instance
          .collection("broadcast")
          .doc(id)
          .get()
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('contacts')
            .add({
          'sender': {
            "id": user['id'],
            "name": user['name'],
            "phone": user["phone"]
          },
          'receiver': null,
          'broadcastId': id,
          'receiverId': selectedContact,
          'senderPhone': user["phone"],
          'timestamp': DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          "lastMessage": "",
          "isBroadcast": true,
          "updateStamp": DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()
        });
      });
      var data ={
        "id": id,
        "selectedContact":selectedContact
      };
      Get.toNamed(routeName.broadcastChat, arguments: data);
    }
  }

  @override
  void onReady() {
// TODO: implement onReady
    isGroup = Get.arguments;
    update();
    super.onReady();
    refreshContacts();
  }
}
