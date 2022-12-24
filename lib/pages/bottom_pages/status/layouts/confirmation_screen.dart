import 'dart:io';

import '../../../../config.dart';

class ConfirmStatusScreen extends StatefulWidget {
  const ConfirmStatusScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfirmStatusScreen> createState() => _ConfirmStatusScreenState();
}

class _ConfirmStatusScreenState extends State<ConfirmStatusScreen> {
  File? file;

  @override
  void initState() {
    // TODO: implement initState
    file = Get.arguments;
    setState(() {

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(
      builder: (statusCtrl) {
        return Scaffold(
          body: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Image.file(file!),
                ),
              ),
              if(statusCtrl.isLoading)
                LoginLoader(isLoading: statusCtrl.isLoading,)
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: ()async {
             await statusCtrl.addStatus(file!);

              Get.back();
            },
            child:  Icon(
              Icons.done,
              color: appCtrl.appTheme.whiteColor
            )
          ),
        );
      }
    );
  }
}
