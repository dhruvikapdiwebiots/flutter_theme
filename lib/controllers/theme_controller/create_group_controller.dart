import 'dart:io';

import 'package:flutter_theme/config.dart';


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
      isLoading =true;
      update();
      final now = DateTime.now();
      String broadcastId = now.microsecondsSinceEpoch.toString();

      final user = appCtrl.storage.read("user");
      await Future.delayed(Durations.s3);
      await FirebaseFirestore.instance
          .collection('broadcast')
          .doc(broadcastId)
          .set({
        "users": selectedContact,
        "broadcastId": broadcastId,
        "createdBy": user,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      FirebaseFirestore.instance
          .collection('broadcastMessage')
          .doc(broadcastId)
          .collection("chat")
          .add({
        'sender': user["id"],
        'senderName': user["name"],
        'receiver': selectedContact,
        'content': "You created this broadcast",
        "broadcastId": broadcastId,
        'type': MessageType.messageType.name,
        'messageType': "sender",
        "status": "",
        'timestamp': DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
      });

      await FirebaseFirestore.instance
          .collection("broadcast")
          .doc(broadcastId)
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
          'broadcastId': broadcastId,
          'receiverId': selectedContact,
          'senderPhone': user["phone"],
          'timestamp': DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          "lastMessage": "",
          "isBroadcast": true,
          "isGroup": false,
          "isBlock": false,
          "updateStamp": DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()
        });
      }).then((value) {
        selectedContact = [];
        update();
      });
      isLoading =false;
      update();
      Get.back();
      FirebaseFirestore.instance
          .collection('contacts').where("broadcastId",isEqualTo: broadcastId).get().then((value) {
            print("value.docs[0].data() : ${value.docs[0].data()}");
        var data ={
          "broadcastId": broadcastId,
          "data":value.docs[0].data()
        };
        Get.toNamed(routeName.broadcastChat, arguments: data);
      });

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
