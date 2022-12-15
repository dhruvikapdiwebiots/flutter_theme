import '../../../../config.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (messageCtrl) {
      return Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('contacts')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
                  ));
                } else {
                  return (snapshot.data!).docs.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(10.0),
                          itemBuilder: (context, index) {
                            return messageCtrl.loadUser(
                                context, (snapshot.data!).docs[index]);
                          },
                          itemCount: (snapshot.data!).docs.length,
                        )
                      : Container();
                }
              }),

        ],
      );
    });
  }
}
