
import '../../../../config.dart';

class ContactLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final VoidCallback? onLongPress;

  const ContactLayout({Key? key, this.document, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        child: Container(
            decoration: BoxDecoration(
              color: appCtrl.appTheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.r15),
            ),
            width: Sizes.s250,
            height: Sizes.s120,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ContactListTile(document: document,),
                  Divider(
                      height: 7,
                      color: appCtrl.appTheme.whiteColor.withOpacity(.2)),
                  // ignore: deprecated_member_use
                  TextButton(
                      onPressed: () {},
                      child: Text("Message",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: appCtrl.appTheme.whiteColor)))
                ])));
  }
}
