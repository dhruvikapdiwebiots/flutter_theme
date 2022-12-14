import 'dart:developer';

import '../../../../config.dart';


class StatusFirebaseApi {
  //add status
  addStatus(imageUrl,statusType,{statusText,statusBgColor}) async {
    var user = appCtrl.storage.read(session.user);
    List<PhotoUrl> statusImageUrls = [];

    var statusesSnapshot = await FirebaseFirestore.instance
        .collection('status')
        .where("uid", isEqualTo: user["id"])
        .get();

    if (statusesSnapshot.docs.isNotEmpty) {
      Status status = Status.fromJson(statusesSnapshot.docs[0].data());
      statusImageUrls = status.photoUrl!;
      var data = {
        "image":statusType == StatusType.text.name ? "": imageUrl!,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "isExpired": false,
        "statusType":statusType,
        "statusText": statusText,
        "statusBgColor": statusBgColor,

      };

      statusImageUrls.add(PhotoUrl.fromJson(data));
      await FirebaseFirestore.instance
          .collection('status')
          .doc(statusesSnapshot.docs[0].id)
          .update(
              {'photoUrl': statusImageUrls.map((e) => e.toJson()).toList()});
      return;
    } else {
      var data = {
        "image":statusType == StatusType.text.name ? "": imageUrl!,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "isExpired": false,
        "statusType":statusType,
        "statusText": statusText,
        "statusBgColor": statusBgColor,
      };
      statusImageUrls = [PhotoUrl.fromJson(data)];
    }

    Status status = Status(
        username: user["name"],
        phoneNumber: user["phone"],
        photoUrl: statusImageUrls,
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        profilePic: user["image"],
        uid: user["id"],
        isSeenByOwn: false);

    await FirebaseFirestore.instance.collection('status').add(status.toJson());
  }

  //get status list
  Future<List<Status>> getStatusUserList(List<Contact> contacts) async {
    var user = appCtrl.storage.read(session.user);
    var statusesSnapshot =
        await FirebaseFirestore.instance.collection('status').get();
    List<Status> statusData = [];
    for (int i = 0; i < statusesSnapshot.docs.length; i++) {
      for (int j = 0; j < contacts.length; j++) {
        if (contacts[j].phones.isNotEmpty) {
          String phone =
              phoneNumberExtension(contacts[j].phones[0].number.toString());
          if (phone == statusesSnapshot.docs[i].data()["phoneNumber"]) {
            if (statusesSnapshot.docs[i].data()["uid"] != user["id"]) {
              Status tempStatus =
                  Status.fromJson(statusesSnapshot.docs[i].data());
              if(!statusData.contains(tempStatus)) {
                statusData.add(tempStatus);
              }
            }
          }
        }
      }
    }
    log("statusData : $statusData");

    return statusData;
  }
}
