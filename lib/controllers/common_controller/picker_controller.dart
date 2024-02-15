import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:flutter_theme/config.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:light_compressor/light_compressor.dart' as light;
import 'package:video_compress_plus/video_compress_plus.dart';

class PickerController extends GetxController {
  XFile? imageFile;
  XFile? videoFile;
  File? image;
  File? video;
  String? imageUrl;
  String? audioUrl;
  List<File> selectedImages = [];


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
        var result = await FlutterImageCompress.compressWithFile(
          croppedFile.path,
          quality: 94,
        );

        log("image : ${result}");

        image = File(croppedFile.path);
        if (result!.length / 1000000 >
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['jpg', 'png', 'jpeg',],
    );

    log("resultresult: $result");
    if (result != null) {
      for (var i = 0; i < result.files.length; i++) {
        selectedImages.add(File(result.files[i].path!));
      }
      return selectedImages;
    } else {
      // If no image is selected it will show a
      // snackbar saying nothing is selected
      ScaffoldMessenger.of(Get.context!)
          .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
    }
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['mp4'],
    );

    log("resultresult: $result");
    if (result != null) {
      for (var i = 0; i < result.files.length; i++) {
        selectedImages.add(File(result.files[i].path!));
      }
      return selectedImages;
    } else {
      // If no image is selected it will show a
      // snackbar saying nothing is selected
      ScaffoldMessenger.of(Get.context!)
          .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
    }
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
                    chatCtrl.selectedImages = value;
                    chatCtrl.isLoading = true;
                    chatCtrl.update();
                    chatCtrl.selectedImages.asMap().entries.forEach((element) async {
                      File? videoFile =  element.value;
                      File? video;
                      if (element.value.name.contains("mp4")) {
                        final light.LightCompressor lightCompressor =
                        light.LightCompressor();
                        final dynamic response =
                        await lightCompressor.compressVideo(
                          path: videoFile.path,
                          videoQuality: light.VideoQuality.very_low,
                          isMinBitrateCheckEnabled: false,
                          video: light.Video(videoName: element.value.name),
                          android: light.AndroidConfig(
                              isSharedStorage: true, saveAt: light.SaveAt.Movies),
                          ios: light.IOSConfig(saveInGallery: false),
                        );

                        video = File(videoFile.path);
                        if (response is light.OnSuccess) {
                          log("videoFile!.path 1: ${getVideoSize(
                              file: File(response.destinationPath))}}");
                          video = File(response.destinationPath);
                        }
                      } else {
                        image = File(videoFile.path);
                        if (image!.lengthSync() / 1000000 > appCtrl.usageControlsVal!.maxFileSize!) {
                          video = null;
                          snackBar(
                              "Image Should be less than ${video!.lengthSync() /
                                  1000000 > appCtrl.usageControlsVal!.maxFileSize!}");
                        }
                      }

                      chatCtrl.uploadMultipleFile(videoFile,element.value.name.contains("mp4") ? MessageType.video : MessageType.image);
                      selectedImages = [];
                      update();
                    });
                  } else if (isSingleChat) {
                    final singleChatCtrl = Get.find<ChatController>();
                    singleChatCtrl.selectedImages = value;

                    if(singleChatCtrl.selectedImages.length >=4){
                      log("HHH");
                      singleChatCtrl.selectedImages
                          .asMap()
                          .entries
                          .forEach((element) async {
                        File? videoFile = element.value;
                        singleChatCtrl.isLoading = true;
                        singleChatCtrl.update();
                        video = File(videoFile.path);
                        if (video!.lengthSync() / 1000000 >
                            appCtrl.usageControlsVal!.maxFileSize!) {
                          video = null;
                          singleChatCtrl.isLoading = false;
                          singleChatCtrl.update();
                          snackBar(
                              "Image Should be less than ${video!.lengthSync() /
                                  1000000 >
                                  appCtrl.usageControlsVal!.maxFileSize!}");
                        }

                        singleChatCtrl.uploadMultipleImage(
                            video!);
                      });
log("INNG :${singleChatCtrl.imageList}");
                      singleChatCtrl.onSendMessage(jsonEncode(singleChatCtrl.imageList), MessageType.imageArray);
                    }else {
                      singleChatCtrl.selectedImages
                          .asMap()
                          .entries
                          .forEach((element) async {
                        File? videoFile = element.value;
                        singleChatCtrl.isLoading = true;
                        singleChatCtrl.update();
                        video = File(videoFile.path);
                        if (video!.lengthSync() / 1000000 >
                            appCtrl.usageControlsVal!.maxFileSize!) {
                          video = null;
                          singleChatCtrl.isLoading = false;
                          singleChatCtrl.update();
                          snackBar(
                              "Image Should be less than ${video!.lengthSync() /
                                  1000000 >
                                  appCtrl.usageControlsVal!.maxFileSize!}");
                        }

                        singleChatCtrl.uploadMultipleFile(
                            video!,
                            element.value.name.contains("mp4")
                                ? MessageType.video
                                : MessageType.image);
                      });
                    }
                    selectedImages = [];
                    update();
                  } else {
                    final broadcastCtrl = Get.find<BroadcastChatController>();
                    broadcastCtrl.selectedImages = value;
                    broadcastCtrl.selectedImages.asMap().entries.forEach((
                        element) async {
                      File? videoFile =  element.value;
                      File? video;
                      if (element.value.name.contains("mp4")) {
                        final light.LightCompressor lightCompressor =
                        light.LightCompressor();
                        final dynamic response =
                        await lightCompressor.compressVideo(
                          path: videoFile.path,
                          videoQuality: light.VideoQuality.very_low,
                          isMinBitrateCheckEnabled: false,
                          video: light.Video(videoName: element.value.name),
                          android: light.AndroidConfig(
                              isSharedStorage: true, saveAt: light.SaveAt.Movies),
                          ios: light.IOSConfig(saveInGallery: false),
                        );

                        video = File(videoFile!.path);
                        if (response is light.OnSuccess) {
                          log("videoFile!.path 1: ${getVideoSize(
                              file: File(response.destinationPath))}}");
                          video = File(response.destinationPath);
                        }
                      } else {

                        image = File(videoFile.path);
                        if (image!.lengthSync() / 1000000 > appCtrl.usageControlsVal!.maxFileSize!) {
                          video = null;
                          snackBar(
                              "Image Should be less than ${image!.lengthSync() /
                                  1000000 > appCtrl.usageControlsVal!.maxFileSize!}");
                          broadcastCtrl.uploadMultipleFile(image!,element.value.name.contains("mp4") ? MessageType.video : MessageType.image);
                          selectedImages = [];
                          update();
                        }else{

                          selectedImages = [];
                          update();
                        }
                      }


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
                chatCtrl.selectedImages = value;
                chatCtrl.selectedImages.asMap().entries.forEach((
                    element) async {
                  File? videoFile =  element.value;
                  File? video;
                  log("VIDEO FILE $videoFile");
                  if (element.value.name.contains("mp4")) {
                    final info = await VideoCompress.compressVideo(
                      videoFile.path,
                      quality: VideoQuality.MediumQuality,
                      deleteOrigin: false,
                      includeAudio: true,
                    );
                    video = File(info!.path!);
                  }
                  chatCtrl.uploadMultipleFile(video!, MessageType.video);
                  selectedImages = [];
                  update();
                });
              } else if (isSingleChat) {
                final singleChatCtrl = Get.find<ChatController>();
                singleChatCtrl.selectedImages = value;
                singleChatCtrl.selectedImages
                    .asMap()
                    .entries
                    .forEach((element) async {
                  File? videoFile =  element.value;

                  appCtrl.isLoading = true;
                  appCtrl.update();


                  if (element.value.name.contains("mp4")) {
                    final info = await VideoCompress.compressVideo(
                      videoFile.path,
                      quality: VideoQuality.MediumQuality,
                      deleteOrigin: false,
                      includeAudio: true,
                    );
                    video = File(info!.path!);
                  }
                  appCtrl.isLoading = false;
                  appCtrl.update();
                  singleChatCtrl.uploadMultipleFile(
                      videoFile, MessageType.video);
                });
                selectedImages = [];
                update();
                Get.back();
              } else {
                final broadcastCtrl = Get.find<BroadcastChatController>();
                broadcastCtrl.selectedImages = value;
                broadcastCtrl.selectedImages.asMap().entries.forEach((
                    element) async {
                  File? videoFile = element.value;
                  if (element.value.name.contains("mp4")) {
                    final info = await VideoCompress.compressVideo(
                      videoFile.path,
                      quality: VideoQuality.MediumQuality,
                      deleteOrigin: false,
                      includeAudio: true,
                    );
                    video = File(info!.path!);
                  }
                  broadcastCtrl.uploadMultipleFile(videoFile, MessageType.video);
                  selectedImages = [];
                  update();
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
