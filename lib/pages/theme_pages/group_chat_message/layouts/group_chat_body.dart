import '../../../../config.dart';

class GroupChatBody extends StatelessWidget {
  const GroupChatBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      // List of messages
      const GroupMessageBox(),
      // Sticker
      Container(),
      // Input content
      const GroupInputBox()
    ]);
  }
}
