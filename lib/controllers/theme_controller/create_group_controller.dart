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

    contacts = await permissionHandelCtrl.getContact();

    update();
    getFirebaseContact(contacts!);
  }

  //get firebase register contact list
  getFirebaseContact(List<Contact> contacts) async {
    isLoading = true;
    update();
    var user = appCtrl.storage.read("user");
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
              contactList.add(value.docs[0].data());
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
    final user = appCtrl.storage.read("user");
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
      await Future.delayed(Durations.s3);
      await Future.delayed(Durations.s3);
     /* await FirebaseFirestore.instance
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

      await FirebaseFirestore.instance
          .collection("broadcast")
          .doc(broadcastId)
          .get()
          .then((value) async {
        await FirebaseFirestore.instance.collection('contacts').add({
          'sender': {
            "id": user['id'],
            "name": user['name'],
            "phone": user["phone"]
          },
          'receiver': null,
          'broadcastId': broadcastId,
          'receiverId': newContact,
          'senderPhone': user["phone"],
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": "",
          "isBroadcast": true,
          "isGroup": false,
          "isBlock": false,
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString()
        });
      }).then((value) {
        selectedContact = [];
        newContact = [];
        update();
      });
      isLoading = false;
      update();
      Get.back();
      FirebaseFirestore.instance
          .collection('contacts')
          .where("broadcastId", isEqualTo: broadcastId)
          .get()
          .then((value) {
        var data = {"broadcastId": broadcastId, "data": value.docs[0].data()};
        Get.toNamed(routeName.broadcastChat, arguments: data);
      });*/
    }
  }

  Future<List> checkChatAvailable() async {
    final user = appCtrl.storage.read("user");
    selectedContact.asMap().entries.forEach((e)async{
      await FirebaseFirestore.instance.collection("users").doc(user["id"]).collection("chats").get().then((value){
       value.docs.asMap().entries.forEach((element) {
         if (value.docs[element.key].data()["senderPhone"] == user["phone"] &&
             value.docs[element.key].data()["receiverPhone"] ==
                 selectedContact[e.key]["phone"] ||
             value.docs[element.key].data()["senderPhone"] ==
                 selectedContact[e.key]["phone"] &&
                 value.docs[element.key].data()["receiverPhone"] == user["phone"]) {
           selectedContact[e.key]["chatId"] = value.docs[element.key].data()["chatId"];
           update();
           if (!newContact.contains(selectedContact[e.key])) {
             newContact.add(selectedContact[e.key]);
           }
         } else {
           selectedContact[e.key]["chatId"] = null;
           if (!newContact.contains(selectedContact[e.key])) {
             newContact.add(selectedContact[e.key]);
           }
         }
       });
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
    isGroup = Get.arguments;
    update();
    super.onReady();
    refreshContacts();
  }
}
