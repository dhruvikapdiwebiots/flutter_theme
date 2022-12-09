import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../config.dart';

class SenderMessage extends StatefulWidget {
  final DocumentSnapshot? document;
  final int? index;

  const SenderMessage({Key? key, this.document, this.index}) : super(key: key);

  @override
  State<SenderMessage> createState() => _SenderMessageState();
}

class _SenderMessageState extends State<SenderMessage> {
  VideoPlayerController? videoController;
  Future<void>? initializeVideoPlayerFuture;
  bool startedPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    print("dd :${widget.document!["type"]}");
    if (widget.document!["type"] == MessageType.video.name) {
      print(widget.document!["content"]);
      videoController = VideoPlayerController.network(
        widget.document!["content"],
      );
    }
    super.initState();
  }

  Future<bool> started() async {
    await videoController!.initialize();
    await videoController!.play();
    startedPlaying = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Container(
          margin: const EdgeInsets.only(bottom: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (widget.document!["type"] == MessageType.text.name)
                    // Text
                    Content(
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!),
                        );
                      },
                      document: widget.document,
                      isLastMessageRight:
                          chatCtrl.isLastMessageRight(widget.index!),
                    ),
                  if (widget.document!["type"] == MessageType.image.name)
                    InkWell(
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!),
                        );
                      },
                      child: SenderImage(url: widget.document!['content']),
                    ),
                  if (widget.document!["type"] == MessageType.contact.name)
                    InkWell(
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: appCtrl.appTheme.primary,
                          borderRadius: BorderRadius.circular(AppRadius.r15),
                        ),
                        width: 250,
                        height: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListTile(
                              isThreeLine: false,
                              leading: CachedNetworkImage(
                                  imageUrl: widget.document!['content']
                                      .split('-BREAK-')[2],
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                        backgroundColor:
                                            const Color(0xffE6E6E6),
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                            '${widget.document!['content'].split('-BREAK-')[2]}'),
                                      ),
                                  placeholder: (context, url) =>
                                      const CircleAvatar(
                                        backgroundColor: Color(0xffE6E6E6),
                                        radius: 30,
                                        child: Icon(
                                          Icons.people,
                                          color: Color(0xffCCCCCC),
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                        backgroundColor: Color(0xffE6E6E6),
                                        radius: 30,
                                        child: Icon(
                                          Icons.people,
                                          color: Color(0xffCCCCCC),
                                        ),
                                      )),
                              title: Text(
                                widget.document!['content'].split('-BREAK-')[0],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    height: 1.4,
                                    fontWeight: FontWeight.w700,
                                    color: appCtrl.appTheme.whiteColor),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  widget.document!['content']
                                      .split('-BREAK-')[1],
                                  style: TextStyle(
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                      color: appCtrl.appTheme.accent),
                                ),
                              ),
                            ),
                            Divider(
                              height: 7,
                              color:
                                  appCtrl.appTheme.whiteColor.withOpacity(.2),
                            ),
                            // ignore: deprecated_member_use
                            TextButton(
                                onPressed: () {},
                                child: Text("Message",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: appCtrl.appTheme.whiteColor)))
                          ],
                        ),
                      ),
                    ),
                  if (widget.document!["type"] == MessageType.location.name)
                    InkWell(
                      onTap: () {
                        launchUrl(Uri.parse(widget.document!["content"]));
                      },
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!),
                        );
                      },
                      child: Image.asset(
                        imageAssets.map,
                        height: Sizes.s150,
                      )
                          .clipRRect(all: AppRadius.r10)
                          .paddingSymmetric(
                              vertical: Insets.i6, horizontal: Insets.i8)
                          .decorated(
                              color: appCtrl.appTheme.primary,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10))
                          .paddingSymmetric(vertical: Insets.i10),
                    ),
                  /*if (widget.document!["type"] == MessageType.video.name)
                    FutureBuilder<bool>(
                      future: started(),
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return AspectRatio(
                            aspectRatio: videoController!.value.aspectRatio,
                            child: VideoPlayer(
                              videoController!,
                            ),
                          ).height(Sizes.s200).gestures(onLongPress: () {
                            showDialog(
                              context: Get.context!,
                              builder: (BuildContext context) => chatCtrl
                                  .buildPopupDialog(context, widget.document!),
                            );
                          });
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),*/
                  if (widget.document!["type"] == MessageType.audio.name)
                    InkWell(
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: Insets.i10),
                        padding: EdgeInsets.symmetric(vertical: Insets.i10),
                        decoration: BoxDecoration(
                          color: appCtrl.appTheme.primary,
                          borderRadius: BorderRadius.circular(AppRadius.r15),
                        ),
                        width: 250,
                        height: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListTile(
                              isThreeLine: false,
                              leading: CircleAvatar(
                                backgroundColor: Color(0xffE6E6E6),
                                radius: 30,
                                child: Icon(
                                  Icons.people,
                                  color: Color(0xffCCCCCC),
                                ),
                              ),
                              title: Text(
                                widget.document!['content'].split("-BREAK-")[0],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    height: 1.4,
                                    fontWeight: FontWeight.w700,
                                    color: appCtrl.appTheme.whiteColor),
                              ),

                            ),
                            Divider(
                              height: 7,
                              color:
                                  appCtrl.appTheme.whiteColor.withOpacity(.2),
                            ),
                            // ignore: deprecated_member_use
                            TextButton(
                                onPressed: ()async {
                                  print(widget.document!['content'].split("-BREAK-")[1]);
                                 
                                },
                                child: Text("DOWNLOAD",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: appCtrl.appTheme.whiteColor)))
                          ],
                        ),
                      ),
                    )
                ],
              ),
              // STORE TIME ZONE FOR BACKAND DATABASE
              chatCtrl.isLastMessageRight(widget.index!)
                  ? Container(
                      margin: const EdgeInsets.only(
                          right: 10.0, top: 5.0, bottom: 5.0),
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(widget.document!['timestamp']))),
                        style: AppCss.poppinsMedium12
                            .style(FontStyle.italic)
                            .textColor(appCtrl.appTheme.primary),
                      ))
                  : Container()
            ],
          ));
    });
  }
}
