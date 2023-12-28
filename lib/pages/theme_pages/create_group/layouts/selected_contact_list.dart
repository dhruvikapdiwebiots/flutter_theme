import '../../../../config.dart';

class SelectedContactList extends StatelessWidget {
  final List? selectedContact;
  final Function(dynamic)? onTap;

  const SelectedContactList({Key? key, this.selectedContact, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: selectedContact!.asMap().entries.map((e) {
          return SelectedUsers(
            data: e.value,
            onTap: () => onTap!(e.value),
          );
        }).toList(),
      ),
    );
  }
}
