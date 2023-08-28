

import '../../../../config.dart';

class BroadCastDeleteAlert extends StatelessWidget {
  final DocumentSnapshot? documentReference;

  const BroadCastDeleteAlert({Key? key, this.documentReference}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return AlertDialog(
        backgroundColor: appCtrl.appTheme.whiteColor,
        title: Text(fonts.alert.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(fonts.areYouSureToDelete.tr),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(fonts.close.tr),
          ),
          TextButton(
            onPressed: () async {
               Get.back();

               int index =0;
               chatCtrl.selectedIndexId.asMap().entries.forEach((e) {
                 chatCtrl.localMessage.asMap().entries.forEach((element) {
                   index = element.value.message!.indexWhere((element) => element.docId == e.value );

                   if(index >0) {
                     chatCtrl.localMessage[element.key].message!.removeAt(index);
                   }
                 });
                 chatCtrl.update();

               });
               chatCtrl.selectedIndexId.asMap().entries.forEach((element) {
                 FirebaseFirestore.instance
                     .collection(collectionName.users)
                     .doc(appCtrl.user["id"])
                     .collection(collectionName.broadcastMessage)
                     .doc(chatCtrl.pId)
                     .collection(collectionName.chat)
                     .doc(element.value)
                     .delete();
               });

               await FirebaseFirestore.instance
                   .runTransaction((transaction) async {});
               chatCtrl.listScrollController.animateTo(0.0,
                   duration: const Duration(milliseconds: 300),
                   curve: Curves.easeOut);

               await FirebaseFirestore.instance
                   .collection(collectionName.users)
                   .doc(appCtrl.user["id"])
                   .collection(collectionName.broadcastMessage)
                   .doc(chatCtrl.pId)
                   .collection(collectionName.chat)
                   .orderBy("timestamp", descending: true)
                   .limit(1)
                   .get()
                   .then((value) {
                 if (value.docs.isEmpty) {
                   List receiver = value.docs[0].data()["receiver"];
                   receiver.asMap().entries.forEach((element) async {
                     FirebaseFirestore.instance
                         .collection(collectionName.users)
                         .doc(element.value["id"])
                         .collection(collectionName.chats)
                         .where("broadcastId", isEqualTo: chatCtrl.pId)
                         .get()
                         .then((value) {
                       FirebaseFirestore.instance
                           .collection(collectionName.users)
                           .doc(element.value["id"]).collection(collectionName.chats).doc(value.docs[0].id)
                           .delete();
                     });
                   });
                 } else {
                   List receiver = value.docs[0].data()["receiver"];
                   receiver.asMap().entries.forEach((element) async {
                     await  FirebaseFirestore.instance
                         .collection(collectionName.users)
                         .doc(element.value["id"])
                         .collection(collectionName.chats)
                         .where("broadcastId",isEqualTo: chatCtrl.pId  )
                         .get()
                         .then((contact) {
                       if (contact.docs.isNotEmpty) {
                         FirebaseFirestore.instance
                             .collection("users")
                             .doc(element.value["id"])
                             .collection("chats")
                             .doc(contact.docs[0].id)
                             .update({
                           "updateStamp":
                           DateTime.now().millisecondsSinceEpoch.toString(),
                           "lastMessage": value.docs[0].data()["content"],
                           "senderId": chatCtrl.userData["id"],
                           "sender": chatCtrl.userData
                         });
                       }
                     });
                   });
                 }
               });
               chatCtrl.selectedIndexId = [];
               chatCtrl.showPopUp =false;
               chatCtrl.enableReactionPopup =false;
               chatCtrl.update();


            },
            child: Text(fonts.yes.tr),
          ),
        ],
      );
    });
  }
}
