import '../../../../config.dart';

class SubTitleLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? blockBy,name;
  const SubTitleLayout({Key? key,this.document,this.name,this.blockBy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.done_all,
            color: document!["isSeen"]
                ? appCtrl.isTheme ?appCtrl.appTheme.white : appCtrl.appTheme.primary
                : appCtrl.appTheme.grey,
            size: Sizes.s16),
        const HSpace(Sizes.s10),
        document!["lastMessage"].contains(".gif") ?const Icon(Icons.gif_box) :
        Text(
            (document!["lastMessage"].contains("media")) ? "You Share Media" :   document!["isBlock"] == true &&
                document!["isBlock"] == "true"
                ? document!["blockBy"] != blockBy
                ? document!["blockUserMessage"]
                : document!["lastMessage"]
                .contains("http")
                :  (document!["lastMessage"].contains(".pdf") ||
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
            overflow: TextOverflow.ellipsis).width(Sizes.s150),
      ],
    );
  }
}
