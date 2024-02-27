import '../../../../config.dart';

class SubTitleLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? blockBy,name;
  final dynamic data;
  const SubTitleLayout({Key? key,this.document,this.name,this.blockBy,this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if(document!["senderId"] == appCtrl.user['id'])
        Icon(Icons.done_all,
            color:  document!["isSeen"]
                ? appCtrl.isTheme ?appCtrl.appTheme.white : appCtrl.appTheme.primary
                : appCtrl.appTheme.grey,
            size: Sizes.s16),
        if(document!["senderId"] == appCtrl.user['id'])
        const HSpace(Sizes.s10),
        data["senderMessage"].contains("gif") ?const Icon(Icons.gif_box) :
        SizedBox(
          width: Sizes.s150,
          child: Text(
             data["senderMessage"] != "" ? data["senderMessage"]:"",
              style: AppCss.poppinsMedium12
                  .textColor(appCtrl.appTheme.grey).textHeight(1.2),
              overflow: TextOverflow.ellipsis).width(Sizes.s150),
        ),
      ],
    );
  }
}
