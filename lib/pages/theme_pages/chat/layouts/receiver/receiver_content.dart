import '../../../../../config.dart';

class ReceiverContent extends StatelessWidget {
  final String? content;
  const ReceiverContent({Key? key,this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      width: 220.0,
      decoration: BoxDecoration(
          color: appCtrl.appTheme.gray,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(Insets.i20),
              bottomLeft: Radius.circular(Insets.i20),
              bottomRight: Radius.circular(Insets.i20))),
      margin: const EdgeInsets.only(left: 2.0),
      child: Text(
        content!,
        style: TextStyle(
            color: appCtrl.appTheme.primary, fontSize: 14.0),
      ),
    );
  }
}
