import 'dart:io';

import 'package:flutter_theme/config.dart';

class PickerController extends GetxController {
  XFile? imageFile;
  XFile? videoFile;
  File? image;
  File? video;
  String? imageUrl;

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

  //video picker option
  videoPickerOption(BuildContext context) {
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
            final ImagePicker picker = ImagePicker();
            videoFile = (await picker.pickVideo(source: ImageSource.camera))!;
            if (videoFile != null) {
              video = File(videoFile!.path);

              update();
              Get.back(result: video);
            }
            update();
          }, galleryTap: () async {
            final ImagePicker picker = ImagePicker();
            videoFile = (await picker.pickVideo(source: ImageSource.gallery))!;
            if (videoFile != null) {
              video = File(videoFile!.path);
              update();
              Get.back(result: video);
            }
            update();
          });
        });
  }

  Future<String> uploadImage(File file,{String? fileNameText}) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child( fileNameText ?? fileName);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    imageUrl = downloadUrl;
    return imageUrl!;
  }


  Future<String> uploadAudio(File file,{String? fileNameText}) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child( fileNameText ?? fileName);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    imageUrl = downloadUrl;
    return imageUrl!;
  }
}
