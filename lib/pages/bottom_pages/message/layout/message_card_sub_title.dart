import '../../../../config.dart';

class MessageCardSubTitle extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy,name;
final dynamic data;
  const MessageCardSubTitle({Key? key, this.document, this.currentUserId,this.blockBy,this.name,this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Row(children: [
      if (currentUserId == document!["senderId"])
        Icon(Icons.done_all,
            color: document!["isSeen"]
                ? appCtrl.isTheme
                ? appCtrl.appTheme.white
                : appCtrl.appTheme.primary
                : appCtrl.appTheme.grey,
            size: Sizes.s16),
      if (currentUserId == document!["senderId"])
        const HSpace(Sizes.s10),
      Expanded(
        child: Text(
           data["receiverMessage"],
            style: AppCss.poppinsMedium12
                .textColor(appCtrl.appTheme.grey).textHeight(1.2),
            overflow: TextOverflow.ellipsis),
      )
    ]).width(Sizes.s170);
  }
}
