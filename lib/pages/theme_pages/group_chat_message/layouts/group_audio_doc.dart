import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../config.dart';


Future<Directory?> _getDownloadDirectory() async {
  return await getApplicationDocumentsDirectory();
}

class GroupAudioDoc extends StatelessWidget {
  final VoidCallback? onLongPress;
  final DocumentSnapshot? document;

  const GroupAudioDoc({Key? key, this.onLongPress, this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(
      builder: (chatCtrl) {
        return InkWell(
          onLongPress: onLongPress,
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: Insets.i10),
              padding: const EdgeInsets.symmetric(vertical: Insets.i10),
              decoration: BoxDecoration(
                color: appCtrl.appTheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.r15),
              ),
              width: Sizes.s250,
              height: Sizes.s130,
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ListTile(
                        isThreeLine: false,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xffE6E6E6),
                          radius: 30,
                          child: Icon(
                            Icons.people,
                            color: Color(0xffCCCCCC),
                          ),
                        ),
                        title: Text(
                          document!['content'].split("-BREAK-")[0],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                              color: appCtrl.appTheme.whiteColor),
                        ),
                      ),
                    ),

                    Text(DateFormat('HH:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document!['timestamp']))),style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.whiteColor),).marginAll(Insets.i10)
                  ],
                ),
                const VSpace(Sizes.s10),
                Divider(
                  height: 7,
                  color: appCtrl.appTheme.whiteColor.withOpacity(.2),
                ),
                // ignore: deprecated_member_use
                TextButton(
                    onPressed: () async {
                      PermissionHandlerController.checkAndRequestPermission(
                          Platform.isIOS ? Permission.storage : Permission.storage)
                          .then((res) async {
                        if(res){
                          launchUrl(Uri.parse(document!["content"].split("-BREAK-")[1]));
                        }
                      });
                    },
                    child: Text("DOWNLOAD",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: appCtrl.appTheme.whiteColor)))
              ])),
        );
      }
    );
  }
}
