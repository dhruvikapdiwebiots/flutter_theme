import 'dart:developer';

import 'package:flutter_theme/pages/bottom_pages/status/layouts/stat_video.dart';
import 'package:video_player/video_player.dart';

import '../../../../config.dart';

class StatusListLayout extends StatefulWidget {
  const StatusListLayout({Key? key}) : super(key: key);

  @override
  State<StatusListLayout> createState() => _StatusListLayoutState();
}

class _StatusListLayoutState extends State<StatusListLayout> {


  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 50,
        child: FutureBuilder(
            future: statusCtrl.getStatus(),
            builder: (context, snapshot) {
log("(snapshot.data) ${(snapshot.data) == null}");
              List<Status> status = (snapshot.data) ?? [];

              log("status : ${status.length}");
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if ((snapshot.data) == null) {
                return  Container();
              }else{
                return ListView.builder(
                  itemCount: status.length,
                  itemBuilder: (context, index) {
                    return Column(children: [
                      InkWell(
                          onTap: () {
                            Get.toNamed(routeName.statusView,
                                arguments: (snapshot.data!)[index]);
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 8.0, top: Insets.i10),
                              child: ListTile(
                                  title: Text(
                                    (snapshot.data!)[index].username!,
                                  ),
                                 leading:  Stack(alignment: Alignment.bottomRight, children: [
                                   status[0].photoUrl!
                                   [status[0].photoUrl!.length-1]
                                  .statusType ==
                                       StatusType.text.name
                                       ? CircleAvatar(
                                     radius: AppRadius.r30,
                                     backgroundColor: Color(int.parse(
                                         status[0].photoUrl!
                                         [status[0].photoUrl!.length - 1].statusBgColor!,
                                         radix: 16)),
                                     child: Text(
                                       status[0].photoUrl!
                                       [status[0].photoUrl!.length - 1].statusText!,
                                       style: AppCss.poppinsMedium12
                                           .textColor(appCtrl.appTheme.whiteColor),
                                     ),
                                   ).paddingAll(Insets.i2).decorated(
                                       color: status[0].isSeenByOwn ==
                                           true
                                           ? appCtrl.appTheme.grey
                                           : appCtrl.appTheme.primary,
                                       shape: BoxShape.circle)
                                       : status[0].photoUrl!
                                   [status[0].photoUrl!.length - 1].statusType ==
                                       StatusType.image.name ? CachedNetworkImage(
                                       imageUrl:status[0].photoUrl![status[0].photoUrl!.length - 1].image
                                           .toString(),
                                       imageBuilder: (context, imageProvider) =>
                                           CircleAvatar(
                                             backgroundColor: const Color(0xffE6E6E6),
                                             radius: 32,
                                             backgroundImage: NetworkImage(status[0].photoUrl![
                                             status[0].photoUrl!.length -
                                                 1].image
                                                 .toString()),
                                           ).paddingAll(Insets.i2).decorated(
                                               color: status[0].isSeenByOwn ==
                                                   true
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
                                               color: appCtrl.appTheme.grey.withOpacity(.4),
                                               shape: BoxShape.circle),
                                       errorWidget: (context, url, error) =>
                                           Image.asset(
                                             imageAssets.user,
                                             color: appCtrl.appTheme.whiteColor,
                                           ).paddingAll(Insets.i15).decorated(
                                               color: appCtrl.appTheme.grey.withOpacity(.4),
                                               shape: BoxShape.circle)) : StatusVideo(snapshot: status[0]),
                                 ]),))),

                    ]);
                  },
                );
              }

            }),
      );
    });
  }
}