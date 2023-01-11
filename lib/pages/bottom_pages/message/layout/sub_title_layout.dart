import '../../../../config.dart';

class SubTitleLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? blockBy,name;
  const SubTitleLayout({Key? key,this.document,this.name,this.blockBy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        children: [
          Icon(Icons.done_all,
              color: document!["isSeen"]
                  ? appCtrl.isTheme ?appCtrl.appTheme.white : appCtrl.appTheme.primary
                  : appCtrl.appTheme.grey,
              size: Sizes.s16),
          const HSpace(Sizes.s10),
          document!["lastMessage"].contains(".gif") ?const Icon(Icons.gif_box) :
          Expanded(
            child:  Text(
                (document!["lastMessage"].contains("media")) ? "$name Media Share" :   document!["isBlock"] == true &&
                    document!["isBlock"] == "true"
                    ? document!["blockBy"] != blockBy
                    ? document!["blockUserMessage"]
                    : document!["lastMessage"]
                    .contains("http")
                    :  (document!["lastMessage"].contains(".pdf") ||
                    document!["lastMessage"]
                        .contains(".docx") ||
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
                style: AppCss.poppinsMedium14
                    .textColor(appCtrl.appTheme.grey),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
