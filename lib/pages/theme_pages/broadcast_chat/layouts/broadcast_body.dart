import '../../../../config.dart';

class BroadcastBody extends StatelessWidget {
  const BroadcastBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      // List of messages
      const BroadcastMessage(),
      // Sticker
      Container(),
      // Input content
      const BroadcastInputBox()
    ]);
  }
}
