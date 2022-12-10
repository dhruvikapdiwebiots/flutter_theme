import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/theme_pages/chat/layouts/audio_recording_plugin.dart';
import 'package:flutter_theme/utilities/utils/handler/all_permission_handler.dart';

class ChatController extends GetxController {
  String? pId, id, pName, groupId, imageUrl, peerNo;
  dynamic message;
  final permissionHandelCtrl = Get.put(PermissionHandlerController());
  bool positionStreamStarted = false;
  XFile? imageFile;
  bool? isLoading;

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

//read local data
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

// FOR Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  documentShare() async {
    dismissKeyboard();
    Get.back();
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path.toString());
      String fileName = "${file.name}-${DateTime.now().millisecondsSinceEpoch.toString()}";
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(file);
      print("fileName : $fileName");
      print("file : $file");
      uploadTask.then((res) {
        res.ref.getDownloadURL().then((downloadUrl) {
          imageUrl = downloadUrl;
          isLoading = false;
          onSendMessage(
              "${result.files.single.name}-BREAK-$imageUrl",
              result.files.single.path.toString().contains(".mp4")
                  ? MessageType.video
                  : result.files.single.path.toString().contains(".mp3")
                      ? MessageType.audio
                      : MessageType.doc);
          update();
        }, onError: (err) {
          isLoading = false;
          update();
          Fluttertoast.showToast(msg: 'Not Upload');
        });
      });
    }
  }

  //location share
  locationShare() async {
    dismissKeyboard();
    Get.back();
    await getCurrentPosition().then((value) async {
      var locationString =
          'https://www.google.com/maps/search/?api=1&query=${value.latitude},${value.longitude}';
      onSendMessage(locationString, MessageType.location);
    });
  }

  //share media
  shareMedia(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout

          return const FileBottomSheet();
        });
  }

// GET IMAGE FROM GALLERY
  Future getImage(source) async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source))!;
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
        onSendMessage(imageUrl!, MessageType.image);
        update();
      }, onError: (err) {
        isLoading = false;
        update();
        Fluttertoast.showToast(msg: 'Image is Not Valid');
      });
    });
  }

  //pick up contact and share
  saveContactInChat() async {
    // Add your onPressed code here!
    final granted = await FlutterContactPicker.hasPermission();
    if (granted) {
      update();
    } else {
      await FlutterContactPicker.requestPermission().then((value) async {
        update();
      });
    }
    final FullContact contactPick =
        (await FlutterContactPicker.pickFullContact());

    onSendMessage(
        '${contactPick.name!.nickName}-BREAK-${contactPick.phones[0].number}-BREAK-${contactPick.photo!}',
        MessageType.contact);
    update();
  }

  void audioRecording(BuildContext context, String type, int index) {
    showModalBottomSheet(
      context: Get.context!,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: AudioRecordingPlugin(
            type: type,
            index: index,
          ),
        );
      },
    );
  }

  Future<Position> getCurrentPosition() async {
    final hasPermission = await permissionHandelCtrl.handlePermission();

    if (!hasPermission) {
      return Geolocator.getCurrentPosition();
    }

    final position =
        await permissionHandelCtrl.geoLocatorPlatform.getCurrentPosition();
    permissionHandelCtrl.updatePositionList(
      PositionItemType.position,
      position.toString(),
    );

    return position;
  }

  // SEND MESSAGE CLICK
  void onSendMessage(String content, MessageType type) async {
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
            'type': type.name
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  //delete chat
  Widget buildPopupDialog(
      BuildContext context, DocumentSnapshot documentReference) {
    return DeleteAlert(
      documentReference: documentReference,
    );
  }

// BUILD ITEM MESSAGE BOX FOR RECEIVER AND SENDER BOX DESIGN
  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      return SenderMessage(
        document: document,
        index: index,
      );
    } else {
      // RECEIVER MESSAGE
      return ReceiverMessage(document: document, index: index);
    }
  }

  // CHECK IF IT IS RECEIVER SIDE OR NOT
  bool isLastMessageLeft(int index) {
    if ((index > 0 && message != null && message![index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // CHECK IF IT IS SENDER SIDE OR NOT
  bool isLastMessageRight(int index) {
     if ((index > 0 && message != null && message![index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }

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

  //image picker option
  imagePickerOption(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return const ImagePickerLayout();
        });
  }
}
