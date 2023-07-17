
import '../config.dart';

class LoadingComponent extends StatelessWidget {
  final Widget child;
  const LoadingComponent({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        child,
        GetBuilder<LoadingController>(
          builder: (ctrl) {
            return ctrl.isLoading == true
                ? Container(
                  width: screenWidth,
                  height: screenHeight,
                  color: appCtrl.appTheme.blackColor.withOpacity(0.2),
                  child: Center(
                      child: Material(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                        child:  Padding(
                          padding:const EdgeInsets.all(8),
                          child: SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                )
                : Container();
          },
        ),
      ],
    );
  }
}
