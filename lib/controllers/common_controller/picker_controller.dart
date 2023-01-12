import 'dart:developer';
import 'dart:io';

import 'package:flutter_theme/config.dart';
import 'package:image_cropper/image_cropper.dart';

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
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: appCtrl.appTheme.primary,
              toolbarWidgetColor: appCtrl.appTheme.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        image = File(croppedFile.path);
      }
    

      update();
      log("image : $image");
      Get.forceAppUpdate();
    }
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
  imagePickerOption(BuildContext context, {isGroup = false,isSingleChat = false,isCreateGroup =false}) {
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
            await getImage(ImageSource.camera).then((value) {
              if(isGroup) {
                final chatCtrl = Get.find<GroupChatMessageController>();
                chatCtrl.uploadFile();
              }else if(isSingleChat){
                final singleChatCtrl = Get.find<ChatController>();
                singleChatCtrl.uploadFile();
              } else if(isCreateGroup){
                final singleChatCtrl = Get.find<CreateGroupController>();
                singleChatCtrl.uploadFile();
              } else{
                final broadcastCtrl = Get.find<BroadcastChatController>();
                broadcastCtrl.uploadFile();
              }
            });
            Get.back();
          }, galleryTap: () async {
            await getImage(ImageSource.gallery).then((value) {
              if(isGroup) {
                final chatCtrl = Get.find<GroupChatMessageController>();
                chatCtrl.uploadFile();
              }else if(isSingleChat){
                final singleChatCtrl = Get.find<ChatController>();
                singleChatCtrl.uploadFile();
              } else if(isCreateGroup){
                final singleChatCtrl = Get.find<CreateGroupController>();
                singleChatCtrl.uploadFile();
              } else{
                final broadcastCtrl = Get.find<BroadcastChatController>();
                broadcastCtrl.uploadFile();
              }
            });
            Get.back();
          });
        });
  }

  //video picker option
  videoPickerOption(BuildContext context, {isGroup = false,isSingleChat = false}) {
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
