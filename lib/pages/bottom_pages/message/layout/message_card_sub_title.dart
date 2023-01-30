import '../../../../config.dart';

class MessageCardSubTitle extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy,name;

  const MessageCardSubTitle({Key? key, this.document, this.currentUserId,this.blockBy,this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(children: [
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
              (document!["lastMessage"]
                  .contains("media"))
                  ? "$name Media Share"
                  : document!["isBlock"] == true &&
                  document!["isBlock"] == "true"
                  ? document!["blockBy"] != blockBy
                  ? document![
              "blockUserMessage"]
                  : document!["lastMessage"]
                  .contains("http")
                  : (document!["lastMessage"]
                  .contains(".pdf") ||
                  document!["lastMessage"]
                      .contains(".doc") ||
                  document!["lastMessage"]
                      .contains(".mp3") ||
                  document!["lastMessage"]
                      .contains(".mp4") ||
                  document!["lastMessage"]
                      .contains(".xlsx") ||
                  document!["lastMessage"]
                      .contains(".ods"))
                  ? document!["lastMessage"]
                  .split("-BREAK-")[0]
                  : document!["lastMessage"],
              style: AppCss.poppinsMedium12
                  .textColor(appCtrl.appTheme.grey).textHeight(1.2),
              overflow: TextOverflow.ellipsis),
        )
      ]),
    );
  }
}
