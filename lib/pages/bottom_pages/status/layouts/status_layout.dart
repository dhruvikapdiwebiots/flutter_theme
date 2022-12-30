import 'package:flutter/cupertino.dart';

import '../../../../config.dart';

class StatusLayout extends StatelessWidget {
  final AsyncSnapshot? snapshot;

  const StatusLayout({Key? key, this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () async {
          Status status = Status.fromJson(snapshot!.data!.docs[0].data());

          Get.toNamed(routeName.statusView, arguments: status);
          await FirebaseFirestore.instance
              .collection('status')
              .doc((snapshot!.data!).docs[0].id)
              .update({
            'isSeenByOwn': true,
          });
        },
        title: Text(
            (snapshot!.data!).docs[0]["username"]
        ),
        trailing: Icon(Icons.more_horiz,color: appCtrl.appTheme.primary,),
        leading: Stack(alignment: Alignment.bottomRight, children: [
          CachedNetworkImage(
              imageUrl:  (snapshot!.data!)
                  .docs[0]["photoUrl"][0]["image"]
                  .toString(),
              imageBuilder: (context, imageProvider) => CircleAvatar(
                backgroundColor: const Color(0xffE6E6E6),
                radius: 32,
                backgroundImage:
                NetworkImage((snapshot!.data!)
                    .docs[0]["photoUrl"][0]["image"]
                    .toString()),
              ) .paddingAll(Insets.i2)
                  .decorated(
                  color: (snapshot!.data!).docs[0]["isSeenByOwn"] == true
                      ? appCtrl.appTheme.grey
                      : appCtrl.appTheme.primary,
                  shape: BoxShape.circle),
              placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2,).width(Sizes.s20).height(Sizes.s20).paddingAll(Insets.i15).decorated(
                  color: appCtrl.appTheme.grey.withOpacity(.4),
                  shape: BoxShape.circle),
              errorWidget: (context, url, error) => Image.asset(
                imageAssets.user,
                color: appCtrl.appTheme.whiteColor,
              ).paddingAll(Insets.i15).decorated(
                  color: appCtrl.appTheme.grey.withOpacity(.4),
                  shape: BoxShape.circle)),
          Icon(
            CupertinoIcons.add_circled_solid,
            color: appCtrl.appTheme.primary,

          ).decorated(
              color: appCtrl.appTheme.whiteColor, shape: BoxShape.circle),
        ]));
  }
}
