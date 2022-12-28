import '../../../../config.dart';

class StatusListLayout extends StatelessWidget {
  const StatusListLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 50,
        child: FutureBuilder(
            future: statusCtrl.getStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if ((snapshot.data == null)) {
                return  Container();
              }else{
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
                                 leading: CachedNetworkImage(
                                     imageUrl:   (snapshot.data!)[index].photoUrl[0].image.toString(),
                                     imageBuilder: (context, imageProvider) => CircleAvatar(
                                       backgroundColor: const Color(0xffE6E6E6),
                                       radius: 32,
                                       backgroundImage:
                                       NetworkImage((snapshot.data!)[index].photoUrl[0].image.toString()),
                                     ),
                                     placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2,).width(Sizes.s20).height(Sizes.s20).paddingAll(Insets.i15).decorated(
                                         color: appCtrl.appTheme.grey.withOpacity(.4),
                                         shape: BoxShape.circle),
                                     errorWidget: (context, url, error) => Image.asset(
                                       imageAssets.user,
                                       color: appCtrl.appTheme.whiteColor,
                                     ).paddingAll(Insets.i15).decorated(
                                         color: appCtrl.appTheme.grey.withOpacity(.4),
                                         shape: BoxShape.circle)),))),
                   
                    ]);
                  },
                );
              }

            }),
      );
    });
  }
}