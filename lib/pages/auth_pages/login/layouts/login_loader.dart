import '../../../../config.dart';

class LoginLoader extends StatelessWidget {
  final bool isLoading;
  const LoginLoader({Key? key,this.isLoading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: isLoading
          ? Container(
        color: appCtrl.appTheme.accent.withOpacity(0.8),
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  appCtrl.appTheme.primary)),
        ),
      )
          : Container(),
    );
  }
}
