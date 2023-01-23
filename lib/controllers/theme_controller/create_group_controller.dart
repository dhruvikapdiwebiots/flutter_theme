import 'dart:developer';
import 'dart:io';

import 'package:flutter_theme/config.dart';

class CreateGroupController extends GetxController {
  List<Contact>? contacts;
  List selectedContact = [];
  dynamic selectedData;
  List newContact = [];
  List contactList = [];
  final formKey = GlobalKey<FormState>();
  File? image;
  XFile? imageFile;
  bool isLoading = false, isGroup = true;
dynamic user;
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
    contacts = await permissionHandelCtrl.getContact();
     user = appCtrl.storage.read(session.user) ?? "";
    log("contacts : ${contacts!.length}");
    update();
    if(user != "") {
      getFirebaseContact(contacts!);
    }
  }

  //get firebase register contact list
  getFirebaseContact(List<Contact> contacts) async {
contactList = [];

    contacts.asMap().entries.forEach((contact) {
      if (contact.value.phones.isNotEmpty) {
        if (user["phone"] !=
            phoneNumberExtension(contact.value.phones[0].number.toString())) {
          FirebaseFirestore.instance
              .collection("users")
              .where("phone",
                  isEqualTo: phoneNumberExtension(
                      contact.value.phones[0].number.toString()))
              .get()
              .then((value) {
            if (value.docs.isNotEmpty) {
              if(value.docs[0].data()["isActive"] == true) {
                if(!contactList.contains(value.docs[0].data())) {
                  contactList.add(value.docs[0].data());
                }
              }
            }
            update();
            Get.forceAppUpdate();
          });
          update();
        }
      }
      update();
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
      final now = DateTime.now();
      String broadcastId = now.microsecondsSinceEpoch.toString();

      await checkChatAvailable();
      log("newContact : $newContact");
      await Future.delayed(Durations.s3);
      await FirebaseFirestore.instance
          .collection('broadcast')
          .doc(broadcastId)
          .set({
        "users": newContact,
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
        'receiver': newContact,
        'content': "You created this broadcast",
        "broadcastId": broadcastId,
        'type': MessageType.messageType.name,
        'messageType': "sender",
        "status": "",
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      await FirebaseFirestore.instance.collection('users').doc(user["id"]).collection("chats").add({
        'receiver': null,
        'broadcastId': broadcastId,
        'receiverId': newContact,
        'senderId': user["id"],
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        "lastMessage": "You created this broadcast",
        "isBroadcast": true,
        "isGroup": false,
        "isBlock": false,
        "updateStamp": DateTime.now().millisecondsSinceEpoch.toString()
      }).then((value) {
        selectedContact = [];
        newContact = [];
        update();
      });

      isLoading = false;
      update();
      Get.back();
      FirebaseFirestore.instance.collection('users').doc(user["id"]).collection("chats")
          .where("broadcastId", isEqualTo: broadcastId)
          .get()
          .then((value) {
        var data = {"broadcastId": broadcastId, "data": value.docs[0].data()};
        Get.toNamed(routeName.broadcastChat, arguments: data);
      });
    }
  }

  //check chat available with contacts
  Future<List> checkChatAvailable() async {
    final user = appCtrl.storage.read(session.user);
    selectedContact.asMap().entries.forEach((e)async{
      log("e.value : ${e.value["chatId"]}");
      await FirebaseFirestore.instance.collection("users").doc(user["id"]).collection("chats").where("isOneToOne",isEqualTo: true).get().then((value){
        log("value.docs.isNotEmpty : ${value.docs}");
        if(value.docs.isNotEmpty) {
          value.docs
              .asMap()
              .entries
              .forEach((element) {
            log("element.value : ${element.value.data()}");
            log("exist : ${element.value.data()["senderId"] == user["id"] &&
                element.value.data()["receiverId"] ==
                    e.value["id"] ||
                element.value.data()["senderId"] ==
                    e.value["id"] &&
                    element.value.data()["receiverId"] == user["id"]}");
            if (element.value.data()["senderId"] == user["id"] &&
                element.value.data()["receiverId"] ==
                    e.value["id"] ||
                element.value.data()["senderId"] ==
                    e.value["id"] &&
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
          });
        }else{
          e.value["chatId"] = null;
          if (!newContact.contains(e.value)) {
            newContact.add(e.value);
          }
        }
        update();
      });

    });


    return newContact;
  }

  selectUserTap(value){
    var data = {
      "id": value["id"],
      "name": value["name"],
      "phone": value["phone"],
      "image": value["image"]
    };
    bool exists = selectedContact.any(
            (file) => file["phone"] == data["phone"]);
    log("exists : $exists");
    if (exists) {
      selectedContact.removeWhere((element) => element["phone"] == data["phone"],);
    } else {
      selectedContact.add(data);
    }

    update();
  }


  @override
  void onReady() {
// TODO: implement onReady
    isGroup = Get.arguments ?? false;
    update();
    super.onReady();

  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    refreshContacts();
  }
}
