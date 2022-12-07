import '../../../../../config.dart';

class BottomNavBar extends StatelessWidget {
  final ValueChanged<int>? onItemSelected;
  final List? bottomNavBarList;
  final int? selectedIndex;

  const BottomNavBar(
      {Key? key,
      this.onItemSelected,
      this.selectedIndex,
      this.bottomNavBarList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAnimatedBottomBar(
      containerHeight: Sizes.s60,
      backgroundColor: appCtrl.appTheme.primary,
      selectedIndex: selectedIndex!,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      onItemSelected: onItemSelected!,
      items: [
        ...bottomNavBarList!
            .asMap()
            .entries
            .map((e) => BottomNavyBarItem(
                  icon: Icon(e.value["icon"],
                      size: e.key == selectedIndex! ? Sizes.s25 : Sizes.s20,
                      color: e.key == selectedIndex!
                          ? appCtrl.appTheme.whiteColor
                          : appCtrl.appTheme.whiteColor),
                  title: Text(trans(e.value['title']),
                      style:  e.key == selectedIndex! ?  AppCss.poppinsBold16.textColor(appCtrl.appTheme.whiteColor) : AppCss.poppinsMedium16.textColor(appCtrl.appTheme.whiteColor)),
                  activeColor: appCtrl.appTheme.whiteColor,
                  inactiveColor: appCtrl.appTheme.whiteColor,
                  textAlign: TextAlign.center,
                ))
            .toList()
      ],
    );
  }
}
