import 'package:flutter/services.dart';

import '../../../../config.dart';

class TextStatus extends StatefulWidget {
  const TextStatus({Key? key}) : super(key: key);

  @override
  State<TextStatus> createState() => _TextStatusState();
}

class _TextStatusState extends State<TextStatus> {

  TextEditingController controller =  TextEditingController();
  Future<bool> onWillPopNEw() {
    return Future.value(false);
  }

  String getColorString() {
    Color color = colorsList[colorIndex];
    String colorString = color.toString(); // Color(0x12345678)
    String valueString =
    colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    return valueString;
  }

  List<Color> colorsList = [
    Colors.blueGrey[700]!,
    Colors.purple[700]!,
    Colors.orange[500]!,
    Colors.cyan[700]!,
    Colors.brown[600]!,
    Colors.red[400]!,
  ];
  int colorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(
      builder: (statusCtrl) {
        return WillPopScope(
          onWillPop: onWillPopNEw,
          child: Scaffold(
            backgroundColor: colorsList[colorIndex],
            appBar: AppBar(
              backgroundColor: colorsList[colorIndex],
              elevation: 0,
              automaticallyImplyLeading: false,
              leading:IconButton(
                onPressed: () =>  Get.back(),
                icon:  Icon(Icons.close, size: 30, color: appCtrl.appTheme.whiteColor),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    if ((colorsList.length - 1) == colorIndex) {
                      colorIndex = 0;
                    } else {
                      colorIndex++;
                    }
                    if (mounted) setState(() {});
                  },
                  icon:  Icon(Icons.palette_rounded,
                      size: 30, color: appCtrl.appTheme.whiteColor),
                ),
                IconButton(
                  onPressed: () {
                    statusCtrl.dismissKeyboard();
                    StatusFirebaseApi().addStatus("", StatusType.text.name,statusBgColor: getColorString(),statusText:controller.text);
                    Get.back();
                  },
                  icon: Icon(Icons.done,
                      size: 30,
                      color: controller.text.isEmpty
                          ? Colors.white24
                          : appCtrl.appTheme.whiteColor),
                )
              ],
            ),
            body:  Center(
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(23, 23, 23, 10),
                child: TextField(
                  decoration: const InputDecoration(border: InputBorder.none),
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(150),
                  ],
                  onChanged: (text) {
                    setState(() {});
                  },
                  maxLines: 7,
                  minLines: 1,
                  style:  TextStyle(
                      color: appCtrl.appTheme.whiteColor,
                      fontSize: 23,
                      height: 1.6,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
