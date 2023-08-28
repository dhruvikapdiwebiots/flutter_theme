
import '../../../../config.dart';

class GroupCardSubTitle extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? name, currentUserId;
  final bool hasData;
  final dynamic data;

  const GroupCardSubTitle(
      {Key? key,
      this.document,
      this.name,
      this.currentUserId,
      this.data,
      this.hasData = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (currentUserId == document!["senderId"])
          (document!.data().toString().contains('messageType'))
              ? document!["messageType"] != MessageType.messageType.name
                  ? Icon(Icons.done_all,
                      color: appCtrl.isTheme
                          ? appCtrl.appTheme.white
                          : appCtrl.appTheme.grey,
                      size: Sizes.s16).marginOnly(right: Insets.i5)
                  : Container()
              : Icon(Icons.done_all,
                  color: appCtrl.isTheme
                      ? appCtrl.appTheme.white
                      : appCtrl.appTheme.grey,
                  size: Sizes.s16).marginOnly(right: Insets.i5),
        data["groupMessage"].contains("gif")
            ? const Icon(
                Icons.gif_box,
                size: Sizes.s20,
              ).alignment(Alignment.centerLeft)
            : SizedBox(
                width: Sizes.s150,
                child: Text(
                       data["groupMessage"],
                        overflow: TextOverflow.ellipsis,
                        style: AppCss.poppinsMedium12
                            .textColor(appCtrl.appTheme.txtColor)
                            .textHeight(1.2)
                            .letterSpace(.2))
                    .width(Sizes.s170),
              ),
      ],
    );
  }
}
