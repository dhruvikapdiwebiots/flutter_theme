import 'dart:developer';
import 'dart:io';

import 'package:flutter_theme/config.dart';

class AddParticipantsController extends GetxController {
  List<Contact>? contacts;
  List selectedContact = [];
  List existsUser = [];
  dynamic selectedData;
  List newContact = [];
  List contactList = [];
  final formKey = GlobalKey<FormState>();
  File? image;
  XFile? imageFile;
  bool isLoading = false, isGroup = true;
  dynamic user;
  int counter = 0;
  String imageUrl = "", groupId = "";
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
      if (contact.value.phones.isNotEmpty) {
        if (user["phone"] !=
            phoneNumberExtension(contact.value.phones[0].number.toString())) {
          counter++;
          contactList = [];

          update();
          Get.forceAppUpdate();
          FirebaseFirestore.instance
              .collection(collectionName.users)
              .where("phone",
                  isEqualTo: phoneNumberExtension(
                      contact.value.phones[0].number.toString()))
              .get()
              .then((value) {
            if (value.docs.isNotEmpty) {
              if (value.docs[0].data()["isActive"] == true) {
                if (!contactList.contains(value.docs[0].data())) {
                  contactList.add(value.docs[0].data());
                } else {
                  contactList.remove(value.docs[0].data());
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

// Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  //add group bottom sheet
  addGroupBottomSheet() async {
    final user = appCtrl.storage.read(session.user);
    log("groupId : $groupId");
    if (isGroup) {
      await FirebaseFirestore.instance
          .collection(collectionName.groups)
          .doc(groupId)
          .get()
          .then((value) async {
        if (value.exists) {
          selectedContact.asMap().entries.forEach((data) {
            existsUser.add(data.value);
          });
          log("AFTER ADD : $existsUser");
          update();
          await FirebaseFirestore.instance
              .collection(collectionName.groups)
              .doc(groupId)
              .update({"users": existsUser}).then((value) {
            Get.back();
            final chatCtrl = Get.isRegistered<GroupChatMessageController>()
                ? Get.find<GroupChatMessageController>()
                : Get.put(GroupChatMessageController());
            chatCtrl.getPeerStatus();
            chatCtrl.pData["receiverId"] = chatCtrl.userList;
            for (var i = 0; i < chatCtrl.pData.length; i++) {
              if (chatCtrl.nameList != "") {
                chatCtrl.nameList = "${chatCtrl.nameList}, ${chatCtrl.pData[i]["name"]}";
              } else {
                chatCtrl.nameList = chatCtrl.pData[i]["name"];
              }
            }
            chatCtrl.update();
            selectedContact = [];
            update();
          });
        }
      });
    } else {
      await FirebaseFirestore.instance
          .collection(collectionName.broadcast)
          .doc(groupId)
          .get()
          .then((value) async{
        if (value.exists) {
          selectedContact.asMap().entries.forEach((data) {
            existsUser.add(data.value);
          });
          log("AFTER ADD : $existsUser");
          update();
          await  FirebaseFirestore.instance
              .collection(collectionName.broadcast)
              .doc(groupId).update({"users": existsUser}).then((value) {
            Get.back();
            final chatCtrl = Get.isRegistered<BroadcastChatController>()
                ? Get.find<BroadcastChatController>()
                : Get.put(BroadcastChatController());
            chatCtrl.getBroadcastData();
Get.back();
          });
        }
      });
    }
  }

  //check chat available with contacts
  Future<List> checkChatAvailable() async {
    final user = appCtrl.storage.read(session.user);
    selectedContact.asMap().entries.forEach((e) async {
      log("e.value : ${e.value["chatId"]}");
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .collection(collectionName.chats)
          .where("isOneToOne", isEqualTo: true)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
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

    return newContact;
  }

  //select user function
  selectUserTap(value) {
    var data = {
      "id": value["id"],
      "name": value["name"],
      "phone": value["phone"],
      "image": value["image"]
    };
    bool exists = selectedContact.any((file) => file["phone"] == data["phone"]);
    log("exists : $exists");
    if (exists) {
      selectedContact.removeWhere(
        (element) => element["phone"] == data["phone"],
      );
    } else {
      /* if(selectedContact.length < appCtrl.usageControlsVal!.groupMembersLimit!) {

      }else{
        snackBarMessengers(message: "You can added only ${isGroup ? appCtrl.usageControlsVal!.groupMembersLimit! :appCtrl.usageControlsVal!.broadCastMembersLimit!} Members in the group");
      }*/
      selectedContact.add(data);
    }

    update();
  }

  @override
  void onReady() {
// TODO: implement onReady
    var data = Get.arguments ?? "";
    existsUser = data["exitsUser"];
    groupId = data["groupId"];
    isGroup = data["isGroup"] ?? true;
    //refreshContacts();
    log("existsUser : $existsUser");
    update();
    super.onReady();
  }
}
