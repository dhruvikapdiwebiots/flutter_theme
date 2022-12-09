import '../../../../config.dart';

class AudioDoc extends StatelessWidget {
  final VoidCallback? onLongPress;
  final DocumentSnapshot? document;

  const AudioDoc({Key? key, this.onLongPress, this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: Insets.i10),
          padding: const EdgeInsets.symmetric(vertical: Insets.i10),
          decoration: BoxDecoration(
            color: appCtrl.appTheme.primary,
            borderRadius: BorderRadius.circular(AppRadius.r15),
          ),
          width: 250,
          height: 130,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            ListTile(
              isThreeLine: false,
              leading: const CircleAvatar(
                backgroundColor: Color(0xffE6E6E6),
                radius: 30,
                child: Icon(
                  Icons.people,
                  color: Color(0xffCCCCCC),
                ),
              ),
              title: Text(
                document!['content'].split("-BREAK-")[0],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: appCtrl.appTheme.whiteColor),
              ),
            ),
            Divider(
              height: 7,
              color: appCtrl.appTheme.whiteColor.withOpacity(.2),
            ),
            // ignore: deprecated_member_use
            TextButton(
                onPressed: () async {},
                child: Text("DOWNLOAD",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: appCtrl.appTheme.whiteColor)))
          ])),
    );
  }
}
