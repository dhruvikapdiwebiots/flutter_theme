import '../../../../config.dart';

class MessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy;

  const MessageCard({Key? key, this.document, this.currentUserId, this.blockBy})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(document!["senderId"])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Row(children: [
                    ImageLayout(id: document!["senderId"]),
                    const HSpace(Sizes.s12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(snapshot.data!["name"],
                              style: AppCss.poppinsblack14
                                  .textColor(appCtrl.appTheme.blackColor)),
                          const VSpace(Sizes.s6),
                          document!["lastMessage"] != null
                              ? decryptMessage(document!["lastMessage"])
                                      .contains(".gif")
                                  ? const Icon(Icons.gif_box)
                                  : MessageCardSubTitle(
                                      blockBy: blockBy,
                                      name: snapshot.data!["name"],
                                      document: document,
                                      currentUserId: currentUserId)
                              : Container()
                        ])
                  ]),
                  Expanded(
                      child: TrailingLayout(
                          currentUserId: currentUserId, document: document))
                ])
                .width(MediaQuery.of(context).size.width)
                .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i12)
                .commonDecoration()
                .marginSymmetric(horizontal: Insets.i10)
                .inkWell(onTap: () {
              UserContactModel userContact = UserContactModel(
                  username: snapshot.data!["name"],
                  uid: document!["senderId"],
                  phoneNumber: snapshot.data!["phone"],
                  image: snapshot.data!["image"],
                  isRegister: true);
              var data = {"chatId": document!["chatId"], "data": userContact};
              Get.toNamed(routeName.chat, arguments: data);
            });
          }
        });
  }
}
