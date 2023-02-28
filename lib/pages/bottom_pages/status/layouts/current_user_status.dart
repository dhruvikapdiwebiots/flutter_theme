import 'dart:developer';
import 'dart:io';

import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../../config.dart';
import 'package:light_compressor/light_compressor.dart' as light;

class CurrentUserStatus extends StatelessWidget {
  final String? currentUserId;
final StatusController? statusCtrl;
  const CurrentUserStatus({Key? key, this.currentUserId,this.statusCtrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('status')
            .where("phoneNumber", isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (!snapshot.data!.docs.isNotEmpty) {
              return CurrentUserEmptyStatus(onTap: () async {
                final List<AssetEntity>? result =
                await AssetPicker.pickAssets(
                  context,
                  pickerConfig: AssetPickerConfig(
                    maxAssets: 1,
                    specialPickerType: SpecialPickerType.wechatMoment,
                  ),
                );
                File? videoFile = await result![0].file;
                File? video;
                if(result[0].title!.contains("mp4")){
                  final light.LightCompressor lightCompressor = light.LightCompressor();
                  final dynamic response = await lightCompressor.compressVideo(
                    path: videoFile!.path,
                    videoQuality: light.VideoQuality.very_low,
                    isMinBitrateCheckEnabled: false,
                    video: light.Video(videoName: result[0].title!),
                    android: light.AndroidConfig(
                        isSharedStorage: true, saveAt: light.SaveAt.Movies),
                    ios: light.IOSConfig(saveInGallery: false),
                  );

                  video = File(videoFile.path);
                  if (response is light.OnSuccess) {
                    log("videoFile!.path 1: ${getVideoSize(file: File(response.destinationPath))}}");
                    video = File(response.destinationPath);
                  }
                }else{
                  File compressedFile = await FlutterNativeImage.compressImage(
                      videoFile!.path,
                      quality: 30,
                      targetWidth: 600,
                      targetHeight: 300,
                      percentage: 20);

                  log("image : ${compressedFile.lengthSync()}");

                  video = File(compressedFile.path);
                  if (video.lengthSync() / 1000000 > 60) {
                    video = null;
                    snackBar(
                        "Image Should be less than ${video!.lengthSync() / 1000000 > 60}");
                  }
                }
                statusCtrl!.addStatus(videoFile,result[0].title!.contains("mp4")? StatusType.video :StatusType.image);
              });
            } else {
              return StatusLayout(snapshot: snapshot);
            }
          } else {
            return CurrentUserEmptyStatus(onTap: () async {
              final List<AssetEntity>? result =
              await AssetPicker.pickAssets(
                context,
                pickerConfig: AssetPickerConfig(
                  maxAssets: 1,
                  specialPickerType: SpecialPickerType.wechatMoment,

                ),
              );
              File? videoFile = await result![0].file;
              statusCtrl!.addStatus(videoFile!,result[0].title!.contains("mp4")? StatusType.video :StatusType.image);
            });
          }
        });
  }
}
