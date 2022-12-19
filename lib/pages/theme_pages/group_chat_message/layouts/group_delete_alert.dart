import '../../../../config.dart';

class GroupDeleteAlert extends StatelessWidget {
  final DocumentSnapshot? documentReference;
  const GroupDeleteAlert({Key? key,this.documentReference}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(
      builder: (chatCtrl) {
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
                    .collection('groupMessage')
                    .doc(chatCtrl.pId).collection("chat").doc(documentReference!.id)
                    .delete();
                await FirebaseFirestore.instance
                    .runTransaction((transaction) async {});
                chatCtrl.listScrollController.animateTo(0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      }
    );
  }
}
