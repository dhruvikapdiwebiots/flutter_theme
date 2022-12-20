import '../../../../config.dart';

class StatusFirebaseApi {
  //add status
  addStatus(imageUrl) async {
    var user = appCtrl.storage.read("user");
    List<PhotoUrl> statusImageUrls = [];
    var statusesSnapshot = await FirebaseFirestore.instance
        .collection('status')
        .where(
          'uid',
          isEqualTo: user["id"],
        )
        .get();

    if (statusesSnapshot.docs.isNotEmpty) {
      Status status = Status.fromJson(statusesSnapshot.docs[0].data());
      statusImageUrls = status.photoUrl!;
      var data = {
        "image": imageUrl!,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "isExpired": false
      };
      statusImageUrls.add(PhotoUrl.fromJson(data));
      await FirebaseFirestore.instance
          .collection('status')
          .doc(statusesSnapshot.docs[0].id)
          .update({'photoUrl': statusImageUrls.map((e) => e.toJson()).toList()});
      return;
    } else {
      var data = {
        "image": imageUrl!,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "isExpired": false
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
  getStatusUserList(contacts)async{
    var statusesSnapshot = await FirebaseFirestore.instance
        .collection('status')
        .orderBy('createdAt', descending: true)
        .get();
    List<Status> statusData = [];
    for (int i = 0; i < statusesSnapshot.docs.length; i++) {
      for (int j = 0; j < contacts.length; j++) {
        if (contacts[j].phones!.isNotEmpty) {
          String phone =
          phoneNumberExtension(contacts[j].phones![0].value.toString());
          if (phone == statusesSnapshot.docs[i]["phoneNumber"]) {
            final storeUser = appCtrl.storage.read("user");
            if (statusesSnapshot.docs[i]["uid"] != storeUser["id"]) {
              Status tempStatus =
              Status.fromJson(statusesSnapshot.docs[i].data());
              statusData.add(tempStatus);
            }
          }
        }
      }
    }

    return statusData;
  }
}
