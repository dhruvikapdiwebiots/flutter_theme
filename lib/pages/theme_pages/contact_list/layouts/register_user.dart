import 'dart:io';

import '../../../../config.dart';
import '../../../../models/contact_model.dart';

class RegisterUser extends StatelessWidget {
  final UserContactModel? userContactModel;
  const RegisterUser({Key? key,this.userContactModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        MessageFirebaseApi().saveContact(
            userContactModel,
            userContactModel!
                .isRegister);
      },
      leading: userContactModel!.isRegister!
          ? CachedNetworkImage(
          imageUrl: userContactModel!.image!,
          imageBuilder: (context,
              imageProvider) =>
              CircleAvatar(
                backgroundColor:
                const Color(
                    0xffE6E6E6),
                radius: Sizes.s20,
                backgroundImage:
                NetworkImage(userContactModel!
                    .image!),
              ),
          placeholder: (context, url) =>
              const CircularProgressIndicator(
                strokeWidth: 2,
              )
                  .width(Sizes.s20)
                  .height(Sizes.s20)
                  .paddingAll(Insets.i15)
                  .decorated(
                  color: appCtrl.appTheme.grey
                      .withOpacity(
                      .4),
                  shape: BoxShape
                      .circle),
          errorWidget: (context, url, error) =>
              CircleAvatar(
                  child: Text(
                    userContactModel!
                        .username!
                        .length >
                        2
                        ? userContactModel!
                        .username!
                        .replaceAll(
                        " ", "")
                        .substring(0, 2)
                        .toUpperCase()
                        : userContactModel!
                        .username![0],
                    style: AppCss
                        .poppinsMedium12
                        .textColor(appCtrl
                        .appTheme
                        .whiteColor),
                  )))
          : userContactModel!.contactImage !=
          null
          ? CircleAvatar(
          backgroundImage:
          MemoryImage(userContactModel!.contactImage!))
          : CircleAvatar(child: Text(userContactModel!.username!.length > 2 ? userContactModel!.username!.replaceAll(" ", "").substring(0, 2).toUpperCase() : userContactModel!.username![0], style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.whiteColor))),
      title: Text(
          userContactModel!.username! ??
              ""),
      subtitle: Text(userContactModel!
          .description ??
          ""),
      trailing: !userContactModel!.isRegister!
          ? Icon(
        Icons.person_add_alt_outlined,
        color: appCtrl.appTheme.primary,
      ).inkWell(onTap: () async {
        if (Platform.isAndroid) {
          final uri = Uri(
            scheme: "sms",
            path: phoneNumberExtension(
                userContactModel!
                    .phoneNumber),
            queryParameters: <String,
                String>{
              'body': Uri.encodeComponent(
                  'Download the ChatBox App'),
            },
          );
          await launchUrl(uri);
        }
      })
          : const SizedBox(
        height: 1,
        width: 1,
      ),
    );
  }
}
