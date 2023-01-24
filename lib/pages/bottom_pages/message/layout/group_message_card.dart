

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
            .collection("groups")
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
              builder: (context, userSnapShot){
                if(userSnapShot.hasData){
                  return Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: appCtrl.appTheme.lightGreyColor))),
                    margin: const EdgeInsets.symmetric(
                      horizontal: Insets.i5),
                    child: ListTile(
                        onTap: () {
                          Get.toNamed(routeName.groupChatMessage,
                              arguments: snapshot.data);
                        },
                        contentPadding: EdgeInsets.zero,
                        leading: CommonImage(
                          image: (snapshot.data!)["image"],
                        ),
                        trailing: Text(
                            DateFormat('HH:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(document!['updateStamp']))),
                            style: AppCss.poppinsMedium12
                                .textColor(appCtrl.appTheme.grey)),
                        title: Text(snapshot.data!["name"],
                            style: AppCss.poppinsblack16
                                .textColor(appCtrl.appTheme.blackColor)),
                        subtitle: document!["lastMessage"] != null
                            ? GroupCardSubTitle(
                            currentUserId: currentUserId,
                            name: userSnapShot.data!["name"],
                            document: document,
                            hasData: userSnapShot.hasData)
                            : Container()),
                  );
                }else{
                  return Container();
                }
              },
            );
          }
        });
  }
}
