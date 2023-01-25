import '../../../../config.dart';

class AudioPortrait extends StatelessWidget {
final  String? status;
     final bool? isPeerMuted;
  const AudioPortrait({Key? key,this.status,this.isPeerMuted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return GetBuilder<AudioCallController>(builder: (audioCtrl) {
      return Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SizedBox(height: h / 35),
                const VSpace(Sizes.s50),
                audioCtrl.call!.receiverPic != null
                    ? SizedBox(
                  height: Sizes.s100,
                  child: CachedNetworkImage(
                      imageUrl: audioCtrl.call!.receiverPic!,
                      imageBuilder: (context, imageProvider) =>
                          CircleAvatar(
                            backgroundColor: const Color(0xffE6E6E6),
                            radius: Sizes.s50,
                            backgroundImage:
                            NetworkImage(audioCtrl.call!.receiverPic!),
                          ),
                      placeholder: (context, url) => Image.asset(
                          imageAssets.user,
                          color: appCtrl.appTheme.contactBgGray)
                          .paddingAll(Insets.i15)
                          .decorated(
                          color:
                          appCtrl.appTheme.grey.withOpacity(.4),
                          shape: BoxShape.circle),
                      errorWidget: (context, url, error) => Image.asset(
                        imageAssets.user,
                        color: appCtrl.appTheme.whiteColor,
                      ).paddingAll(Insets.i15).decorated(
                          color:
                          appCtrl.appTheme.grey.withOpacity(.4),
                          shape: BoxShape.circle)),
                )
                    : SizedBox(
                  height: Sizes.s100,
                  child: Image.asset(
                    imageAssets.user,
                    color: appCtrl.appTheme.whiteColor,
                  ).paddingAll(Insets.i15).decorated(
                      color: appCtrl.appTheme.grey.withOpacity(.4),
                      shape: BoxShape.circle),
                ),

                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 7),
                  SizedBox(
                      width: w / 1.1,
                      child: Text(
                          audioCtrl.call!.callerId == audioCtrl.userData["id"]
                              ? audioCtrl.call!.receiverName!
                              : audioCtrl.call!.callerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppCss.poppinsblack28
                              .textColor(appCtrl.appTheme.blackColor)))
                ]),
                // SizedBox(height: h / 25),
                const VSpace(Sizes.s20),
                status == 'pickedUp'
                    ? Text(
                  "${audioCtrl.hoursStr}:${audioCtrl.minutesStr}:${audioCtrl.secondsStr}",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: appCtrl.appTheme.greenColor.withOpacity(.3),
                      fontWeight: FontWeight.w600),
                )
                    : Text(
                    status == 'pickedUp'
                        ? fonts.picked.tr
                        : status == 'noNetwork'
                        ? fonts.connecting.tr
                        : status == 'ringing' || status == 'missedCall'
                        ? fonts.calling.tr
                        : status == 'calling'
                        ? audioCtrl.call!.receiverId == audioCtrl.userData["id"]
                        ? fonts.connecting.tr
                        : fonts.calling.tr
                        : status == 'pickedUp'
                        ? fonts.onCall.tr
                        : status == 'ended'
                        ? fonts.callEnded.tr
                        : status == 'rejected'
                        ? fonts.callRejected.tr
                        : fonts.plsWait.tr,
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.blackColor)),
                const SizedBox(height: 16),
              ],
            ).marginSymmetric(vertical: Insets.i15),
          ],
        ),
      );
    });
  }
}
