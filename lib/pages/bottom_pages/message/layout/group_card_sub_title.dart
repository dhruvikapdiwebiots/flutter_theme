import '../../../../config.dart';

class GroupCardSubTitle extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? name, currentUserId;
  final bool hasData;

  const GroupCardSubTitle(
      {Key? key,
      this.document,
      this.name,
      this.currentUserId,
      this.hasData = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: (document!["lastMessage"].contains(".gif"))
          ? const Icon(
              Icons.gif_box,
              size: Sizes.s20,
            ).alignment(Alignment.centerLeft)
          : Text(
              (document!["lastMessage"].contains("media"))
                  ? hasData
                      ? "$name Media Share"
                      : "Media Share"
                  : (document!["lastMessage"].contains(".pdf") ||
                          document!["lastMessage"].contains(".docx") ||
                          document!["lastMessage"].contains(".mp3") ||
                          document!["lastMessage"].contains(".mp4") ||
                          document!["lastMessage"].contains(".xlsx") ||
                          document!["lastMessage"].contains(".ods"))
                      ? document!["lastMessage"].split("-BREAK-")[0]
                      : document!["lastMessage"] == ""
                          ? currentUserId == document!["senderId"]
                              ? "You Create this group ${document!["group"]['name']}"
                              : "${document!["sender"]['name']} added you"
                          : document!["lastMessage"],
              style: AppCss.poppinsMedium12
                  .textColor(appCtrl.appTheme.grey)
                  .textHeight(1.2)
                  .letterSpace(.2)),
    );
  }
}
