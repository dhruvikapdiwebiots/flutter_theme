

import '../../../../config.dart';

class CallListLayout extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>? snapshot;

  const CallListLayout({Key? key, this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallListController>(builder: (callListCtrl) {
      return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: Insets.i10),
        itemBuilder: (context, index) {
          return CallView(
            snapshot: snapshot,
            index: index,
            userId: callListCtrl.user["id"],
          );
        },
        itemCount: snapshot!.data!.docs.length,
      );
    });
  }
}
