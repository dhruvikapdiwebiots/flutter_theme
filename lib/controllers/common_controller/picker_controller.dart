import 'dart:developer';
import 'dart:io';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_theme/config.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:light_compressor/light_compressor.dart' as light;

class PickerController extends GetxController {
  XFile? imageFile;
  XFile? videoFile;
  File? image;
  File? video;
  String? imageUrl;
  String? audioUrl;
  List<DrishyaEntity>? entities;

  GallerySetting gallerySetting = GallerySetting(
    enableCamera: false,
    maximumCount: appCtrl.usageControlsVal != null
        ? appCtrl.usageControlsVal!.maxFilesMultiShare!
        : 1,
    requestType: RequestType.image,
    cameraSetting: const CameraSetting(videoDuration: Duration(seconds: 15)),
  );

  GallerySetting galleryVideoSetting = GallerySetting(
    enableCamera: false,
    maximumCount: appCtrl.usageControlsVal != null
        ? appCtrl.usageControlsVal!.maxFilesMultiShare!
        : 1,
    requestType: RequestType.video,
    cameraSetting: const CameraSetting(videoDuration: Duration(seconds: 15)),
  );

// GET IMAGE FROM GALLERY
  Future getImage(source) async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source, imageQuality: 30))!;
    if (imageFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile!.path,
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
        File compressedFile = await FlutterNativeImage.compressImage(
            croppedFile.path,
            quality: 30,
            targetWidth: 600,
            targetHeight: 300,
            percentage: 20);
        update();

        log("image : ${compressedFile.lengthSync()}");

        image = File(compressedFile.path);
        if (image!.lengthSync() / 1000000 >
            appCtrl.usageControlsVal!.maxFileSize!) {
          image = null;
          snackBar(
              "Image Should be less than ${image!.lengthSync() / 1000000 > appCtrl.usageControlsVal!.maxFileSize!}");
        }
      }
      log("image1 : $image");
      log("image1 : ${image!.lengthSync() / 1000000 > 60}");

      Get.forceAppUpdate();
    }
  }

// GET IMAGE FROM GALLERY
  Future getMultipleImage() async {
    GalleryController controller = GalleryController();
    entities = await controller.pick(
      Get.context!,
      setting: gallerySetting,
    );

    update();
    return entities;
  }

// GET VIDEO FROM GALLERY
  Future getVideo(source) async {
    appCtrl.isLoading = true;
    update();
    final light.LightCompressor lightCompressor = light.LightCompressor();
    final ImagePicker picker = ImagePicker();
    videoFile = (await picker.pickVideo(
      source: source,
    ))!;
    if (videoFile != null) {
      log("videoFile!.path : ${videoFile!.path}");
      final dynamic response = await lightCompressor.compressVideo(
        path: videoFile!.path,
        videoQuality: light.VideoQuality.very_low,
        isMinBitrateCheckEnabled: false,
        video: light.Video(videoName: videoFile!.name),
        android: light.AndroidConfig(
            isSharedStorage: true, saveAt: light.SaveAt.Movies),
        ios: light.IOSConfig(saveInGallery: false),
      );

      video = File(videoFile!.path);
      if (response is light.OnSuccess) {
        log("videoFile!.path 1: ${getVideoSize(file: File(response.destinationPath))}}");
        video = File(response.destinationPath);
      }
      appCtrl.isLoading = false;
      appCtrl.update();
      update();
    }
    Get.forceAppUpdate();
  }

// GET VIDEO FROM GALLERY
  Future getMultipleVideo() async {
    GalleryController controller = GalleryController();
    entities = await controller.pick(
      Get.context!,
      setting: galleryVideoSetting,
    );

    update();
    return entities;
  }

// FOR Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  //image picker option
  imagePickerOption(BuildContext context,
      {isGroup = false, isSingleChat = false, isCreateGroup = false}) {
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
              log("VALUE : $value");
              if (isGroup) {
                final chatCtrl = Get.find<GroupChatMessageController>();
                chatCtrl.uploadFile();
              } else if (isSingleChat) {
                final singleChatCtrl = Get.find<ChatController>();
                singleChatCtrl.uploadFile();
              } else if (isCreateGroup) {
                final singleChatCtrl = Get.find<CreateGroupController>();
                singleChatCtrl.uploadFile();
              } else {
                final broadcastCtrl = Get.find<BroadcastChatController>();
                broadcastCtrl.uploadFile();
              }
            });
            Get.back();
          }, galleryTap: () async {
            if (isCreateGroup) {
              getImage(ImageSource.gallery).then((value) {
                final singleChatCtrl = Get.find<CreateGroupController>();
                singleChatCtrl.uploadFile();
              });
            } else {
              await getMultipleImage().then((value) {
                if (value != null) {
                  if (isGroup) {
                    final chatCtrl = Get.find<GroupChatMessageController>();
                    chatCtrl.entities = value;
                    chatCtrl.isLoading = true;
                    chatCtrl.update();
                    chatCtrl.entities!.asMap().entries.forEach((element) async {
                      File? videoFile = await element.value.file;
                      File? video;
                      if (element.value.title!.contains("mp4")) {
                        final light.LightCompressor lightCompressor =
                            light.LightCompressor();
                        final dynamic response =
                            await lightCompressor.compressVideo(
                          path: videoFile!.path,
                          videoQuality: light.VideoQuality.very_low,
                          isMinBitrateCheckEnabled: false,
                          video: light.Video(videoName: element.value.title!),
                          android: light.AndroidConfig(
                              isSharedStorage: true,
                              saveAt: light.SaveAt.Movies),
                          ios: light.IOSConfig(saveInGallery: false),
                        );

                        video = File(videoFile.path);
                        if (response is light.OnSuccess) {
                          log("videoFile!.path 1: ${getVideoSize(file: File(response.destinationPath))}}");
                          video = File(response.destinationPath);
                        }
                      } else {
                        File compressedFile =
                            await FlutterNativeImage.compressImage(
                                videoFile!.path,
                                quality: 30,
                                targetWidth: 600,
                                targetHeight: 300,
                                percentage: 20);

                        log("image : ${compressedFile.lengthSync()}");

                        video = File(compressedFile.path);
                        if (video.lengthSync() / 1000000 >
                            appCtrl.usageControlsVal!.maxFileSize!) {
                          video = null;
                          snackBar(
                              "Image Should be less than ${video!.lengthSync() / 1000000 > appCtrl.usageControlsVal!.maxFileSize!}");
                        }
                      }

                      chatCtrl.uploadMultipleFile(
                          videoFile,
                          element.value.title!.contains("mp4")
                              ? MessageType.video
                              : MessageType.image);
                    });
                  } else if (isSingleChat) {
                    final singleChatCtrl = Get.find<ChatController>();
                    singleChatCtrl.entities = value;
                    singleChatCtrl.entities!
                        .asMap()
                        .entries
                        .forEach((element) async {
                      File? videoFile = await element.value.file;
                      File compressedFile =
                          await FlutterNativeImage.compressImage(
                              videoFile!.path,
                              quality: 30,
                              targetWidth: 600,
                              targetHeight: 300,
                              percentage: 20);

                      log("image : ${compressedFile.lengthSync()}");

                      video = File(compressedFile.path);
                      if (video!.lengthSync() / 1000000 >
                          appCtrl.usageControlsVal!.maxFileSize!) {
                        video = null;
                        snackBar(
                            "Image Should be less than ${video!.lengthSync() / 1000000 > appCtrl.usageControlsVal!.maxFileSize!}");
                      }

                      singleChatCtrl.uploadMultipleFile(
                          video!,
                          element.value.title!.contains("mp4")
                              ? MessageType.video
                              : MessageType.image);
                    });
                  } else {
                    final broadcastCtrl = Get.find<BroadcastChatController>();
                    broadcastCtrl.entities = value;
                    broadcastCtrl.entities!
                        .asMap()
                        .entries
                        .forEach((element) async {
                      File? videoFile = await element.value.file;
                      File? video;
                      if (element.value.title!.contains("mp4")) {
                        final light.LightCompressor lightCompressor =
                            light.LightCompressor();
                        final dynamic response =
                            await lightCompressor.compressVideo(
                          path: videoFile!.path,
                          videoQuality: light.VideoQuality.very_low,
                          isMinBitrateCheckEnabled: false,
                          video: light.Video(videoName: element.value.title!),
                          android: light.AndroidConfig(
                              isSharedStorage: true,
                              saveAt: light.SaveAt.Movies),
                          ios: light.IOSConfig(saveInGallery: false),
                        );

                        video = File(videoFile.path);
                        if (response is light.OnSuccess) {
                          log("videoFile!.path 1: ${getVideoSize(file: File(response.destinationPath))}}");
                          video = File(response.destinationPath);
                        }
                      } else {
                        File compressedFile =
                            await FlutterNativeImage.compressImage(
                                videoFile!.path,
                                quality: 30,
                                targetWidth: 600,
                                targetHeight: 300,
                                percentage: 20);

                        log("image : ${compressedFile.lengthSync()}");

                        video = File(compressedFile.path);
                        if (video.lengthSync() / 1000000 >
                            appCtrl.usageControlsVal!.maxFileSize!) {
                          video = null;
                          snackBar(
                              "Image Should be less than ${video!.lengthSync() / 1000000 > appCtrl.usageControlsVal!.maxFileSize!}");
                        }
                      }

                      broadcastCtrl.uploadMultipleFile(
                          video,
                          element.value.title!.contains("mp4")
                              ? MessageType.video
                              : MessageType.image);
                    });
                  }
                }
              });
            }
            Get.back();
          });
        });
  }

  //video picker option
  videoPickerOption(BuildContext context,
      {isGroup = false, isSingleChat = false}) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.r25))),
        builder: (BuildContext context) {
          // return your layout
          return ImagePickerLayout(cameraTap: () async {
            dismissKeyboard();
            await getVideo(ImageSource.camera).then((value) {
              if (isGroup) {
                final chatCtrl = Get.find<GroupChatMessageController>();
                chatCtrl.videoSend();
              } else if (isSingleChat) {
                final singleChatCtrl = Get.find<ChatController>();
                singleChatCtrl.videoSend();
              } else {
                final broadcastCtrl = Get.find<BroadcastChatController>();
                broadcastCtrl.videoSend();
              }
            });
            Get.back();
          }, galleryTap: () async {
            await getMultipleVideo().then((value) {
              if (isGroup) {
                final chatCtrl = Get.find<GroupChatMessageController>();
                chatCtrl.entities = value;
                chatCtrl.entities!.asMap().entries.forEach((element) async {
                  File? videoFile = await element.value.file;
                  File? video;
                  if (element.value.title!.contains("mp4")) {
                    final light.LightCompressor lightCompressor =
                        light.LightCompressor();
                    final dynamic response =
                        await lightCompressor.compressVideo(
                      path: videoFile!.path,
                      videoQuality: light.VideoQuality.very_low,
                      isMinBitrateCheckEnabled: false,
                      video: light.Video(videoName: element.value.title!),
                      android: light.AndroidConfig(
                          isSharedStorage: true, saveAt: light.SaveAt.Movies),
                      ios: light.IOSConfig(saveInGallery: false),
                    );

                    video = File(videoFile.path);
                    if (response is light.OnSuccess) {
                      log("videoFile!.path 1: ${getVideoSize(file: File(response.destinationPath))}}");
                      video = File(response.destinationPath);
                    }
                  }
                  chatCtrl.uploadMultipleFile(video!, MessageType.video);
                });
              } else if (isSingleChat) {
                final singleChatCtrl = Get.find<ChatController>();
                singleChatCtrl.entities = value;
                singleChatCtrl.entities!
                    .asMap()
                    .entries
                    .forEach((element) async {
                  File? videoFile = await element.value.file;

                  if (element.value.title!.contains("mp4")) {
                    final light.LightCompressor lightCompressor =
                        light.LightCompressor();
                    final dynamic response =
                        await lightCompressor.compressVideo(
                      path: videoFile!.path,
                      videoQuality: light.VideoQuality.very_low,
                      isMinBitrateCheckEnabled: false,
                      video: light.Video(videoName: element.value.title!),
                      android: light.AndroidConfig(
                          isSharedStorage: true, saveAt: light.SaveAt.Movies),
                      ios: light.IOSConfig(saveInGallery: false),
                    );

                    video = File(videoFile.path);
                    if (response is light.OnSuccess) {
                      log("videoFile!.path 1: ${getVideoSize(file: File(response.destinationPath))}}");
                      video = File(response.destinationPath);
                    }
                  }
                  singleChatCtrl.uploadMultipleFile(
                      videoFile!, MessageType.video);
                });
              } else {
                final broadcastCtrl = Get.find<BroadcastChatController>();
                broadcastCtrl.entities = value;
                broadcastCtrl.entities!
                    .asMap()
                    .entries
                    .forEach((element) async {
                  File? videoFile = await element.value.file;
                  if (element.value.title!.contains("mp4")) {
                    final light.LightCompressor lightCompressor =
                        light.LightCompressor();
                    final dynamic response =
                        await lightCompressor.compressVideo(
                      path: videoFile!.path,
                      videoQuality: light.VideoQuality.very_low,
                      isMinBitrateCheckEnabled: false,
                      video: light.Video(videoName: element.value.title!),
                      android: light.AndroidConfig(
                          isSharedStorage: true, saveAt: light.SaveAt.Movies),
                      ios: light.IOSConfig(saveInGallery: false),
                    );

                    video = File(videoFile.path);
                    if (response is light.OnSuccess) {
                      log("videoFile!.path 1: ${getVideoSize(file: File(response.destinationPath))}}");
                      video = File(response.destinationPath);
                    }
                  }
                  broadcastCtrl.uploadMultipleFile(
                      videoFile!, MessageType.video);
                });
              }
            });
            Get.back();
          });
        });
  }

  Future<String> uploadImage(File file, {String? fileNameText}) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference =
          FirebaseStorage.instance.ref().child(fileNameText ?? fileName);
      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot snap = await uploadTask;
      String downloadUrl = await snap.ref.getDownloadURL();
      imageUrl = downloadUrl;
      return imageUrl!;
    } on FirebaseException catch (e) {
      log("FIREBASE : ${e.message}");
      return "";
    }
  }
}
