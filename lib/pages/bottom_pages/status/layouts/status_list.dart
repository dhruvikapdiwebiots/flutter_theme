
import 'package:flutter_theme/pages/bottom_pages/status/layouts/status_list_card.dart';

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
              List<Status> status = (snapshot.data) ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if ((snapshot.data) == null) {
                return Container();
              } else {
                return ListView.builder(
                  itemCount: status.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Get.toNamed(routeName.statusView,
                            arguments: (snapshot.data!)[index]);
                      },
                      child: StatusListCard(index: index,snapshot: snapshot,status: status),
                    );
                  },
                );
              }
            }),
      );
    });
  }
}
