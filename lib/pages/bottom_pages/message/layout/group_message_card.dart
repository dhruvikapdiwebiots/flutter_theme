import 'package:flutter_theme/widgets/common_extension.dart';
import 'package:intl/intl.dart';
import '../../../../config.dart';

class GroupMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;

  const GroupMessageCard({Key? key, this.document, this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(collectionName.groups)
            .doc(document!["groupId"])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(document!["senderId"])
                        .snapshots(),
                    builder: (context, userSnapShot) {
                      if (userSnapShot.hasData) {

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CommonImage(image: (snapshot.data!)["image"],name: (snapshot.data!)["name"],),
                                const HSpace(Sizes.s12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(snapshot.data!["name"],
                                        style: AppCss.poppinsblack14
                                            .textColor(appCtrl.appTheme.blackColor)),
                                    const VSpace(Sizes.s5),
                                    document!["lastMessage"] != null
                                        ? GroupCardSubTitle(
                                        currentUserId: currentUserId,
                                        name: userSnapShot.data!["name"],
                                        document: document,
                                        hasData: userSnapShot.hasData)
                                        : Container(height: Sizes.s15,)
                                  ],
                                ),
                              ],
                            ),
                            Text(
                                DateFormat('HH:mm a').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document!['updateStamp']))),
                                style: AppCss.poppinsMedium12
                                    .textColor(appCtrl.appTheme.txtColor)).paddingOnly(top: Insets.i8)
                          ],
                        ).paddingSymmetric(vertical: Insets.i10).inkWell(onTap: () {
                          Get.toNamed(routeName.groupChatMessage,
                              arguments: snapshot.data);
                        });

                      } else {
                        return Container();
                      }
                    }).width(MediaQuery.of(context).size.width)
                .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i4)
                .commonDecoration()
                .marginSymmetric(horizontal: Insets.i10);
          }
        });
  }
}
