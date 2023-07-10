import 'dart:developer';

//import 'package:camera/camera.dart';
import 'package:camera/camera.dart';

import '../../../config.dart';

class PickupLayout extends StatefulWidget {
  final Widget scaffold;

  const PickupLayout({
    super.key,
    required this.scaffold,
  });

  @override
  State<PickupLayout> createState() => _PickupLayoutState();
}

class _PickupLayoutState extends State<PickupLayout>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation? colorAnimation;
  CameraController? cameraController;

  Animation? sizeAnimation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    colorAnimation = ColorTween(
            begin: appCtrl.appTheme.redColor, end: appCtrl.appTheme.redColor)
        .animate(CurvedAnimation(parent: controller!, curve: Curves.bounceOut));
    sizeAnimation = Tween<double>(begin: 30.0, end: 60.0).animate(controller!);
    controller!.addListener(() async {
      setState(() {});
    });

    controller!.repeat();

    if(cameras.isNotEmpty) {
      cameraController = CameraController(cameras.length ==1 ?cameras[0] : cameras[1], ResolutionPreset.max, imageFormatGroup: ImageFormatGroup.yuv420,);
      log("cameraController : $cameraController");
      cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
            // Handle access errors here.
              break;
            default:
              // Handle other errors here.
              break;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    var user = appCtrl.storage.read(session.user);
    return user != null && user != ""
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(user["id"])
                .collection(collectionName.calling)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                Call call = Call.fromMap(snapshot.data!.docs[0].data());
                if (!call.hasDialled!) {
                  return PickupBody(
                    call: call,
                    cameraController: cameraController,
                    imageUrl: snapshot.data!.docs[0].data()["callerPic"]
                  );
                } else {}
              }
              return widget.scaffold;
            },
          )
        : widget.scaffold;
  }
}
