import 'dart:developer';
import 'dart:io';

import 'package:flutter_theme/config.dart';

class PickerController extends GetxController {
  XFile? imageFile;
  XFile? videoFile;
  File? image;
  File? video;
  String? imageUrl;
  String? audioUrl;

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


// GET VIDEO FROM GALLERY
  Future getVideo(source) async {
    final ImagePicker picker = ImagePicker();
    videoFile = (await picker.pickVideo(source: source))!;
    if (videoFile != null) {
      video = File(videoFile!.path);
      update();
      log("getV : $video");
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
  videoPickerOption(BuildContext context, {isGroup = true,isSingleChat = false}) {
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
            await getVideo(ImageSource.camera).then((value) {
              if(isGroup) {
                final chatCtrl = Get.find<GroupChatMessageController>();
                chatCtrl.videoSend();
              }else if(isSingleChat){
                final singleChatCtrl = Get.find<ChatController>();
                singleChatCtrl.videoSend();
              }else{
                final broadcastCtrl = Get.find<BroadcastChatController>();
                broadcastCtrl.videoSend();
              }
            });
            Get.back();
          }, galleryTap: () async {
            await getVideo(ImageSource.gallery).then((value){
              if(isGroup) {
                final chatCtrl = Get.find<GroupChatMessageController>();
                chatCtrl.videoSend();
              }else if(isSingleChat){
                final singleChatCtrl = Get.find<ChatController>();
                singleChatCtrl.videoSend();
              }else{
                final broadcastCtrl = Get.find<BroadcastChatController>();
                broadcastCtrl.videoSend();
              }
            });
            Get.back();
          });
        });
  }

  Future<String> uploadImage(File file, {String? fileNameText}) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child(fileNameText ?? fileName);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    imageUrl = downloadUrl;
    return imageUrl!;
  }

  Future<String> uploadAudio(File file, {String? fileNameText}) async {
    log("message");
    log("message ");
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child(fileNameText ?? fileName);
    UploadTask uploadTask = reference.putFile(file);
  log("uploadTask : $uploadTask");
    uploadTask.then((res) {
      log("res : $res");
      res.ref.getDownloadURL().then((downloadUrl) {
        audioUrl = downloadUrl;
        update();
      }, onError: (err) {

        Fluttertoast.showToast(msg: 'Image is Not Valid');
      });
    });
    return audioUrl!;
  }
}
