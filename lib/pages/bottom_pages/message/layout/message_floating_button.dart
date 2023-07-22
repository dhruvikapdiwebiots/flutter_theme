import '../../../../config.dart';

class MessageFloatingButton extends StatelessWidget {
  const MessageFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: ()async {

          Get.to(() =>  ContactList(),
              transition: Transition.downToUp);
        //Get.toNamed(routeName.contactList);

        },
        backgroundColor: appCtrl.appTheme.primary,
        child: Container(
            width: Sizes.s52,
            height: Sizes.s52,
            padding: const EdgeInsets.all(Insets.i8),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  appCtrl.isTheme
                      ? appCtrl.appTheme.primary.withOpacity(.8)
                      : appCtrl.appTheme.lightPrimary,
                  appCtrl.appTheme.primary
                ])),
            child: SvgPicture.asset(svgAssets.add,
                height: Sizes.s15)));
  }
}
