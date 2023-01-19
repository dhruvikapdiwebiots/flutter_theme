



import '../../../config.dart';

class AudioCall extends StatelessWidget {
  final audioCallCtrl = Get.put(AudioCallController());
   AudioCall({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioCallController>(
      builder: (context) {
        return Scaffold(
            backgroundColor:appCtrl.appTheme.primary,
            body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream:
              audioCallCtrl.stream as Stream<DocumentSnapshot<Map<String, dynamic>>>?,
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.data() == null ||
                      snapshot.data == null) {

                    return Center(
                      child: Stack(
                        children: <Widget>[
                          audioCallCtrl.audioScreenForPORTRAIT(
                              context: context,
                              status: 'calling',
                              isPeerMuted: false),

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
                              context: context,
                              status: snapshot.data!.data()!["STATUS"],
                              isPeerMuted: snapshot.data!.data()!["ISMUTED"]),

                          audioCallCtrl.toolbar(
                              snapshot.data!.data()!["STATUS"] == 'pickedup'
                                  ? true
                                  : false,
                              snapshot.data!.data()!["STATUS"]),
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
                            context: context,
                            status: 'noNetwork',
                            isPeerMuted: false),

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
                          context: context,
                          status: 'calling',
                          isPeerMuted: false),
                      audioCallCtrl.toolbar(false, 'calling'),
                    ],
                  ),
                );
              },
            ));
      }
    );
  }
}
