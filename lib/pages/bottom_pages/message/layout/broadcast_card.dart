import 'package:flutter_theme/widgets/common_extension.dart';
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
    return ListTile(
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
      subtitle: Text(
          document!["lastMessage"],overflow: TextOverflow.ellipsis,
          style: AppCss.poppinsMedium14
              .textColor(appCtrl.appTheme.txtColor)
      ),
      leading:const Icon(Icons.volume_down).paddingAll(Insets.i12).decorated(color: appCtrl.appTheme.grey.withOpacity(.4),borderRadius: BorderRadius.circular(AppRadius.r8)),
      trailing: Text(
          DateFormat('HH:mm a').format(
              DateTime.fromMillisecondsSinceEpoch(
                  int.parse(document!['updateStamp']))),
          style:  AppCss.poppinsMedium12
              .textColor(appCtrl.appTheme.txtColor)
      ),
    ) .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i5)
        .commonDecoration()
        .marginSymmetric(horizontal: Insets.i10);
  }
}
