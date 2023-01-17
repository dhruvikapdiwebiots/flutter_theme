

import '../../../../config.dart';

class ContactLayout extends StatelessWidget {
  final dynamic document;
  final VoidCallback? onLongPress;

  final bool isReceiver;

  const ContactLayout(
      {Key? key, this.document, this.onLongPress, this.isReceiver = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        child: Stack(
          alignment: isReceiver ? Alignment.topLeft : Alignment.topRight,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    CachedNetworkImage(
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
                    const HSpace(Sizes.s10),
                    Text(document!['content'].split('-BREAK-')[0],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppCss.poppinsblack14.textColor(isReceiver
                            ? appCtrl.appTheme.primary
                            : appCtrl.appTheme.whiteColor))
                  ]
                )
              ],
            ),
            /*Container(
                padding: const EdgeInsets.symmetric(vertical: Insets.i5),
                decoration: BoxDecoration(
                    color: isReceiver
                        ? appCtrl.appTheme.white
                        : appCtrl.appTheme.primary,
                    borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(AppRadius.r8),
                        bottomRight: const Radius.circular(AppRadius.r8),
                        topLeft: isReceiver
                            ? const Radius.circular(0)
                            : const Radius.circular(AppRadius.r8),
                        topRight: isReceiver
                            ? const Radius.circular(AppRadius.r8)
                            : const Radius.circular(0)),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 15.0,
                          color: appCtrl.appTheme.blackColor.withOpacity(.25),
                          offset: const Offset(-2, 2))
                    ]),
                width: Sizes.s280,
                height: Sizes.s100,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              child: ContactListTile(
                            document: document,
                          )),
                          Text(
                            DateFormat('HH:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(document!['timestamp']))),
                            style: AppCss.poppinsMedium12.textColor(isReceiver
                                ? appCtrl.appTheme.primary
                                : appCtrl.appTheme.whiteColor),
                          ).marginSymmetric(horizontal: Insets.i10)
                        ],
                      ),
                      Divider(height: 7, color: appCtrl.appTheme.whiteColor),
                      // ignore: deprecated_member_use
                      *//*TextButton(
                          onPressed: () async {
                            final uri = Uri(
                              scheme: "sms",
                              path: document!['content'].split('-BREAK-')[1],
                              queryParameters: <String, String>{
                                'body': Uri.encodeComponent(
                                    'Download the ChatBox App'),
                              },
                            );
                            await launchUrl(uri);
                          },
                          child: Text("Message",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: appCtrl.appTheme.whiteColor)))*//*
                    ])),*/
            CustomPaint(painter: CustomShape(appCtrl.appTheme.primary)),
          ],
        ).marginSymmetric(horizontal: Insets.i8,vertical: Insets.i10));
  }
}
