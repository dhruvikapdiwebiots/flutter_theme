import 'package:flutter_theme/pages/bottom_pages/status/layouts/status_list_card.dart';

import '../../../../config.dart';

class SponsorStatus extends StatelessWidget {
  const SponsorStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Sizes.s110,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(
              collectionName.adminStatus)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container();
            } else if (!snapshot.hasData) {
              return Container();
            } else {
              Status status = Status.fromJson(
                  snapshot.data!.docs[0].data());

              return SizedBox(
                  height: Sizes.s110,
                  child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Sponsor Status",
                                style: AppCss
                                    .poppinsblack16
                                    .textColor(appCtrl
                                    .appTheme
                                    .txtColor)),
                            const HSpace(Sizes.s12),
                            Expanded(
                                child: Divider(
                                  color: appCtrl
                                      .appTheme.primary
                                      .withOpacity(.2),
                                  thickness: 1,
                                ))
                          ],
                        ).paddingSymmetric(
                            horizontal: Insets.i12),
                        const VSpace(Sizes.s10),
                        InkWell(
                            onTap: () {
                              Get.toNamed(
                                  routeName
                                      .statusView,
                                  arguments:
                                  status);
                            },
                            child: StatusListCard(
                                isUserStatus: false,
                                snapshot: status))
                      ]));
            }
          }),
    );
  }
}
