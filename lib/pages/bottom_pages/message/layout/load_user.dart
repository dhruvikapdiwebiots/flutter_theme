import 'dart:developer';

import '../../../../config.dart';

class LoadUser extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy;

  const LoadUser({Key? key, this.document, this.currentUserId, this.blockBy})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (document!["isGroup"] == false && document!["isBroadcast"] == false ) {
      if (document!["senderPhone"] == currentUserId ) {
        return   ReceiverMessageCard(
            document: document, currentUserId: currentUserId, blockBy: blockBy);
      } else {
        return MessageCard(
          blockBy: blockBy,
          document: document,
          currentUserId: currentUserId,
        );
      }
    } else if (document!["isGroup"] == true) {
      List user = document!["receiverId"];
      return user
              .where((element) => element["phone"] == currentUserId)
              .isNotEmpty
          ? GroupMessageCard(
              document: document,
              currentUserId: currentUserId,
            )
          : Container();
    } else if (document!["isBroadcast"] == true || document!["isBroadcastSender"] == false) {

      return document!["senderPhone"] == currentUserId
          ? BroadCastMessageCard(
              document: document,
              currentUserId: currentUserId,
            )
          : Container();
    } else if( document!["isBroadcastSender"] == true ){
      return MessageCard(
        blockBy: blockBy,
        document: document,
        currentUserId: currentUserId,
      );
    }else{
      return Container();
    }
  }
}
