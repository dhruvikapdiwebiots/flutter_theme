import 'dart:io';

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
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              File? pickedImage = await pickImageFromGallery(context);
              Get.toNamed(routeName.confirmationScreen, arguments: pickedImage);
            },
            backgroundColor: appCtrl.appTheme.primary,
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
              child: Stack(fit: StackFit.expand, children: <Widget>[
            SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 50,
                decoration: BoxDecoration(color: appCtrl.appTheme.accent),
                child: StreamBuilder(
                    stream: statusCtrl.generateNumbers,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
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
            ),
          ])));
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
