

import '../../../../config.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (messageCtrl) {
      return Column(
        children: [
          FutureBuilder(
              future: messageCtrl.getMessage(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
                  ));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      return LoadUser(
                          document: snapshot.data![index],
                          currentUserId: messageCtrl.currentUserId);
                    },
                    itemCount: snapshot.data!.length,
                  );
                }
              }),
        ],
      );
    });
  }
}
