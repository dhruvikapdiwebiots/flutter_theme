import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../config.dart';

class DocxLayout extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  final bool isReceiver, isGroup;
  final String? currentUserId;
  const DocxLayout({Key? key, this.document,this.onLongPress,this.isReceiver =false,this.isGroup =false,this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: () async {
        var openResult = 'Unknown';

        /*final _url = Uri.parse(document!['content'].split("-BREAK-")[1]);
        if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
          // <--
          throw Exception('Could not launch $_url');
        }*/
        var dio = Dio();
        var tempDir = await getExternalStorageDirectory();

        var filePath = tempDir!.path + document!['content'].split("-BREAK-")[0];
        final response = await dio.download(document!['content'].split("-BREAK-")[1],filePath);
        log("response : ${response.statusCode}");

        final result = await OpenFilex.open(filePath);

        openResult = "type=${result.type}  message=${result.message}";
        log("openResult : $openResult");
        OpenFilex.open(filePath);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isGroup)
            if (isReceiver)
              if (document!["sender"] != currentUserId)
                Align(
                    alignment: Alignment.topLeft,
                    child: Column(children: [
                      Text(document!['senderName'],
                          style: AppCss.poppinsMedium12
                              .textColor(appCtrl.appTheme.primary)),
                      const VSpace(Sizes.s8)
                    ])),
          Row(
            children: [
              Image.asset(imageAssets.docx, height: Sizes.s20),
              const HSpace(Sizes.s10),
              Expanded(
                child: Text(
                  document!['content'].split("-BREAK-")[0],
                  textAlign: TextAlign.start,

                  style: AppCss.poppinsMedium12.textColor(isReceiver
                      ? appCtrl.appTheme.lightBlackColor
                      : appCtrl.appTheme.whiteColor),
                ),
              ),
            ],
          )
              .width(220)
              .paddingSymmetric(horizontal: Insets.i10, vertical: Insets.i15)
              .decorated(
              color: isReceiver
                  ? appCtrl.appTheme.lightGrey1Color
                  : appCtrl.appTheme.lightPrimary,
              borderRadius: BorderRadius.circular(AppRadius.r8)),
          const VSpace(Sizes.s10),
          Text(
              DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(document!['timestamp']))),
              style: AppCss.poppinsMedium12.textColor(isReceiver
                  ? appCtrl.appTheme.lightBlackColor
                  : appCtrl.appTheme.whiteColor))
        ],
      )
          .paddingAll(Insets.i8)
          .decorated(
          color: isReceiver
              ? appCtrl.appTheme.whiteColor
              : appCtrl.appTheme.primary,
          borderRadius: BorderRadius.circular(AppRadius.r8))
          .marginSymmetric(horizontal: Insets.i10, vertical: Insets.i5),
    );
  }
}
