import '../../../config.dart';

class AudioCall extends StatefulWidget {
  const AudioCall({Key? key}) : super(key: key);

  @override
  State<AudioCall> createState() => _AudioCallState();
}

class _AudioCallState extends State<AudioCall> {
  final audioCallCtrl = Get.put(AudioCallController());

  @override
  void initState() {
    super.initState();
    var data = Get.arguments;
    audioCallCtrl.channelName = data["channelName"];
    audioCallCtrl.call = data["call"];
    audioCallCtrl.userData = appCtrl.storage.read(session.user);
    setState(() {});

    audioCallCtrl.onReady();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioCallController>(builder: (context) {
      return Scaffold(
          backgroundColor: appCtrl.appTheme.whiteColor,
          body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: audioCallCtrl.stream
                as Stream<DocumentSnapshot<Map<String, dynamic>>>?,
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.data() == null || snapshot.data == null) {
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        audioCallCtrl.audioScreenForPORTRAIT(
                            status: 'calling', isPeerMuted: false),
                        audioCallCtrl.toolbar(false, 'calling'),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        // _viewRows(),
                        audioCallCtrl.audioScreenForPORTRAIT(
                            status: snapshot.data!.data()!["status"],
                            isPeerMuted: snapshot.data!.data()!["isMuted"]),

                        audioCallCtrl.toolbar(
                            snapshot.data!.data()!["status"] == 'pickedUp'
                                ? true
                                : false,
                            snapshot.data!.data()!["status"]),
                      ],
                    ),
                  );
                }
              } else if (!snapshot.hasData) {
                return Center(
                  child: Stack(
                    children: <Widget>[
                      // _viewRows(),
                      audioCallCtrl.audioScreenForPORTRAIT(
                          status: 'noNetwork', isPeerMuted: false),

                      audioCallCtrl.toolbar(false, 'noNetwork'),
                    ],
                  ),
                );
              }

              return Center(
                child: Stack(
                  children: <Widget>[
                    // _viewRows(),
                    audioCallCtrl.audioScreenForPORTRAIT(
                        status: 'calling', isPeerMuted: false),
                    audioCallCtrl.toolbar(false, 'calling'),
                  ],
                ),
              );
            },
          ));
    });
  }
}
