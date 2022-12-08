import 'dart:async';
import 'dart:io';
import 'package:flutter_theme/config.dart';


class ChatController extends GetxController {
  String? pId, id, pName,groupId,imageUrl, peerNo;
  dynamic message;

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

// GET IMAGE FROM GALLERY
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

  Widget buildPopupDialog(
      BuildContext context, DocumentSnapshot documentReference) {
    return DeleteAlert(documentReference: documentReference,);
  }

// BUILD ITEM MESSAGE BOX FOR RECEIVER AND SENDER BOX DESIGN
  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      return SenderMessage(document: document,index: index,);
    } else {
      // RECEIVER MESSAGE
      return ReceiverMessage(document: document,index: index);
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
