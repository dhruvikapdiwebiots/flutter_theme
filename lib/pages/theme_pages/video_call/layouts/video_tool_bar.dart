import '../../../../config.dart';

class VideoToolBar extends StatelessWidget {
  final String? status;
  final bool? isShowSpeaker;

  const VideoToolBar({Key? key, this.status, this.isShowSpeaker})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoCallController>(builder: (videoCtrl) {
      return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: Insets.i35),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Icon(
            videoCtrl.isSpeaker
                ? Icons.volume_mute_rounded
                : Icons.volume_off_sharp,
            color: videoCtrl.isSpeaker
                ? appCtrl.appTheme.whiteColor
                : appCtrl.appTheme.primary,
            size: Sizes.s22,
          )
              .paddingAll(Insets.i10)
              .decorated(
                  color: videoCtrl.isSpeaker
                      ? appCtrl.appTheme.primary
                      : appCtrl.appTheme.whiteColor,
                  shape: BoxShape.circle)
              .inkWell(onTap: videoCtrl.onToggleSpeaker),
          status != 'ended' && status != 'rejected'
              ? Icon(
                  videoCtrl.muted ? Icons.mic_off : Icons.mic,
                  color: appCtrl.appTheme.whiteColor,
                  size: 22.0,
                )
                  .paddingAll(Insets.i10)
                  .decorated(
                      color: videoCtrl.muted
                          ? appCtrl.appTheme.whiteColor
                          : appCtrl.appTheme.primary,
                      shape: BoxShape.circle)
                  .inkWell(onTap: videoCtrl.onToggleMute)
              : const SizedBox(height: Sizes.s42, width: Sizes.s65),
          Icon(
            status == 'ended' || status == 'rejected'
                ? Icons.close
                : Icons.call,
            color: appCtrl.appTheme.whiteColor,
            size: Sizes.s35,
          )
              .paddingAll(Insets.i15)
              .decorated(
                  color: appCtrl.appTheme.redColor, shape: BoxShape.circle)
              .inkWell(onTap: () async {
            videoCtrl.isAlreadyEndedCall =
                status == 'ended' || status == 'rejected' ? true : false;
            videoCtrl.update();
            videoCtrl.onCallEnd(Get.context!);
          }),
          status == 'ended' || status == 'rejected'
              ? const SizedBox(
                  width: Sizes.s65,
                )
              : SizedBox(
                  width: Sizes.s65,
                  child: RawMaterialButton(
                      onPressed: videoCtrl.onSwitchCamera,
                      shape: const CircleBorder(),
                      elevation: 2.0,
                      fillColor: appCtrl.appTheme.whiteColor,
                      padding: const EdgeInsets.all(Insets.i12),
                      child: Icon(Icons.switch_camera,
                          color: appCtrl.appTheme.primary, size: 20.0)))
        ]),
      );
    });
  }
}
