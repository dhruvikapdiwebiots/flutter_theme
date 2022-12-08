import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_theme/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatController extends GetxController {
  String? pId;
  String? id;  String? pName;


  dynamic message;
  String? groupId;

  XFile? imageFile;
  bool? isLoading;
  String? imageUrl, peerNo;

  TextEditingController textEditingController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  @override
  void onReady() {
    // TODO: implement onReady
    groupId = '';
    isLoading = false;
    imageUrl = '';
    var data = Get.arguments;
    pId = data["pId"];
    pName = data["pName"];
    readLocal();

    update();
    super.onReady();
  }

  readLocal() async {
    id = appCtrl.storage.read('id') ?? '';
    if (id.hashCode <= pId.hashCode) {
      groupId = '$id-$pId';
    } else {
      groupId = '$pId-$id';
    }
    FirebaseFirestore.instance
        .collection(
            'users') // Your collection name will be whatever you have given in firestore database
        .doc(id)
        .update({'chattingWith': pId});
    update();
  }

// GET IMAGE FROM GALLARY
  Future getImage() async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: ImageSource.gallery))!;
    if (imageFile != null) {
      isLoading = true;
      update();
      uploadFile();
    }
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    var file = File(imageFile!.path);
    UploadTask uploadTask = reference.putFile(file);
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((downloadUrl) {
        imageUrl = downloadUrl;
        isLoading = false;
        onSendMessage(imageUrl!, 1);
        update();
      }, onError: (err) {
        isLoading = false;
        update();
        Fluttertoast.showToast(msg: 'Image is Not Valid');
      });
    });
  }

  // SEND MESSAGE CLICK
  void onSendMessage(String content, int type) async {
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupId)
          .collection(groupId!)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': pId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget _buildPopupDialog(
      BuildContext context, DocumentSnapshot documentReference) {
    return AlertDialog(
      title: const Text('Alert!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text("Are you sure you want to delete this message?"),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();

            FirebaseFirestore.instance
                .collection('messages')
                .doc(groupId)
                .collection(groupId!)
                .doc(documentReference.id)
                .delete();
            await FirebaseFirestore.instance
                .runTransaction((transaction) async {});
            listScrollController.animateTo(0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }

// BUILD ITEM MESSAGE BOX FOR RECEIVER AND SENDER BOX DESIGN

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      return Container(
        margin: const EdgeInsets.only(bottom: 2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                document['type'] == 0
                    // Text
                    ? InkWell(
                        onLongPress: () {
                          showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) =>
                                _buildPopupDialog(context, document),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          width: 220.0,
                          decoration: BoxDecoration(
                              color: appCtrl.appTheme.primary,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(Insets.i20),
                                  topLeft: Radius.circular(Insets.i20),
                                  bottomLeft: Radius.circular(Insets.i20))),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 10.0 : 10.0,
                              right: 10.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                document['content'],
                                style: TextStyle(
                                    color: appCtrl.appTheme.accent,
                                    fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(0),
                        child: TextButton(
                          child: Material(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(Insets.i20),
                                topLeft: Radius.circular(Insets.i20),
                                bottomLeft: Radius.circular(Insets.i20)),
                            clipBehavior: Clip.hardEdge,
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                width: 220.0,
                                height: 200.0,
                                padding: const EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: appCtrl.appTheme.accent,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(Insets.i20),
                                      topLeft: Radius.circular(Insets.i20),
                                      bottomLeft: Radius.circular(Insets.i20)),
                                ),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      appCtrl.appTheme.accent),
                                ),
                              ),
                              imageUrl: document['content'],
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          onLongPress: () {},
                          onPressed: () {},
                        ),
                      )
              ],
            ),
            // STORE TIME ZONE FOR BACKAND DATABASE
            isLastMessageRight(index)
                ? Container(
                    margin: const EdgeInsets.only(
                        right: 10.0, top: 5.0, bottom: 5.0),
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                      style: TextStyle(
                          color: appCtrl.appTheme.primary,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  )
                : Container()
          ],
        ),
      );
    } else {
      // RECEIVER MESSAGE
      return Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                // isLastMessageLeft(index)
                //     ? Material(
                //         child: CachedNetworkImage(
                //           placeholder: (context, url) => Container(
                //             child: CircularProgressIndicator(
                //               strokeWidth: 1.0,
                //               valueColor:
                //                   AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
                //             ),
                //             width: 35.0,
                //             height: 35.0,
                //             padding: EdgeInsets.all(10.0),
                //           ),
                //           imageUrl: pImage,
                //           width: 35.0,
                //           height: 35.0,
                //           fit: BoxFit.cover,
                //         ),
                //         borderRadius: BorderRadius.only(
                // topRight: Radius.circular(20.0),
                // bottomLeft: Radius.circular(20.0),
                // bottomRight: Radius.circular(20.0)),
                //         clipBehavior: Clip.hardEdge,
                //       )
                //     : Container(width: 35.0),

                // MESSAGE BOX FOR TEXT
                document['type'] == 0
                    ? Container(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 220.0,
                        decoration: BoxDecoration(
                            color: appCtrl.appTheme.gray,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(Insets.i20),
                                bottomLeft: Radius.circular(Insets.i20),
                                bottomRight: Radius.circular(Insets.i20))),
                        margin: const EdgeInsets.only(left: 2.0),
                        child: Text(
                          document['content'],
                          style: TextStyle(
                              color: appCtrl.appTheme.primary, fontSize: 14.0),
                        ),
                      )

                    // MESSAGE BOX FOR IMAGE
                    : Container(
                        padding: const EdgeInsets.all(0),
                        margin: const EdgeInsets.only(left: 10.0),
                        child: TextButton(
                          onPressed: () {},
                          child: Material(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(Insets.i20),
                                bottomLeft: Radius.circular(Insets.i20),
                                bottomRight: Radius.circular(Insets.i20)),
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                width: 200.0,
                                height: 200.0,
                                padding: const EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: appCtrl.appTheme.primary,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(20.0),
                                      bottomLeft: Radius.circular(20.0),
                                      bottomRight: Radius.circular(20.0)),
                                ),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      appCtrl.appTheme.primary),
                                ),
                              ),
                              errorWidget: (context, url, error) => Material(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: Sizes.s200,
                                  height: Sizes.s200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              imageUrl: document['content'],
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                          ),

                        ),
                      )
              ],
            ),

            // STORE TIME ZONE FOR BACKAND DATABASE
            isLastMessageLeft(index)
                ? Container(
                    margin: const EdgeInsets.only(
                        left: 10.0, top: 5.0, bottom: 5.0),
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                      style: TextStyle(
                          color: appCtrl.appTheme.primary,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  )
                : Container()
          ],
        ),
      );
    }
  }

  // CHECK IF IT IS RECEIVER SIDE OR NOT
  bool isLastMessageLeft(int index) {
    /*if ((index > 0 && message != null && message![index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }*/
    return false;
  }

  // CHECK IF IT IS SENDER SIDE OR NOT
  bool isLastMessageRight(int index) {
   /* if ((index > 0 && message != null && message![index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }*/
    return false;
  }

  // ON BACKPRESS
  Future<bool> onBackPress() {
    FirebaseFirestore.instance
        .collection(
            'users') // Your collection name will be whatever you have given in firestore database
        .doc(id)
        .update({'chattingWith': null});
    Get.back();
    return Future.value(false);
  }
}
