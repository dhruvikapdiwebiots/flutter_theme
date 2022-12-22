import '../../../../config.dart';

class LoadUser extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;
  const LoadUser({Key? key,this.document,this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (document!["isGroup"] == false) {

      if (document!["senderPhone"] == currentUserId) {
        return ReceiverMessageCard(
            document: document, currentUserId: currentUserId);
      } else {
        return MessageCard(
          document: document,
          currentUserId: currentUserId,
        );
      }
    } else {
      List user = document!["receiverId"];
      return user.where((element) => element["phone"] == currentUserId).isNotEmpty
          ? GroupMessageCard(
        document: document,
        currentUserId: currentUserId,
      )
          : Container();
    };
  }
}
