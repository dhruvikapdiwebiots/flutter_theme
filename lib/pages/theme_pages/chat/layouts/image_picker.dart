import '../../../../config.dart';

class ImagePickerLayout extends StatelessWidget {
  const ImagePickerLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (chatCtrl) {
        return Container(
          padding: const EdgeInsets.all(12),
          height: Sizes.s150,
          alignment: Alignment.bottomCenter,
          child: Column(children: [
            const VSpace(Sizes.s20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconCreation(
                icons: Icons.camera,
                color: appCtrl.appTheme.primary,
                text: fonts.camera.tr,
                onTap: () {
                  chatCtrl.dismissKeyboard();
                  chatCtrl.getImage(ImageSource.camera);
                  Get.back();
                }),
                IconCreation(
                    icons: Icons.image,
                    color: appCtrl.appTheme.primary,
                    text: fonts.gallery.tr,
                    onTap: () {
                      chatCtrl.getImage(ImageSource.gallery);
                      Get.back();
                    }),

              ],
            ),
          ]),
        );
      }
    );
  }
}
