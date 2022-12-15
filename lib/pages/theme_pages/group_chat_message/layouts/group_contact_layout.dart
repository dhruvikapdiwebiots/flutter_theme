
import 'package:intl/intl.dart';

import '../../../../config.dart';

class GroupContactLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final VoidCallback? onLongPress;
final String? currentUserId;
  const GroupContactLayout({Key? key, this.document, this.onLongPress,this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        child: Container(
            decoration: BoxDecoration(
              color: appCtrl.appTheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.r15),
            ),
            width: Sizes.s280,

            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if(document!["sender"] != currentUserId)
                  Text(document!['senderName'],
                      style: AppCss.poppinsMedium14
                          .textColor(appCtrl.appTheme.whiteColor)).alignment(Alignment.bottomLeft).paddingAll(Insets.i15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: ContactListTile(document: document,)),
                      Text(DateFormat('HH:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document!['timestamp']))),style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.whiteColor),).marginSymmetric(horizontal: Insets.i10)
                    ],
                  ),
                  Divider(
                      height: 7,
                      color: appCtrl.appTheme.whiteColor.withOpacity(.2)),
                  // ignore: deprecated_member_use
                  TextButton(
                      onPressed: () {},
                      child: Text("Message",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: appCtrl.appTheme.whiteColor)))
                ])));
  }
}
