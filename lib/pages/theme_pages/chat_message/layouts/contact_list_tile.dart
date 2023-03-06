import '../../../../config.dart';

class ContactListTile extends StatelessWidget {
  final DocumentSnapshot? document;
  final bool isReceiver;

  const ContactListTile({Key? key, this.document, this.isReceiver = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
minVerticalPadding: 0,

        dense:true,
        contentPadding: const EdgeInsets.symmetric(horizontal: Insets.i15),
          leading: CachedNetworkImage(
              imageUrl: document!['content'].split('-BREAK-')[2],
              imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundColor: isReceiver?appCtrl.appTheme.txtColor : appCtrl.appTheme.contactBgGray,
                    radius: AppRadius.r22,
                    backgroundImage: NetworkImage(
                        '${document!['content'].split('-BREAK-')[2]}'),
                  ),
              placeholder: (context, url) => CircleAvatar(
                  backgroundColor: isReceiver?appCtrl.appTheme.txtColor : appCtrl.appTheme.contactBgGray,
                  radius: AppRadius.r22,
                  child: Icon(Icons.people, color: appCtrl.appTheme.contactGray)),
              errorWidget: (context, url, error) => CircleAvatar(
                  backgroundColor: isReceiver?appCtrl.appTheme.txtColor : appCtrl.appTheme.contactBgGray,
                  radius: AppRadius.r22,
                  child:
                      Icon(Icons.people, color: appCtrl.appTheme.contactGray))),
        title: Text(document!['content'].split('-BREAK-')[0],
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AppCss.poppinsblack14.textColor(isReceiver
                ? appCtrl.appTheme.primary
                : appCtrl.appTheme.whiteColor)));
  }
}
