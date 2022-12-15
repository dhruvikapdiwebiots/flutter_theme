
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
              color: Colors.indigo,
              text: fonts.document.tr,
              onTap: () => chatCtrl.documentShare()),
          const HSpace(Sizes.s40),
          IconCreation(
              icons: Icons.video_collection_sharp,
              color: Colors.pink,
              text: fonts.video.tr,
              onTap: ()async {
                print("object");
                chatCtrl.pickerCtrl.dismissKeyboard();
                Get.back();
                chatCtrl.videoSend();
              }),
          const HSpace(Sizes.s40),
          IconCreation(
              onTap: () {
                Get.back();
                chatCtrl.pickerCtrl.imagePickerOption(Get.context!);
                chatCtrl.imageFile = chatCtrl.pickerCtrl.imageFile;
                chatCtrl.update();
                chatCtrl.uploadFile();
              },
              icons: Icons.insert_photo,
              color: Colors.purple,
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
              color: Colors.orange,
              text: fonts.audio.tr),
          const HSpace(Sizes.s40),
          IconCreation(
              onTap: () => chatCtrl.locationShare(),
              icons: Icons.location_pin,
              color: Colors.teal,
              text: fonts.location.tr),
          const HSpace(Sizes.s40),
          IconCreation(
              icons: Icons.person,
              color: Colors.blue,
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
