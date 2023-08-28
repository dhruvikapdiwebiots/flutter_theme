import 'dart:developer';

import '../../../../config.dart';

class ReceiverMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy;
  final dynamic data;

  const ReceiverMessageCard(
      {Key? key, this.currentUserId, this.blockBy, this.document, this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (msgCtrl) {
      return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Row(children: [
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(collectionName.users)
                      .doc(document!["receiverId"])
                      .snapshots(),
                  builder: (context, snapshot) {
                    return CommonImage(
                        image: snapshot.hasData
                            ? snapshot.data!.exists
                                ? (snapshot.data!)["image"]
                                : ""
                            : "",
                        name: document!["name"]);
                  }),
              const HSpace(Sizes.s12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(document!["name"],
                    style: AppCss.poppinsblack14
                        .textColor(appCtrl.appTheme.blackColor)),
                const VSpace(Sizes.s5),
                SubTitleLayout(
                    document: document,
                    data: data,
                    name: document!["name"],
                    blockBy: blockBy)
              ])
            ]),
            TrailingLayout(
                    data: data,
                    document: document,
                    currentUserId: currentUserId)
                .width(Sizes.s55)
          ])
          .width(MediaQuery.of(context).size.width)
          .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i12)
          .commonDecoration()
          .marginSymmetric(horizontal: Insets.i10)
          .inkWell(onTap: () async {
        await FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(document!["receiverId"])
            .get()
            .then((value)async {
          if (value.exists) {
            UserContactModel userContact = UserContactModel(
                username: value.data()!["name"],
                uid: document!["receiverId"],
                phoneNumber: value.data()!["phone"],
                image: value.data()!["image"],
                isRegister: true);
            await FirebaseFirestore.instance.collection(collectionName.users).doc(appCtrl.user["id"]).collection(collectionName.messages).doc(document!["chatId"]).collection(collectionName.chat).get().then((value) {
              log("value.docs : ${userContact.uid}");
              if(value.docs.isNotEmpty){

                var data = {"chatId": document!["chatId"], "data": userContact};
                Get.toNamed(routeName.chat, arguments: data);
              }else{
                var data = {"chatId": document!["chatId"], "data": userContact};
                Get.toNamed(routeName.chat, arguments: data);
              }
            });
          }
        });
      });
    });
  }
}
