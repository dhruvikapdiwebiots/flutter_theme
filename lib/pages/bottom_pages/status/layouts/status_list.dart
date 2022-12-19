import '../../../../config.dart';

class StatusListLayout extends StatelessWidget {
  const StatusListLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(
      builder: (statusCtrl) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 50,
          child: FutureBuilder<List<Status>>(
              future: statusCtrl.getStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: (snapshot.data!).length,
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
                                  leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          (snapshot.data!)[index].profilePic!),
                                      radius: 30)))),
                      Divider(
                          color: appCtrl.appTheme.grey.withOpacity(.2), indent: 85),
                    ]);
                  },
                );
                return Container();
              }),
        );
      }
    );
  }
}
