import 'dart:convert';
import 'dart:developer';

import 'dart:typed_data';

import 'package:flutter_theme/models/message_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../../../config.dart';

class ReceiverImage extends StatefulWidget {
  final MessageModel? document;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onTap;

  const ReceiverImage({Key? key, this.document, this.onLongPress,this.onTap})
      : super(key: key);

  @override
  State<ReceiverImage> createState() => _ReceiverImageState();
}

class _ReceiverImageState extends State<ReceiverImage> {
  bool _imageLoaded = false;
  Uint8List? _imageBytes;
  List image = [];
  
  @override
  void initState() {
    super.initState();
    

    if (widget.document!.type == MessageType.imageArray.name) {
      var a = decrypt(widget.document!.content);

      var ab = json.decode(a).cast<String>().toList();

      image = ab;
      setState(() {

      });
      log("image : ${image}");
    }
    _loadImage();
  }

  void _loadImage() async {
    try {
      final response = await http.get(Uri.parse(decrypt(widget.document!.content)));
      if (response.statusCode == 200) {
        setState(() {
          _imageLoaded = true;
          _imageBytes = response.bodyBytes;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: widget.onLongPress,
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          widget.document!.type == MessageType.image.name
              ? Stack(
            clipBehavior: Clip.none ,
            children: [
              Container(

                decoration: ShapeDecoration(
                  color: appCtrl.appTheme.chatSecondaryColor,
                  shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                          topLeft: SmoothRadius(
                            cornerRadius: 20,
                            cornerSmoothing:1
                          ),
                          topRight: SmoothRadius(
                            cornerRadius: 20,
                            cornerSmoothing: 1
                          ),
                          bottomRight: SmoothRadius(
                            cornerRadius: 20,
                            cornerSmoothing: 1
                          ))),
                ),
                child:ClipSmoothRect(
                    clipBehavior: Clip.hardEdge,
                    radius: SmoothBorderRadius(
                      cornerRadius: 20,
                      cornerSmoothing: 1,
                    ),
                    child: Material(
                      borderRadius: SmoothBorderRadius(cornerRadius: 20,cornerSmoothing: 1),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                            width: Sizes.s160,

                            decoration: BoxDecoration(
                              color: appCtrl.appTheme.accent,
                              borderRadius: BorderRadius.circular(AppRadius.r8),
                            ),
                            child: Container()),
                        imageUrl: decryptMessage(widget.document!.content),
                        width: Sizes.s160,
                        fit: BoxFit.cover,
                      ),
                    ).paddingSymmetric(horizontal:Insets.i10).paddingOnly(bottom: Insets.i12)
                )
              ),
              if (widget.document!.emoji!= null)
                EmojiLayout(emoji: widget.document!.emoji)
            ],
          ) : Container(
            decoration: ShapeDecoration(
              color: appCtrl.appTheme.chatSecondaryColor,
              shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 10, cornerSmoothing: 1)),
            ),
            height: Sizes.s220,
            width: Sizes.s200,
            child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(Insets.i12),
              itemCount: 4,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 0,
                  mainAxisExtent: 95,
                  mainAxisSpacing: 0.0,
                  crossAxisCount: 2),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(index == 0 ? 15 : 0),
                      bottomLeft: Radius.circular(index == 2 ? 15 : 0),
                      bottomRight: Radius.circular(index == 3 ? 15 : 0),
                      topRight: Radius.circular(index == 1 ? 15 : 0)),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: index == 0 || index == 2
                                    ? appCtrl.appTheme.redColor
                                    : appCtrl.appTheme.transparentColor,
                                width: 2),bottom:    BorderSide(
                            color: index == 0 || index == 1
                                ? appCtrl.appTheme.redColor
                                : appCtrl.appTheme.transparentColor,
                            width: 2))),
                    child: Image.network(
                      image[index],
                      height: Sizes.s120,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                if (widget.document!.isFavourite != null)
                  if(appCtrl.user["id"] == widget.document!.favouriteId)
                    Icon(Icons.star,
                        color: appCtrl.appTheme.txtColor, size: Sizes.s10),
                const HSpace(Sizes.s3),
                Text(
                  DateFormat('HH:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(widget.document!.timestamp!.toString()))),
                  style: AppCss.poppinsMedium12
                      .textColor(appCtrl.appTheme.txtColor),
                ).marginSymmetric(horizontal: Insets.i5, vertical: Insets.i8),
              ],
            ),
          )
        ],
      ).marginSymmetric(horizontal: Insets.i15),
    );
  }
}
