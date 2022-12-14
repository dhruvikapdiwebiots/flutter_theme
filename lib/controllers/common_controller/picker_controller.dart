import 'dart:io';

import 'package:flutter_theme/config.dart';

class PickerController extends GetxController {
  XFile? imageFile;
  File? image;

// GET IMAGE FROM GALLERY
  Future getImage(source) async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source))!;
    if (imageFile != null) {
      image = File(imageFile!.path);
      update();
    }
    Get.forceAppUpdate();
  }

// FOR Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  //image picker option
  imagePickerOption(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return ImagePickerLayout(cameraTap: () async {
            dismissKeyboard();
            await getImage(ImageSource.camera);
            Get.back();
          }, galleryTap: () async {
            await getImage(ImageSource.gallery);
            Get.back();
          });
        });
  }
}
