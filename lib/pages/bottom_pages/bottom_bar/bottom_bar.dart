



import '../../../../../config.dart';

class CustomAnimatedBottomBar extends StatelessWidget {
  const CustomAnimatedBottomBar({
    Key? key,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.iconSize = 24,
    this.backgroundColor,
    this.itemCornerRadius = 50,
    this.containerHeight = 56,
    this.animationDuration = const Duration(milliseconds: 270),
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    required this.items,
    required this.onItemSelected,
    this.curve = Curves.linear,
  })  : assert(items.length >= 2 && items.length <= 5),
        super(key: key);

  final int selectedIndex;
  final double iconSize;
  final Color? backgroundColor;
  final bool showElevation;
  final Duration animationDuration;
  final List<BottomNavyBarItem> items;
  final ValueChanged<int> onItemSelected;
  final MainAxisAlignment mainAxisAlignment;
  final double itemCornerRadius;
  final double containerHeight;
  final Curve curve;

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(color: appCtrl.appTheme.primary, boxShadow: [
        if (showElevation)
          BoxShadow(color: appCtrl.appTheme.txt.withOpacity(.5), blurRadius: 2)
      ]),
      child: SafeArea(
        child: Container(
            width: double.infinity,
            height: containerHeight,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
                mainAxisAlignment: mainAxisAlignment,
                children: items.map((item) {
                  var index = items.indexOf(item);
                  return GestureDetector(
                      onTap: () => onItemSelected(index),
                      child: ItemWidget(
                          item: item,
                          isSelected: index == selectedIndex,
                          animationDuration: animationDuration,
                          curve: curve));
                }).toList())),
      ),
    );
  }
}
