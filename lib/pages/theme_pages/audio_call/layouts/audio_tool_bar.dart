import '../../../../config.dart';

class AudioToolBar extends StatelessWidget {
  final String? status;
  final bool? isShowSpeaker;

  const AudioToolBar({Key? key, this.status, this.isShowSpeaker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioCallController>(
      builder: (audioCtrl) {
        return Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(vertical: Insets.i35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(
                audioCtrl.isSpeaker ? Icons.volume_mute_rounded : Icons.volume_off_sharp,
                color:audioCtrl. isSpeaker
                    ? appCtrl.appTheme.whiteColor
                    : appCtrl.appTheme.primary,
                size: Sizes.s22,
              )
                  .paddingAll(Insets.i10)
                  .decorated(
                  color: audioCtrl.isSpeaker
                      ? appCtrl.appTheme.primary
                      : appCtrl.appTheme.whiteColor,
                  shape: BoxShape.circle)
                  .inkWell(onTap: audioCtrl.onToggleSpeaker),
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
                audioCtrl.isAlreadyEnded =
                status == 'ended' || status == 'rejected' ? true : false;
                audioCtrl.update();
                audioCtrl.onCallEnd(Get.context!);
              }),
              status != 'ended' && status != 'rejected'
                  ? Icon(
                audioCtrl.muted ? Icons.mic_off : Icons.mic,
                color: appCtrl.appTheme.whiteColor,
                size: 22.0,
              )
                  .paddingAll(Insets.i10)
                  .decorated(
                  color: appCtrl.appTheme.primary, shape: BoxShape.circle)
                  .inkWell(onTap: audioCtrl.onToggleMute)
                  : const SizedBox(height: 42, width: 65.67),
            ],
          ),
        );
      }
    );
  }
}
