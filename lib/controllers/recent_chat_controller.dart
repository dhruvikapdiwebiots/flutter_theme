import 'dart:developer';

import 'package:flutter_theme/models/data_model.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

import '../config.dart';

class RecentChatController with ChangeNotifier {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> userData = [];
  List<Widget> messageWidgetList = [];

  DataModel? getModel(user) {
    appCtrl.cachedModel ??= DataModel(user["phone"]);
    Future.delayed(Durations.s1).then((value) {
      userData = appCtrl.cachedModel!.userData;

      getMessageList();
    });
   //notifyListeners();
    return appCtrl.cachedModel;
  }

  getMessageList() async {
    LocalStorage storage = LocalStorage('messageModel');
    messageWidgetList = [];
    storage.ready.then((ready) {
      if (ready) {
        userData.asMap().entries.forEach((element) {
          var data = {
            "name": element.value["name"],
            "groupMessage": decryptMessage(element.value["lastMessage"])
                    .contains(".gif")
                ? "gif"
                : element.value["lastMessage"] == ""
                    ? ""
                    : (decryptMessage(element.value["lastMessage"])
                            .contains("media"))
                        ? "Media Share"
                        : (decryptMessage(element.value["lastMessage"])
                                    .contains(".pdf") ||
                                decryptMessage(element.value["lastMessage"])
                                    .contains(".doc") ||
                                decryptMessage(element.value["lastMessage"])
                                    .contains(".mp3") ||
                                decryptMessage(element.value["lastMessage"])
                                    .contains(".mp4") ||
                                decryptMessage(element.value["lastMessage"])
                                    .contains(".xlsx") ||
                                decryptMessage(element.value["lastMessage"])
                                    .contains(".ods"))
                            ? decryptMessage(element.value["lastMessage"])
                                .split("-BREAK-")[0]
                            : decryptMessage(element.value["lastMessage"]) == ""
                                ? appCtrl.user["id"] ==
                                        element.value["senderId"]
                                    ? "You Create this group ${element.value["group"]['name']}"
                                    : "${element.value["sender"]['name']} added you"
                                : decryptMessage(element.value["lastMessage"]),
            "receiverMessage":
                (decryptMessage(element.value["lastMessage"]).contains("media"))
                    ? "Media Share"
                    : element.value["isBlock"] == true &&
                            element.value["isBlock"] == "true"
                        ? element.value["blockBy"] != appCtrl.user["id"]
                            ? element.value["blockUserMessage"]
                            : decryptMessage(element.value["lastMessage"])
                                .contains("http")
                        : (decryptMessage(element.value["lastMessage"])
                                    .contains(".pdf") ||
                                decryptMessage(element.value["lastMessage"])
                                    .contains(".doc") ||
                                decryptMessage(element.value["lastMessage"])
                                    .contains(".mp3") ||
                                decryptMessage(element.value["lastMessage"])
                                    .contains(".mp4") ||
                                decryptMessage(element.value["lastMessage"])
                                    .contains(".xlsx") ||
                                decryptMessage(element.value["lastMessage"])
                                    .contains(".ods"))
                            ? decryptMessage(element.value["lastMessage"])
                                .split("-BREAK-")[0]
                            : decryptMessage(element.value["lastMessage"]),
            "senderMessage": element.value["lastMessage"] != null &&
                    element.value["lastMessage"] != ""
                ? ""
                : decryptMessage(element.value["lastMessage"]).contains(".gif")
                    ? "gif"
                    : (decryptMessage(element.value["lastMessage"])
                            .contains("media"))
                        ? "You Share Media"
                        : element.value["isBlock"] == true &&
                                element.value["isBlock"] == "true"
                            ? element.value["blockBy"] != appCtrl.user["id"]
                                ? element.value["blockUserMessage"]
                                : decryptMessage(element.value["lastMessage"])
                                    .contains("http")
                            : (decryptMessage(element.value["lastMessage"])
                                        .contains(".pdf") ||
                                    decryptMessage(element.value["lastMessage"])
                                        .contains(".doc") ||
                                    decryptMessage(element.value["lastMessage"])
                                        .contains(".mp3") ||
                                    decryptMessage(element.value["lastMessage"])
                                        .contains(".mp4") ||
                                    decryptMessage(element.value["lastMessage"])
                                        .contains(".xlsx") ||
                                    decryptMessage(element.value["lastMessage"])
                                        .contains(".ods"))
                                ? decryptMessage(element.value["lastMessage"])
                                    .split("-BREAK-")[0]
                                : decryptMessage(element.value["lastMessage"]),
            "time": DateFormat('HH:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(element.value['updateStamp']))),
          };
          if (element.value.data()["isGroup"] == false &&
              element.value.data()["isBroadcast"] == false) {
            if (element.value.data()["senderId"] == appCtrl.user["id"]) {
              messageWidgetList.add(ReceiverMessageCard(
                      data: data,
                      document: element.value,
                      currentUserId: appCtrl.user["id"],
                      blockBy: appCtrl.user['id'])
                  .marginOnly(bottom: Insets.i12));
            } else {
              messageWidgetList.add(MessageCard(
                      data: data,
                      blockBy: appCtrl.user["id"],
                      document: element.value,
                      currentUserId: appCtrl.user["id"])
                  .marginOnly(bottom: Insets.i12));
            }
          } else if (element.value.data()["isGroup"] == true) {
            messageWidgetList.add(GroupMessageCard(
              document: element.value,
              data: data,
              currentUserId: appCtrl.user["id"],
            ).marginOnly(bottom: Insets.i12));
          } else if (element.value.data()["isBroadcast"] == true) {
            element.value.data()["senderId"] == appCtrl.user["id"]
                ? messageWidgetList.add(BroadCastMessageCard(
                    document: element.value,
                    currentUserId: appCtrl.user["id"],
                  ).marginOnly(bottom: Insets.i12))
                : messageWidgetList.add(MessageCard(
                        data: data,
                        document: element.value,
                        currentUserId: appCtrl.user["id"],
                        blockBy: appCtrl.user["id"])
                    .marginOnly(bottom: Insets.i12));
          } else {
            messageWidgetList.add(Container());
          }
          notifyListeners();
        });
      }
      notifyListeners();

    });
  }
}