import 'package:intl/intl.dart';

import '../../../../config.dart';

class CallIcon extends StatelessWidget {
  final AsyncSnapshot<dynamic>? snapshot;
  final int? index;

  const CallIcon({Key? key,this.snapshot,this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              snapshot!.data!.docs[index!].data()['type'] == 'inComing'
                  ? (snapshot!.data!.docs[index!].data()['started'] ==
                  null
                  ? Icons.call_missed
                  : Icons.call_received)
                  : (snapshot!.data!.docs[index!].data()['started'] ==
                  null
                  ? Icons.call_made_rounded
                  : Icons.call_made_rounded),
              size: 15,
              color: snapshot!.data!.docs[index!].data()['type'] ==
                  'inComing'
                  ? (snapshot!.data!.docs[index!].data()['started'] ==
                  null
                  ? appCtrl.appTheme.redColor
                  : appCtrl.appTheme.greenColor)
                  : (snapshot!.data!.docs[index!].data()['started'] ==
                  null
                  ? appCtrl.appTheme.redColor
                  : appCtrl.appTheme.greenColor)),
          const HSpace(Sizes.s5),
          DateFormat('dd/MM/yyyy').format(DateTime.now()) ==   DateFormat('dd/MM/yyyy').format(
              DateTime.fromMillisecondsSinceEpoch(int.parse(snapshot!
                  .data!.docs[index!]
                  .data()["timestamp"]
                  .toString()))) ?  Text("Today, ${DateFormat('HH:mm a').format(
              DateTime.fromMillisecondsSinceEpoch(int.parse(snapshot!
                  .data!.docs[index!]
                  .data()["timestamp"]
                  .toString())))}",
              style: AppCss.poppinsMedium12
                  .textColor(appCtrl.appTheme.statusTxtColor)) :
          calculateDifference(DateTime.fromMillisecondsSinceEpoch(int.parse(snapshot!
              .data!.docs[index!]
              .data()["timestamp"]
              .toString())))  == -1 ? Text("Yesterday, ${DateFormat('HH:mm a').format(
              DateTime.fromMillisecondsSinceEpoch(int.parse(snapshot!
                  .data!.docs[index!]
                  .data()["timestamp"]
                  .toString())))}",
              style: AppCss.poppinsMedium12
                  .textColor(appCtrl.appTheme.statusTxtColor)) :
          Text(
              DateFormat('MMM dd HH:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(int.parse(snapshot!
                      .data!.docs[index!]
                      .data()["timestamp"]
                      .toString()))),
              style: AppCss.poppinsMedium12
                  .textColor(appCtrl.appTheme.statusTxtColor))
        ]);
  }
}