import 'package:flutter_theme/pages/bottom_pages/status/layouts/stat_video.dart';
import 'package:intl/intl.dart';

import '../../../../config.dart';

class StatusListCard extends StatelessWidget {
  final Status? snapshot;
  final int? index;
  final List<Status>? status;

  const StatusListCard({Key? key, this.snapshot, this.index, this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
      return Column(children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(snapshot!.username!,
                style: AppCss.poppinsblack14.textColor(appCtrl.appTheme.txt)),
            const VSpace(Sizes.s10),
            Row(children: [
              if (DateFormat("dd/MM/yyyy").format(statusCtrl.date) ==
                  DateFormat('dd/MM/yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(snapshot!.createdAt!))))
                Text("Today, ",
                    style: AppCss.poppinsMedium12
                        .textColor(appCtrl.appTheme.grey)),
              Text(
                  "Yesterday, ${DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(snapshot!.createdAt!)))}",
                  style:
                      AppCss.poppinsMedium12.textColor(appCtrl.appTheme.grey)),
            ])
          ]),
          leading: Stack(alignment: Alignment.bottomRight, children: [
            status![index!]
                        .photoUrl![status![index!].photoUrl!.length - 1]
                        .statusType ==
                    StatusType.text.name
                ? CircleAvatar(
                    radius: AppRadius.r30,
                    backgroundColor: Color(int.parse(
                        status![index!]
                            .photoUrl![status![index!].photoUrl!.length - 1]
                            .statusBgColor!,
                        radix: 16)),
                    child: Text(
                      status![index!]
                          .photoUrl![status![index!].photoUrl!.length - 1]
                          .statusText!,
                      textAlign: TextAlign.center,
                      style: AppCss.poppinsMedium10
                          .textColor(appCtrl.appTheme.whiteColor),
                    ),
                  ).paddingAll(Insets.i2).decorated(
                    color: appCtrl.appTheme.primary, shape: BoxShape.circle)
                : status![index!]
                            .photoUrl![status![index!].photoUrl!.length - 1]
                            .statusType ==
                        StatusType.image.name
                    ? CachedNetworkImage(
                        imageUrl: status![index!]
                            .photoUrl![status![index!].photoUrl!.length - 1]
                            .image
                            .toString(),
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                              backgroundColor: appCtrl.appTheme.contactBgGray,
                              radius: AppRadius.r25,
                              backgroundImage: NetworkImage(status![index!]
                                  .photoUrl![
                                      status![index!].photoUrl!.length - 1]
                                  .image
                                  .toString()),
                            ).paddingAll(Insets.i2).decorated(
                                color: status![index!].isSeenByOwn == true
                                    ? appCtrl.appTheme.grey
                                    : appCtrl.appTheme.primary,
                                shape: BoxShape.circle),
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                            )
                                .width(Sizes.s20)
                                .height(Sizes.s20)
                                .paddingAll(Insets.i15)
                                .decorated(
                                    color:
                                        appCtrl.appTheme.grey.withOpacity(.4),
                                    shape: BoxShape.circle),
                        errorWidget: (context, url, error) => Image.asset(
                              imageAssets.user,
                              color: appCtrl.appTheme.whiteColor,
                            ).paddingAll(Insets.i15).decorated(
                                color: appCtrl.appTheme.grey.withOpacity(.4),
                                shape: BoxShape.circle))
                    : StatusVideo(snapshot: snapshot!),
          ]),
        ),
        const Divider()
      ]);
    });
  }
}
