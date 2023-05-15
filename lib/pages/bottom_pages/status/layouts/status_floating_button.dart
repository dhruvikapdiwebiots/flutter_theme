import 'dart:developer';
import 'dart:io';

import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../../config.dart';
import 'package:light_compressor/light_compressor.dart' as light;

class StatusFloatingButton extends StatelessWidget {
  const StatusFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(
      builder: (statusCtrl) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: Sizes.s40,
              margin: const EdgeInsets.only(bottom: Insets.i15),
              child: FloatingActionButton(
                  backgroundColor: const Color(0xff999EA6),
                  child:SvgPicture.asset(svgAssets.edit,height: Sizes.s15),
                  onPressed: () => Get.to(const TextStatus())!.then((value) {
                    log("value : $value");
                  })),
            ),
            FloatingActionButton(
              onPressed: () async{
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
                statusCtrl.addStatus(videoFile,result[0].title!.contains("mp4")? StatusType.video :StatusType.image);
              },
              backgroundColor: appCtrl.appTheme.primary,
              child: Container(
                width: Sizes.s52,
                height: Sizes.s52,
                padding: const EdgeInsets.all(Insets.i12),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      appCtrl.isTheme ? appCtrl.appTheme.primary.withOpacity(.8):  appCtrl.appTheme.lightPrimary,
                      appCtrl.appTheme.primary
                    ])),
                child: SvgPicture.asset(svgAssets.camera,height: Sizes.s15),
              ),
            ),

          ],
        );
      }
    );
  }
}
