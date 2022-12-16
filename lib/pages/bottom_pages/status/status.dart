import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_theme/config.dart';

class StatusList extends StatefulWidget {
  const StatusList({Key? key}) : super(key: key);

  @override
  State<StatusList> createState() => _StatusListState();
}

class _StatusListState extends State<StatusList>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final statusCtrl = Get.put(StatusController());

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      appCtrl.firebaseCtrl.setIsActive();
    } else {
      appCtrl.firebaseCtrl.setLastSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (_) {
      return Scaffold(
          backgroundColor: appCtrl.appTheme.accent,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              File? pickedImage = await pickImageFromGallery(context);
              if(pickedImage != null) {
                Get.toNamed(
                    routeName.confirmationScreen, arguments: pickedImage);
              }
            },
            backgroundColor: appCtrl.appTheme.primary,
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Column(children: <Widget>[
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('status')
                      .where("uid", isEqualTo: statusCtrl.currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      print("dat :${!snapshot.data!.docs.isNotEmpty}");
                      if (!snapshot.data!.docs.isNotEmpty) {
                        print("hass :${snapshot.hasData}");
                        return Expanded(
                          child: ListTile(
                              onTap: () {
                                Status status = Status.fromMap(snapshot.data!.docs[0].data());
                                print(snapshot.data!.docs[0]);
                                Get.toNamed(routeName.statusView,
                                    arguments:status);
                              },
                              title: Text(
                                "Your status",
                              ),
                              leading:
                              Stack(alignment: Alignment.bottomRight, children: [
                                CircleAvatar(
                                    backgroundImage:  AssetImage(imageAssets.user),
                                    radius: 30),
                                Icon(CupertinoIcons.add_circled_solid,
                                    color: appCtrl.appTheme.whiteColor)
                              ])),
                        );
                      } else {

                        return ListTile(
                            onTap: ()async {
                              Status status = Status.fromMap(snapshot.data!.docs[0].data());
                              print(snapshot.data!.docs[0]);
                              Get.toNamed(routeName.statusView,
                                  arguments:status);
                              await FirebaseFirestore.instance
                                  .collection('status')
                                  .doc((snapshot.data!).docs[0].id)
                                  .update({
                                'isSeenByOwn': true,
                              });
                            },
                            title: Text(
                              (snapshot.data!).docs[0]["username"],
                            ),
                            leading:
                            Stack(alignment: Alignment.bottomRight, children: [
                              CircleAvatar(
                                  backgroundImage:  NetworkImage((snapshot.data!).docs[0]["photoUrl"][(snapshot.data!).docs[0]["photoUrl"].length -1].toString()),
                                  radius: 30).paddingAll(Insets.i2).decorated(color: (snapshot.data!).docs[0]["isSeenByOwn"] == true ? appCtrl.appTheme.grey: appCtrl.appTheme.primary,shape: BoxShape.circle),
                              Icon(CupertinoIcons.add,
                                  color: appCtrl.appTheme.whiteColor,size: Sizes.s20,).paddingAll(Insets.i2).decorated(color: appCtrl.appTheme.primary,shape: BoxShape.circle),
                            ]));
                      }
                    } else {
                      return Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  appCtrl.appTheme.primary)));
                    }
                  })
                  .decorated(color: appCtrl.appTheme.accent)
                  .marginSymmetric(vertical: Insets.i10),
              Divider().decorated(color: appCtrl.appTheme.accent),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 50,
                decoration: BoxDecoration(color: appCtrl.appTheme.accent),
                child: FutureBuilder<List<Status>>(
                    future: statusCtrl.getStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: const CircularProgressIndicator());
                      }

                      return ListView.builder(
                        itemCount: (snapshot.data!).length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  print((snapshot.data!)[index]);
                                  Get.toNamed(routeName.statusView,
                                      arguments: (snapshot.data!)[index]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, top: Insets.i10),
                                  child: ListTile(
                                    title: Text(
                                      (snapshot.data!)[index].username,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        (snapshot.data!)[index].profilePic,
                                      ),
                                      radius: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                  color: appCtrl.appTheme.grey.withOpacity(.2),
                                  indent: 85),
                            ],
                          );
                        },
                      );
                      return Container();
                    }),
              ),
            ]),
          )));
    });
  }
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
  }
  return image;
}
