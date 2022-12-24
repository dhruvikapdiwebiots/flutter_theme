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
          CircleAvatar(
                  backgroundImage: NetworkImage((snapshot!.data!)
                      .docs[0]["photoUrl"][0]["image"]
                      .toString()),
                  radius: 30)
              .paddingAll(Insets.i2)
              .decorated(
                  color: (snapshot!.data!).docs[0]["isSeenByOwn"] == true
                      ? appCtrl.appTheme.grey
                      : appCtrl.appTheme.primary,
                  shape: BoxShape.circle),
          Icon(
            CupertinoIcons.add,
            color: appCtrl.appTheme.whiteColor,
            size: Sizes.s20,
          ).paddingAll(Insets.i2).decorated(
              color: appCtrl.appTheme.primary, shape: BoxShape.circle),
        ]));
  }
}
