import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../config.dart';

class SenderImage extends StatelessWidget {
  final dynamic document;
  final VoidCallback? onPressed, onLongPress;

  const SenderImage({Key? key, this.document, this.onPressed, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        onTap: () async {
          var openResult = 'Unknown';
          var dio = Dio();
          var tempDir = await getExternalStorageDirectory();
          DateTime now = DateTime.now();
          var filePath = tempDir!.path +
              (document!['content'].contains("-BREAK-")
                  ? document!['content'].split("-BREAK-")[0]
                  : (document!['content']));
          final response = await dio.download(
              document!['content'].contains("-BREAK-")
                  ? document!['content'].split("-BREAK-")[1]
                  : document!['content'],
              filePath);
          log("response : ${response.statusCode}");

          final result = await OpenFilex.open(filePath);

          openResult = "type=${result.type}  message=${result.message}";
          log("openResult : $openResult");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: Insets.i10),
              decoration: ShapeDecoration(
                color: appCtrl.appTheme.primary,
                shape: const SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                        topLeft: SmoothRadius(
                          cornerRadius: 20,
                          cornerSmoothing: .5,
                        ),
                        topRight: SmoothRadius(
                          cornerRadius: 20,
                          cornerSmoothing: 0.4,
                        ),
                        bottomLeft: SmoothRadius(
                          cornerRadius: 20,
                          cornerSmoothing: .5,
                        ))),
              ),
              child: Material(
                borderRadius: BorderRadius.circular(AppRadius.r8),
                clipBehavior: Clip.hardEdge,
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                      width: Sizes.s160,
                      height: Sizes.s150,
                      decoration: BoxDecoration(
                        color: appCtrl.appTheme.accent,
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                      child: Container()),
                  imageUrl: document!['content'],
                  width: Sizes.s160,
                  height: Sizes.s150,
                  fit: BoxFit.cover,
                ),
              ).paddingAll(Insets.i12),
            ),
            Row(
              children: [
                Icon(Icons.done_all_outlined,
                    size: Sizes.s15,
                    color: document!['isSeen'] == true
                        ? appCtrl.appTheme.secondary
                        : appCtrl.appTheme.txtColor),
                const HSpace(Sizes.s5),
                Text(
                  DateFormat('HH:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(document!['timestamp']))),
                  style: AppCss.poppinsMedium12
                      .textColor(appCtrl.appTheme.txtColor),
                ),
              ],
            ).marginSymmetric(horizontal: Insets.i15, vertical: Insets.i10)
          ],
        ));
  }
}
