
import 'dart:developer';

import 'package:flutter_theme/widgets/common_note_encrypt.dart';

import '../../../../config.dart';

class BroadcastMessage extends StatelessWidget {
  const BroadcastMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return Flexible(
        child:  ListView(
          controller: chatCtrl.listScrollController,
          reverse: true,
          children: [

            ...chatCtrl.localMessage.asMap().entries.map((e) => chatCtrl
                .timeLayout(
              e.value,
            )
                .marginOnly(bottom: Insets.i18)).toList(),
            Container(
                margin: const EdgeInsets.only(bottom: 2.0),
                padding: const EdgeInsets.only(
                    left: Insets.i10, right: Insets.i10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.center,
                      child: CommonNoteEncrypt(),
                    ).paddingOnly(bottom: Insets.i8)
                  ],
                )),
            /*ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return chatCtrl
                            .timeLayout(
                              chatCtrl.message[index],
                            )
                            .marginOnly(bottom: Insets.i18);
                      },
                      itemCount: chatCtrl.message.reversed.length,
                      reverse: true,
                      controller: chatCtrl.listScrollController),*/
          ],
        ),
      );
    });
  }
}
