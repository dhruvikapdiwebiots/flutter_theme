
import '../../../../config.dart';

class CallView extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>? snapshot;
  final int? index;
  final String? userId;

  const CallView({Key? key, this.snapshot, this.index, this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallListController>(
        builder: (callList) {
        return Column(children: [
          ListTile(
              dense: true,
              horizontalTitleGap: 12,
              onTap: ()async{
                if(snapshot!.data!.docs[index!].data()["isVideoCall"]){
                  await callList.permissionHandelCtrl
                      .getCameraMicrophonePermissions()
                      .then((value) {

                    if (value == true) {

                      callList.audioVideoCallTap(true,snapshot!.data!
                          .docs[index!].data());
                    }
                  });
                }else {
                  await callList.permissionHandelCtrl
                      .getCameraMicrophonePermissions()
                      .then((value) {
                    if (value == true) {
                      callList.audioVideoCallTap(false, snapshot!.data!
                          .docs[index!].data());
                    }
                  });
                }
              },
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: Insets.i15, vertical: Insets.i4),
              leading: ImageLayout(
                  isLastSeen: false,
                  id: snapshot!.data!.docs[index!].data()["id"] == userId
                      ? snapshot!.data!.docs[index!].data()["receiverId"]
                      : snapshot!.data!.docs[index!].data()["id"]),
              title: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where("id",
                          isEqualTo: snapshot!.data!.docs[index!].data()["id"] ==
                                  userId
                              ? snapshot!.data!.docs[index!].data()["receiverId"]
                              : snapshot!.data!.docs[index!].data()["id"])
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.hasData) {
                      if (snapshot!.data != null) {
                        return Text(
                            userSnapshot.data!.docs.isEmpty ? "C":    userSnapshot.data!.docs[0].data()["name"],
                          style: AppCss.poppinsSemiBold14
                              .textColor(appCtrl.appTheme.blackColor),
                        );
                      } else {
                        return Container();
                      }
                    } else {
                      return Container();
                    }
                  }),
              subtitle: CallIcon(snapshot: snapshot, index: index),
              trailing: SvgPicture.asset(
                  snapshot!.data!.docs[index!].data()["isVideoCall"]
                      ? svgAssets.videoCallFilled
                      : svgAssets.callFilled,
                  color: appCtrl.appTheme.primary)),
          const Divider(
              color: Color.fromRGBO(49, 100, 189, .1),
              endIndent: Insets.i15,
              indent: Insets.i15,
              height: 1,
              thickness: 1)
        ]);
      }
    );
  }
}
