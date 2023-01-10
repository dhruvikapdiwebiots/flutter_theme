import 'package:intl/intl.dart';

import '../../../../config.dart';

class BroadCastMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;

  const BroadCastMessageCard({Key? key, this.document, this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List selectedContact = document!["receiverId"];
    return Container(

      margin: const EdgeInsets.only(
          bottom: Insets.i10, left: Insets.i5, right: Insets.i5),

      child: ListTile(
        onTap: (){
          var data={
            "broadcastId":document!["broadcastId"],
            "data":document,

          };
          Get.toNamed(routeName.broadcastChat,arguments: data);
        },
        contentPadding: EdgeInsets.zero,
        title: Text(
            "${selectedContact.length} recipient",
            style: AppCss.poppinsblack16
                .textColor(appCtrl.appTheme.blackColor)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
              document!["lastMessage"],
              style: AppCss.poppinsMedium14
                  .textColor(appCtrl.appTheme.grey)
          ),
        ),
        leading:const Icon(Icons.volume_down).paddingAll(Insets.i15).decorated(color: appCtrl.appTheme.grey.withOpacity(.4),shape: BoxShape.circle),
        trailing: Text(
            DateFormat('HH:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(document!['updateStamp']))),
            style:  AppCss.poppinsMedium12
                .textColor(appCtrl.appTheme.grey)
        ),
      ),
    );
  }
}
