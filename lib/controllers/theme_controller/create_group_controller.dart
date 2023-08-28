import 'dart:developer';
import 'dart:io';

import 'package:flutter_theme/config.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';

class CreateGroupController extends GetxController {
  List<Contact>? contacts;
  List selectedContact = [];
  dynamic selectedData;
  List newContact = [];
  List contactList = [];
  final formKey = GlobalKey<FormState>();
  File? image;
  XFile? imageFile;
  bool isLoading = false, isGroup = true, isAddUser = false;
  dynamic user;
  int counter = 0;
  int count = 0;
  int dddd = 0;

  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);
  String imageUrl = "";
  TextEditingController txtGroupName = TextEditingController();
  final pickerCtrl = Get.isRegistered<PickerController>()
      ? Get.find<PickerController>()
      : Get.put(PickerController());
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());

  //refresh and get contact
  Future<void> refreshContacts() async {
    isLoading = true;
    update();
    user = appCtrl.storage.read(session.user) ?? "";

    update();
    getFirebaseContact();
  }

  //get firebase register contact list
  getFirebaseContact() async {
    contactList = [];
    update();
    user = appCtrl.storage.read(session.user) ?? "";

    update();
    Get.forceAppUpdate();
    log("AVAILABLE : ${appCtrl.contactList.length}");
    appCtrl.contactList.asMap().entries.forEach((contact) {
      if (user["phone"] !=
          phoneNumberExtension(contact.value.phones[0].number.toString())) {
        counter++;

        update();
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("phone",
                isEqualTo: phoneNumberExtension(
                    contact.value.phones[0].number.toString()))
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            if (value.docs[0].data()["isActive"] == true) {
              bool isContains = contactList
                  .where((element) =>
                      element["phone"] == value.docs[0].data()["phone"])
                  .isNotEmpty;
              if (!isContains) {
                contactList.add(value.docs[0].data());
              }
            }
          }

          update();
        });
        log("INIT1  : ${contactList.length}");
        update();
      }
    });

    isLoading = false;
    update();
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    imageFile = pickerCtrl.imageFile;
    update();
    log("crate_group_con  $imageFile");
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

// Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  //add group bottom sheet
  addGroupBottomSheet() async {
    final user = appCtrl.storage.read(session.user);
    if (isGroup) {
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
    } else {
      isLoading = true;
      update();
      String broadcastId = DateTime.now().millisecondsSinceEpoch.toString();
      final dateTime = DateTime.now().millisecondsSinceEpoch.toString();
      final key = encrypt.Key.fromUtf8('my 32 length key................');
      final iv = encrypt.IV.fromLength(16);

      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encrypted =
          encrypter.encrypt("You created this broadcast", iv: iv).base64;
      final fontEncrypted =
          encrypter.encrypt(fonts.noteEncrypt.tr, iv: iv).base64;

      await checkChatAvailable();
      await Future.delayed(Durations.s6);
      log("newContact SS: ${newContact.length}");
      isLoading = false;
      update();
          await FirebaseFirestore.instance
          .collection(collectionName.broadcast)
          .doc(broadcastId)
          .set({
        "users": newContact,
        "broadcastId": broadcastId,
        "createdBy": user,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      log("CREATE BROADCAST");

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.broadcastMessage)
          .doc(broadcastId)
          .collection(collectionName.chat)
          .doc(dateTime)
          .set({
        'sender': user["id"],
        'senderName': user["name"],
        'receiver': newContact,
        'content': fontEncrypted,
        "broadcastId": broadcastId,
        'type': MessageType.note.name,
        'messageType': "sender",
        "status": "",
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.broadcastMessage)
          .doc(broadcastId)
          .collection(collectionName.chat)
          .doc(dateTime)
          .set(
        {
          'sender': user["id"],
          'senderName': user["name"],
          'receiver': newContact,
          'content': fontEncrypted,
          "broadcastId": broadcastId,
          'type': MessageType.note.name,
          'messageType': "sender",
          "status": "",
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .collection(collectionName.chats)
          .add({
        'receiver': null,
        'broadcastId': broadcastId,
        'receiverId': newContact,
        'senderId': user["id"],
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        "lastMessage": encrypted,
        "isBroadcast": true,
        "isGroup": false,
        "isBlock": false,
        "name": "Broadcast",
        "updateStamp": DateTime.now().millisecondsSinceEpoch.toString()
      }).then((value) {
        selectedContact = [];

        update();
      });

      isLoading = false;
      update();
      Get.back();
      FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .collection(collectionName.chats)
          .where("broadcastId", isEqualTo: broadcastId)
          .get()
          .then((value) async {
            log("ALLL : ${value.docs[0].data()}");
        var data = {
          "broadcastId": broadcastId,
          "data": value.docs[0].data(),
          "newContact": newContact,
        };

        log("newContact :$data");


        Get.toNamed(routeName.broadcastChat, arguments: data);

      });
    }
  }

  //check chat available with contacts
  Future<List> checkChatAvailable() async {
    newContact = [];
    count = 0;
    dddd = 0;

    final user = appCtrl.storage.read(session.user);
    selectedContact.asMap().entries.forEach((e) async {
      count++;
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .collection(collectionName.chats)
          .where("isOneToOne", isEqualTo: true)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          dddd++;
          value.docs.asMap().entries.forEach((element) {
            if (element.value.data()["senderId"] == user["id"] &&
                    element.value.data()["receiverId"] == e.value["id"] ||
                element.value.data()["senderId"] == e.value["id"] &&
                    element.value.data()["receiverId"] == user["id"]) {
              e.value["chatId"] = element.value.data()["chatId"];
              update();
              if (!newContact.contains(e.value)) {
                newContact.add(e.value);
              }
            } else {
              e.value["chatId"] = null;
              if (!newContact.contains(e.value)) {
                newContact.add(e.value);
              }
            }

            update();
          });
        } else {
          e.value["chatId"] = null;
          if (!newContact.contains(e.value)) {
            newContact.add(e.value);
          }
        }

        update();
      });
    });
    log("DATA CHAT : ${newContact.length}");
    return newContact;
  }

  //select user function
  selectUserTap(RegisterContactDetail value) {
    var data = {
      "id": value.id,
      "name": value.name,
      "phone": value.phone,
      "image": value.image
    };
    bool exists = selectedContact.any((file) => file["phone"] == data["phone"]);
    log("exists : $exists");
    if (exists) {
      selectedContact.removeWhere(
        (element) => element["phone"] == data["phone"],
      );
    } else {
      if (selectedContact.length <
          appCtrl.usageControlsVal!.groupMembersLimit!) {
        selectedContact.add(data);
      } else {
        snackBarMessengers(
            message:
                "You can added only ${isGroup ? appCtrl.usageControlsVal!.groupMembersLimit! : appCtrl.usageControlsVal!.broadCastMembersLimit!} Members in the group");
      }
    }

    update();
  }

  @override
  void onReady() {
// TODO: implement onReady
    isGroup = Get.arguments ?? false;
    //refreshContacts();
    update();
    super.onReady();
  }
}
