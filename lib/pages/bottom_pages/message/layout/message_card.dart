import 'dart:developer';

import '../../../../config.dart';

class MessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy;
final dynamic data;
  const MessageCard({Key? key, this.document, this.currentUserId, this.blockBy,this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            ImageLayout(id: document!["senderId"],height: Sizes.s45,width: Sizes.s45,),
            const HSpace(Sizes.s12),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document!["name"],
                      style: AppCss.poppinsblack14
                          .textColor(appCtrl.appTheme.blackColor)),
                  const VSpace(Sizes.s6),
                     data!["receiverMessage"] != null
                              ? data!["receiverMessage"]
                                      .contains("gif")
                                  ? const Icon(Icons.gif_box)
                                  : MessageCardSubTitle(
                         data: data,
                                      blockBy: blockBy,
                                      name: document!["name"],
                                      document: document,
                                      currentUserId: currentUserId)
                              : Container()
                ])
          ]),
           Expanded(
                      child: TrailingLayout(
                        data: data,
                          currentUserId: currentUserId, document: document))
        ]) .width(MediaQuery.of(context).size.width)
        .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i12)
        .commonDecoration()
        .marginSymmetric(horizontal: Insets.i10)  .inkWell(onTap: () async{
          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(document!["senderId"]).get().then((value)async {
                if(value.exists){
                  UserContactModel userContact = UserContactModel(
                      username: document!["name"],
                      uid: document!["senderId"],
                      phoneNumber: value.data()!["phone"],
                      image: value.data()!["image"],
                      isRegister: true);

                  var data = {"chatId": document!["chatId"], "data": userContact};
                  log("IMAGE : ${userContact.image}");
                  Get.toNamed(routeName.chat, arguments: data);
                  final chatCtrl = Get.isRegistered<ChatController>()
                      ? Get.find<ChatController>()
                      : Get.put(ChatController());
                  chatCtrl.onReady();
                }
          });

    });
  }
}
