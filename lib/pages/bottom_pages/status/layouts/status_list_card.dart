import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_theme/pages/bottom_pages/status/layouts/stat_video.dart';
import 'package:intl/intl.dart';

import '../../../../config.dart';

double radius = 27.0;

double colorWidth(double radius, int statusCount, double separation) {
  return ((2 * pi * radius) - (statusCount * separation)) / statusCount;
}

double separation(int statusCount) {
  if (statusCount <= 20)
    return 3.0;
  else if (statusCount <= 30)
    return 1.8;
  else if (statusCount <= 60)
    return 1.0;
  else
    return 0.3;
}

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
          horizontalTitleGap: 10,
          contentPadding: const EdgeInsets.symmetric(horizontal: Insets.i15),
          subtitle: Row(children: [
            Text(
                DateFormat("dd/MM/yyyy").format(statusCtrl.date) ==
                        DateFormat('dd/MM/yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(snapshot!.createdAt!)))
                    ? fonts.today.tr
                    : fonts.yesterday.tr,
                style: AppCss.poppinsMedium12
                    .textColor(appCtrl.appTheme.txtColor)),
            Text(
                DateFormat('HH:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(snapshot!.createdAt!))),
                style: AppCss.poppinsMedium12
                    .textColor(appCtrl.appTheme.txtColor)),
          ]),
          title: Text(snapshot!.username!,
              style: AppCss.poppinsblack14.textColor(appCtrl.appTheme.txt)),
          leading: DottedBorder(
            color: appCtrl.appTheme.primary,
            padding: const EdgeInsets.all(Insets.i2),
            borderType: BorderType.RRect,
            strokeCap: StrokeCap.round,
            radius: const SmoothRadius(
              cornerRadius: 15,
              cornerSmoothing: 1,
            ),
            dashPattern: snapshot!.photoUrl!.length == 1
                ? [
                    //one status
                    (2 * pi * (radius + 2)),
                    0,
                  ]
                : [
                    //multiple status
                    colorWidth(radius + 2, snapshot!.photoUrl!.length,
                        separation(snapshot!.photoUrl!.length)),
                    separation(snapshot!.photoUrl!.length),
                  ],
            strokeWidth: 1,
            child: Stack(alignment: Alignment.bottomRight, children: [
              snapshot!.photoUrl![snapshot!.photoUrl!.length - 1].statusType ==
                      StatusType.text.name
                  ? Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: Insets.i4),
                      height: Sizes.s50,
                      width: Sizes.s50,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                          color: Color(int.parse(
                              snapshot!
                                  .photoUrl![snapshot!.photoUrl!.length - 1]
                                  .statusBgColor!,
                              radix: 16)),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 12, cornerSmoothing: 1),
                          )),
                      child: Text(
                        snapshot!.photoUrl![snapshot!.photoUrl!.length - 1]
                            .statusText!,
                        textAlign: TextAlign.center,
                        style: AppCss.poppinsMedium10
                            .textColor(appCtrl.appTheme.whiteColor),
                      ),
                    )
                  : snapshot!.photoUrl![snapshot!.photoUrl!.length - 1]
                              .statusType ==
                          StatusType.image.name
                      ? CommonImage(
                          height: Sizes.s50,
                          width: Sizes.s50,
                          image: snapshot!
                              .photoUrl![snapshot!.photoUrl!.length - 1].image
                              .toString(),
                          name: snapshot!.username,
                        )
                      : StatusVideo(snapshot: snapshot!),
            ]),
          ),
        )
      ]);
    });
  }
}
