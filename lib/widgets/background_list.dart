

import '../../../../config.dart';

class BackgroundList extends StatefulWidget {
  const BackgroundList({Key? key}) : super(key: key);

  @override
  State<BackgroundList> createState() => _BackgroundListState();
}

class _BackgroundListState extends State<BackgroundList> {
  String? chatId, groupId, broadcastId;

  @override
  void initState() {
    // TODO: implement initState
    var data = Get.arguments;
    if (data["chatId"] != null) {
      chatId = data["chatId"];
    }
    if (data["groupId"] != null) {
      groupId = data["groupId"];
    }
    if (data["broadcastId"] != null) {
      broadcastId = data["broadcastId"];
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCtrl.appTheme.bgColor,
      appBar: CommonAppBar(text: fonts.defaultWallpaper.tr),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(svgAssets.gallery),
                const HSpace(Sizes.s10),
                Text(fonts.setDefaultBackground.tr,
                        style: AppCss.poppinsSemiBold16
                            .textColor(appCtrl.appTheme.blackColor))
                    .inkWell(onTap: () async {
                  if (chatId != null) {
                    dynamic userData = appCtrl.storage.read(session.user);
                    await FirebaseFirestore.instance
                        .collection(collectionName.users)
                        .doc(userData["id"])
                        .collection(collectionName.chats)
                        .where("chatId",
                        isEqualTo: chatId)
                        .limit(1)
                        .get()
                        .then((userChat) {
                      if(userChat.docs.isNotEmpty) {
                        FirebaseFirestore.instance
                            .collection(
                            collectionName.users)
                            .doc(userData["id"])
                            .collection(
                            collectionName.chats)
                            .doc(userChat.docs[0].id)
                            .update(
                            {
                              'backgroundImage': ""
                            });
                      }
                    });
                  }
                  if (groupId != null) {
                    await FirebaseFirestore.instance
                        .collection(collectionName.groups)
                        .doc(groupId)
                        .update({'backgroundImage': ""});
                  }
                  if (broadcastId != null) {
                    await FirebaseFirestore.instance
                        .collection(collectionName.broadcast)
                        .doc(broadcastId)
                        .update({'backgroundImage': ""});
                  }
                  Get.back();
                }),
              ],
            ).marginSymmetric(horizontal: Insets.i15),

            const VSpace(Sizes.s20),
            Row(
              children: [
                Icon(Icons.delete_forever,color: appCtrl.appTheme.redColor,),
                const HSpace(Sizes.s10),
                Text(fonts.removeWallpaper.tr,
                    style: AppCss.poppinsSemiBold16
                        .textColor(appCtrl.appTheme.redColor))
                    .inkWell(onTap: () async {
                  if (chatId != null) {
                    dynamic userData = appCtrl.storage.read(session.user);
                    await FirebaseFirestore.instance
                        .collection(collectionName.users)
                        .doc(userData["id"])
                        .collection(collectionName.chats)
                        .where("chatId",
                        isEqualTo: chatId)
                        .limit(1)
                        .get()
                        .then((userChat) {
                      if(userChat.docs.isNotEmpty) {
                        FirebaseFirestore.instance
                            .collection(
                            collectionName.users)
                            .doc(userData["id"])
                            .collection(
                            collectionName.chats)
                            .doc(userChat.docs[0].id)
                            .update(
                            {
                              'backgroundImage': ""
                            });
                      }
                    });
                  }
                  if (groupId != null) {
                    await FirebaseFirestore.instance
                        .collection(collectionName.groups)
                        .doc(groupId)
                        .update({'backgroundImage': ""});
                  }
                  if (broadcastId != null) {
                    await FirebaseFirestore.instance
                        .collection(collectionName.broadcast)
                        .doc(broadcastId)
                        .update({'backgroundImage': ""});

                  }
                  Get.back();
                }),
              ],
            ).marginSymmetric(horizontal: Insets.i15),
            const VSpace(Sizes.s20),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(collectionName.wallpaper)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(Insets.i20),
                      itemCount: snapshot.data!.docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 20,
                              mainAxisExtent: 216,
                              mainAxisSpacing: 20.0,
                              crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        return Container(
                          width: MediaQuery.of(context).size.width,

                          //color: Colors.black.withOpacity(0.4), colorBlendMode: BlendMode.darken,
                          height: Sizes.s210,
                          decoration: BoxDecoration(
                              color: appCtrl.appTheme.bgColor,
                              boxShadow: const [
                                BoxShadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                    color: Color.fromRGBO(0, 0, 0, 0.08))
                              ],
                              borderRadius: BorderRadius.circular(AppRadius.r10),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      snapshot.data!.docs[index]["image"]!))),
                        ).inkWell(
                            onTap: () => Get.back(
                                result: snapshot.data!.docs[index]["image"]));
                      },
                    );
                  } else {
                    return Container();
                  }
                }),
          ],
        ),
      ),
    );
  }
}
