import '../../../../../config.dart';

class ItemWidget extends StatelessWidget {
  final bool isSelected;
  final BottomNavyBarItem item;
  final Duration animationDuration;
  final Curve curve;

  const ItemWidget({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.animationDuration,
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
        container: true,
        selected: isSelected,
        child: AnimatedContainer(
            width:130,
            height: double.maxFinite,
            duration: animationDuration,
            curve: curve,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Container(
                    width: 130,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        item.icon,

                          Expanded(
                              child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                                  child: DefaultTextStyle.merge(
                                      style: TextStyle(
                                          color: item.activeColor,
                                          fontWeight: FontWeight.bold),
                                      textAlign: item.textAlign,
                                      child: item.title)))
                      ],
                    )))));
  }
}
