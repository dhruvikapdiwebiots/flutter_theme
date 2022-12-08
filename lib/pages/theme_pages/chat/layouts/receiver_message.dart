
import 'package:intl/intl.dart';

import '../../../../config.dart';

class ReceiverMessage extends StatelessWidget {
  final DocumentSnapshot? document;
  final int? index;

  const ReceiverMessage({Key? key, this.index, this.document})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  // MESSAGE BOX FOR TEXT
                  document!['type'] == 0
                      ? ReceiverContent(content: document!['content'])

                      // MESSAGE BOX FOR IMAGE
                      : ReceiverImage(image: document!['content'])
                ],
              ),

              // STORE TIME ZONE FOR BACKAND DATABASE
              chatCtrl.isLastMessageLeft(index!)
                  ? Container(
                      margin: const EdgeInsets.only(
                          left: 10.0, top: 5.0, bottom: 5.0),
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document!['timestamp']))),
                        style: TextStyle(
                            color: appCtrl.appTheme.primary,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  : Container()
            ]),
      );
    });
  }
}
