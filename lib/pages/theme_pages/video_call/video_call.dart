import 'package:flutter_theme/config.dart';


class VideoCall extends StatelessWidget {
  final videoCtrl = Get.put(VideoCallController());
  VideoCall({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return GetBuilder<VideoCallController>(
      builder: (_) {
        return WillPopScope(
          onWillPop: videoCtrl.onWillPopNEw,
          child: Scaffold(
            // appBar: AppBar(
            //   title: Text('Flutter Video Call Demo'),
            //   centerTitle: true,
            // ),
              backgroundColor: Colors.black,
              body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: videoCtrl.stream as Stream<DocumentSnapshot<Map<String, dynamic>>>?,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.data() == null || snapshot.data == null) {
                      return Center(
                        child: Stack(
                          children: <Widget>[
                            // _viewRows(),
                            videoCtrl.onetooneview(
                                screenHeight, screenWidth, false, videoCtrl.isuserenlarged),

                            videoCtrl.toolbar(false, 'calling'),
                            videoCtrl.panel(
                                status: 'calling',
                                ispeermuted: false,
                                context: context),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Stack(
                          children: <Widget>[
                            // _viewRows(),
                            videoCtrl.onetooneview(
                                screenHeight,
                                screenWidth,
                                snapshot.data!.data()!["STATUS"] == 'ended'
                                    ? true
                                    : false,
                                videoCtrl.isuserenlarged),

                            videoCtrl.toolbar(
                                snapshot.data!.data()!["STATUS"] == 'pickedup'
                                    ? true
                                    : false,
                                snapshot.data!.data()!["STATUS"]),

                            snapshot.data!.data()!["STATUS"] == 'pickedup' &&
                                videoCtrl.getRenderViews().length > 1
                                ? Positioned(
                              bottom: screenWidth > screenHeight ? 40 : 120,
                              right: screenWidth > screenHeight ? 20 : 10,
                              child: Container(
                                height: screenWidth > screenHeight
                                    ? screenWidth / 4.7
                                    : screenHeight / 4.7,
                                width: screenWidth > screenHeight
                                    ? (screenWidth / 4.7) / 1.7
                                    : (screenHeight / 4.7) / 1.7,
                                child: videoCtrl.getRenderViews()[
                                videoCtrl.isuserenlarged == true ? 1 : 0],
                              ),
                            )
                                : SizedBox(),
                            videoCtrl.panel(
                                context: context,
                                status: snapshot.data!.data()!["STATUS"],
                                ispeermuted: snapshot.data!.data()!["ISMUTED"]),
                          ],
                        ),
                      );
                    }
                  } else if (!snapshot.hasData) {
                    return Center(
                      child: Stack(
                        children: <Widget>[
                          // _viewRows(),
                          videoCtrl.onetooneview(
                              screenHeight, screenWidth, false, videoCtrl.isuserenlarged),

                          videoCtrl.toolbar(false, 'nonetwork'),
                          videoCtrl.panel(
                              context: context,
                              status: 'nonetwork',
                              ispeermuted: false),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        // _viewRows(),
                        videoCtrl.onetooneview(
                            screenHeight, screenWidth, false, videoCtrl.isuserenlarged),

                        videoCtrl.toolbar(false, 'calling'),
                        videoCtrl.panel(
                            context: context,
                            status: 'calling',
                            ispeermuted: false),
                      ],
                    ),
                  );
                },
              )),
        );
      }
    );
  }
}
