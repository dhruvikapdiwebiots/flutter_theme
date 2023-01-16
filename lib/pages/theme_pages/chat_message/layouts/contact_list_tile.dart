import '../../../../config.dart';

class ContactListTile extends StatelessWidget {
  final DocumentSnapshot? document;
  final bool isReceiver;

  const ContactListTile({Key? key, this.document, this.isReceiver = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        isThreeLine: false,
        leading: CachedNetworkImage(
            imageUrl: document!['content'].split('-BREAK-')[2],
            imageBuilder: (context, imageProvider) => CircleAvatar(
                  backgroundColor: appCtrl.appTheme.contactBgGray,
                  radius: AppRadius.r20,
                  backgroundImage: NetworkImage(
                      '${document!['content'].split('-BREAK-')[2]}'),
                ),
            placeholder: (context, url) => CircleAvatar(
                backgroundColor: appCtrl.appTheme.contactBgGray,
                radius: AppRadius.r20,
                child: Icon(Icons.people, color: appCtrl.appTheme.contactGray)),
            errorWidget: (context, url, error) => CircleAvatar(
                backgroundColor: appCtrl.appTheme.contactBgGray,
                radius: AppRadius.r20,
                child:
                    Icon(Icons.people, color: appCtrl.appTheme.contactGray))),
        title: Text(document!['content'].split('-BREAK-')[0],
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AppCss.poppinsblack14.textColor(isReceiver
                ? appCtrl.appTheme.primary
                : appCtrl.appTheme.whiteColor)),
        subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              document!['content'].split('-BREAK-')[1],
              style: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: isReceiver
                      ? appCtrl.appTheme.primary
                      : appCtrl.appTheme.whiteColor),
            )));
  }
}
