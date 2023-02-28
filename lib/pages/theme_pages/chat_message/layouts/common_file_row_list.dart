

import '../../../../../../config.dart';

class CommonFileRowList extends StatelessWidget {

  const CommonFileRowList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconCreation(
              icons: Icons.insert_drive_file,
              color: appCtrl.appTheme.indigoColor,
              text: fonts.document.tr,
              onTap: () => chatCtrl.documentShare()),
          const HSpace(Sizes.s40),
          IconCreation(
              icons: Icons.video_collection_sharp,
              color: appCtrl.appTheme.pinkColor,
              text: fonts.video.tr,
              onTap: () {
                Get.back();
                chatCtrl.pickerCtrl.videoPickerOption(context,isSingleChat: true);

              }),
          const HSpace(Sizes.s40),
          IconCreation(
              onTap: () {
              // Get.back();
                chatCtrl.pickerCtrl.imagePickerOption(Get.context!,isSingleChat: true);

              },
              icons: Icons.insert_photo,
              color: appCtrl.appTheme.purpleColor,
              text: fonts.gallery.tr)
        ]),
        const VSpace(Sizes.s30),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconCreation(
              onTap: () {
                Get.back();
                chatCtrl.audioRecording(context,"audio",0);
              },
              icons: Icons.headset,
              color: appCtrl.appTheme.orangeColor,
              text: fonts.audio.tr),
          const HSpace(Sizes.s40),
          IconCreation(
              onTap: () => chatCtrl.locationShare(),
              icons: Icons.location_pin,
              color: appCtrl.appTheme.tealColor,
              text: fonts.location.tr),
          const HSpace(Sizes.s40),
          IconCreation(
              icons: Icons.person,
              color: appCtrl.appTheme.blueColor,
              text: fonts.contact.tr,
              onTap: () {
                chatCtrl.pickerCtrl.dismissKeyboard();
                Get.back();
                chatCtrl.saveContactInChat();
              })
        ])
      ]);
    });
  }
}
