import 'dart:io';

import '../../../../config.dart';

class UnRegisterUser extends StatelessWidget {
  final UserContactModel? item;
  final PhotoUrl? message;

  const UnRegisterUser({Key? key, this.item, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          vertical: Insets.i5, horizontal: Insets.i18),
      onTap: () {
        MessageFirebaseApi().saveContact(item!, message: message);
      },
      leading: item!.isRegister == false
          ? CircleAvatar(
          child: Text(
            item!.username!.length > 2
                ? item!.username!
                .replaceAll(" ", "")
                .substring(0, 2)
                .toUpperCase()
                : item!.username![0],
            style: AppCss.poppinsMedium12
                .textColor(appCtrl.appTheme.whiteColor),
          ))
          : item!.contactImage != null
              ? CircleAvatar(backgroundImage: MemoryImage(item!.contactImage!))
              : CircleAvatar(
                  child: Text(
                      item!.username!.length > 2
                          ? item!.username!
                              .replaceAll(" ", "")
                              .substring(0, 2)
                              .toUpperCase()
                          : item!.username![0],
                      style: AppCss.poppinsMedium12
                          .textColor(appCtrl.appTheme.whiteColor))),
      title: Text(item!.username!),
      trailing: !item!.isRegister!
          ? Icon(
              Icons.person_add_alt_outlined,
              color: appCtrl.appTheme.primary,
            ).inkWell(onTap: () async {
              if (Platform.isAndroid) {
                final uri = Uri(
                  scheme: "sms",
                  path: phoneNumberExtension(item!.phoneNumber),
                  queryParameters: <String, String>{
                    'body': Uri.encodeComponent('Download the ChatBox App'),
                  },
                );
                await launchUrl(uri);
              }
            })
          : const SizedBox(height: 1, width: 1),
    );
  }
}
