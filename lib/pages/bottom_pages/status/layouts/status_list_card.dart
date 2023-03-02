import 'dart:math';

import 'package:figma_squircle/figma_squircle.dart';
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
          leading: Stack(
            children: [
              CustomPaint(painter: DottedBorder(
                numberOfStories: snapshot!.photoUrl!.length,
                spaceLength: 2,
              ),),
              Stack(alignment: Alignment.bottomRight, children: [
                status![index!]
                            .photoUrl![status![index!].photoUrl!.length - 1]
                            .statusType ==
                        StatusType.text.name
                    ? Container(
                        decoration: ShapeDecoration(
                            color: Color(int.parse(
                                status![index!]
                                    .photoUrl![
                                        status![index!].photoUrl!.length - 1]
                                    .statusBgColor!,
                                radix: 16)),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                  cornerRadius: 12, cornerSmoothing: 1),
                            )),
                        child: Text(
                          snapshot!
                              .photoUrl![status![index!].photoUrl!.length - 1]
                              .statusText!,
                          textAlign: TextAlign.center,
                          style: AppCss.poppinsMedium10
                              .textColor(appCtrl.appTheme.whiteColor),
                        ),
                      ).paddingAll(Insets.i2).decorated(
                        color: appCtrl.appTheme.primary, shape: BoxShape.circle)
                    : snapshot!.photoUrl![status![index!].photoUrl!.length - 1]
                                .statusType ==
                            StatusType.image.name
                        ? CommonImage(
                            isStatusPage: true,
                            image: snapshot!
                                .photoUrl![status![index!].photoUrl!.length - 1]
                                .image
                                .toString(),
                            name: snapshot!.username,
                          )
                        : StatusVideo(snapshot: snapshot!),
              ]),
            ],
          ),
        ),
        const Divider()
      ]);
    });
  }
}

class DottedBorder extends CustomPainter {
  //number of stories
  final int numberOfStories;

  //length of the space arc (empty one)
  final int spaceLength;

  //start of the arc painting in degree(0-360)
  double startOfArcInDegree = 0;

  DottedBorder({required this.numberOfStories, this.spaceLength = 10});

  //drawArc deals with rads, easier for me to use degrees
  //so this takes a degree and change it to rad
  double inRads(double degree) {
    return (degree * pi) / 180;
  }

  @override
  bool shouldRepaint(DottedBorder oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //circle angle is 360, remove all space arcs between the main story arc (the number of spaces(stories) times the  space length
    //then subtract the number from 360 to get ALL arcs length
    //then divide the ALL arcs length by number of Arc (number of stories) to get the exact length of one arc
    double arcLength =
        (360 - (numberOfStories * spaceLength)) / numberOfStories;

    //be careful here when arc is a negative number
    //that happens when the number of spaces is more than 360
    //feel free to use what logic you want to take care of that
    //note that numberOfStories should be limited too here
    if (arcLength <= 0) {
      arcLength = 360 / spaceLength - 1;
    }

    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    //looping for number of stories to draw every story arc
    for (int i = 0; i < numberOfStories; i++) {
      //printing the arc
      canvas.drawArc(
          rect,
          inRads(startOfArcInDegree),
          //be careful here is:  "double sweepAngle", not "end"
          inRads(arcLength),
          false,
          Paint()
            //here you can compare your SEEN story index with the arc index to make it grey
            ..color = i == 0 || i == 1 ? appCtrl.appTheme.txtColor : appCtrl.appTheme.primary
            ..strokeWidth = 14.0
            ..style = PaintingStyle.stroke);

      //the logic of spaces between the arcs is to start the next arc after jumping the length of space
      startOfArcInDegree += arcLength + spaceLength;
    }
  }
}
