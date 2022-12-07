import '../../../../config.dart';

class PagePopup extends StatelessWidget {
  final PageViewData imageData;

  const PagePopup({Key? key, required this.imageData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 120,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    imageData.assetsImage,
                    height: Sizes.s50,
                    width: Sizes.s50,
                    fit: BoxFit.cover,
                  ),
                  const VSpace(Sizes.s20),
                  Text(
                    imageData.subtitleText.tr,
                    textAlign: TextAlign.center,
                    style: AppCss.poppinsBold20
                        .textColor(appCtrl.appTheme.primary).letterSpace(.2).textHeight(1.2)
                  ),
                ]),
          ),
        ),
      ],
    );
  }
}