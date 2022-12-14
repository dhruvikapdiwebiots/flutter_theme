

import '../../../../config.dart';

class SelectedContactList extends StatelessWidget {
  const SelectedContactList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateGroupController>(builder: (groupChatCtrl) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: groupChatCtrl.selectedContact.asMap().entries.map((e) {
            return SelectedUsers(
              data: e.value,
              onTap: () {
                groupChatCtrl.selectedContact.remove(e.value);
                groupChatCtrl.update();
              },
            );
          }).toList(),
        ),
      );
    });
  }
}
