import '../../../../config.dart';

class CommonLoader extends StatelessWidget {
  final bool isLoading;
  const CommonLoader({Key? key,this.isLoading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return Positioned(
          child: isLoading
              ? Center(
              child: Material(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60)),
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: appCtrl.appTheme.primary,
                              strokeWidth: 3)))))
              : Container(),
        );
      }
    );
  }
}
