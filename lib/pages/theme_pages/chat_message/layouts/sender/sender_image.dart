import 'dart:developer';

import 'package:dio/dio.dart';
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
                  : (document!['content'] + now.microsecondsSinceEpoch));
          final response = await dio.download(
              document!['content'].contains("-BREAK-")
                  ? document!['content'].split("-BREAK-")[1]
                  : document!['content'],
              filePath);
          log("response : ${response.statusCode}");

          final result = await OpenFilex.open(filePath);

          openResult = "type=${result.type}  message=${result.message}";
          log("openResult : $openResult");
          OpenFilex.open(filePath);
        },
        child: Stack(alignment: Alignment.bottomRight, children: [
          Material(
            borderRadius: BorderRadius.circular(AppRadius.r8),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                  width: Sizes.s220,
                  height: Sizes.s200,
                  decoration: BoxDecoration(
                    color: appCtrl.appTheme.accent,
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                  child: Container()),
              imageUrl: document!['content'],
              width: Sizes.s200,
              height: Sizes.s200,
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: [
              Text(
                DateFormat('HH:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document!['timestamp']))),
                style:
                    AppCss.poppinsBold12.textColor(appCtrl.appTheme.whiteColor),
              ),
              const HSpace(Sizes.s5),
              Icon(Icons.done_all_outlined,
                  size: Sizes.s15,
                  color: document!['isSeen'] == true
                      ? appCtrl.appTheme.secondary
                      : appCtrl.appTheme.white)
            ],
          )
              .marginSymmetric(horizontal: Insets.i10, vertical: Insets.i10)
              .boxShadow(
                  blurRadius: 15.0,
                  color: appCtrl.appTheme.blackColor.withOpacity(.25),
                  offset: const Offset(-2, 2))
        ])
            .paddingAll(Insets.i5)
            .decorated(
                color: appCtrl.appTheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.r8))
            .marginSymmetric(vertical: Insets.i10, horizontal: Insets.i15));
  }
}
