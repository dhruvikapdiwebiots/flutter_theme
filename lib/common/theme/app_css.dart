import '../../config.dart';
part 'scale.dart';

class AppCss {
  //monterrat font
  static TextStyle montserrat = TextStyle(
    fontFamily: GoogleFonts.montserrat().fontFamily,
    letterSpacing: 0,

    height: 1,
  );

  //ubuntu font
  static TextStyle ubuntu = TextStyle(
    fontFamily: GoogleFonts.ubuntu().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );

  //lato font
  static TextStyle lato = TextStyle(
    fontFamily: GoogleFonts.lato().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );

  //nunito sans font
  static TextStyle nunitoSans = TextStyle(
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );

  //oleoScriptSwashCaps font
  static TextStyle oleoScriptSwashCaps = TextStyle(
    fontFamily: GoogleFonts.oleoScriptSwashCaps().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );

  //mulish font
  static TextStyle mulish= TextStyle(
    fontFamily: GoogleFonts.mulish().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );

  //inter font
  static TextStyle inter= TextStyle(
    fontFamily: GoogleFonts.inter().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );

  //rubik font
  static TextStyle rubik= TextStyle(
    fontFamily: GoogleFonts.rubik().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );


  //roboto  font
  static TextStyle roboto = TextStyle(
    fontFamily: GoogleFonts.roboto().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );

  //pubSans  font
  static TextStyle publicSans = TextStyle(
    fontFamily: GoogleFonts.publicSans().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );

  //josefin sans  font
  static TextStyle josefinSans = TextStyle(
    fontFamily: GoogleFonts.josefinSans().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );

  //rowdies sans  font
  static TextStyle rowdies = TextStyle(
    fontFamily: GoogleFonts.rowdies().fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1,
  );

  //Text Style montserrat extra bold
  static TextStyle get montserratExtraBold65 => montserrat.extraThickBold.size(FontSizes.f65);
  static TextStyle get montserratExtraBold60 => montserrat.extraThickBold.size(FontSizes.f60);

  //Text Style montserrat bold
  static TextStyle get montserratblack24 => montserrat.black.size(FontSizes.f24);
  static TextStyle get montserratblack20 => montserrat.black.size(FontSizes.f20);
  static TextStyle get montserratblack18 => montserrat.black.size(FontSizes.f18);
  static TextStyle get montserratblack16 => montserrat.black.size(FontSizes.f16);
  static TextStyle get montserratblack14 => montserrat.black.size(FontSizes.f14);


  //Text Style montserrat bold
  static TextStyle get montserratExtraBold22 => montserrat.extraBold.size(FontSizes.f22);
  static TextStyle get montserratExtraBold18 => montserrat.extraBold.size(FontSizes.f18);
  static TextStyle get montserratExtraBold16 => montserrat.extraBold.size(FontSizes.f16);
  static TextStyle get montserratExtraBold14 => montserrat.extraBold.size(FontSizes.f14);
  static TextStyle get montserratExtraBold12 => montserrat.extraBold.size(FontSizes.f12);

  static TextStyle get pubSansExtraBold14 => publicSans.extraBold.size(FontSizes.f14);

  //Text Style semi montserrat bold
  static TextStyle get montserratBold50 => montserrat.bold.size(FontSizes.f50);
  static TextStyle get montserratBold35 => montserrat.bold.size(FontSizes.f35);
  static TextStyle get montserratBold24 => montserrat.bold.size(FontSizes.f24);
  static TextStyle get montserratBold20 => montserrat.bold.size(FontSizes.f20);
  static TextStyle get montserratBold18 => montserrat.bold.size(FontSizes.f18);
  static TextStyle get montserratBold16 => montserrat.bold.size(FontSizes.f16);
  static TextStyle get montserratBold14 => montserrat.bold.size(FontSizes.f14);
  static TextStyle get montserratBold12 => montserrat.bold.size(FontSizes.f12);
  static TextStyle get montserratBold10 => montserrat.bold.size(FontSizes.f10);

  static TextStyle get interBold24 => inter.bold.size(FontSizes.f24);
  static TextStyle get interBold18 => inter.bold.size(FontSizes.f18);

  static TextStyle get rubikBold16 => rubik.bold.size(FontSizes.f16);
  static TextStyle get rubikBold18 => rubik.bold.size(FontSizes.f18);
  static TextStyle get pubSansBold14 => publicSans.bold.size(FontSizes.f14);
  static TextStyle get pubSansBold12 => publicSans.bold.size(FontSizes.f12);

  static TextStyle get josefinSansBold22 => josefinSans.bold.size(FontSizes.f22);


  static TextStyle get ubuntuSemiBold12 => ubuntu.semiBold.size(FontSizes.f12);
  static TextStyle get latoSemiBold26 => lato.semiBold.size(FontSizes.f26);
  static TextStyle get latoSemiBold18 => lato.semiBold.size(FontSizes.f18);
  static TextStyle get nunitoSemiSansBold18 => nunitoSans.semiBold.size(FontSizes.f18);
  static TextStyle get nunitoSemiSansBold16 => nunitoSans.semiBold.size(FontSizes.f16);
  static TextStyle get nunitoSemiSansBold12 => nunitoSans.semiBold.size(FontSizes.f12);
  static TextStyle get oleoScriptSemiBold35 => oleoScriptSwashCaps.semiBold.size(FontSizes.f35);
  static TextStyle get latoSemiBold16 => lato.semiBold.size(FontSizes.f16);
  static TextStyle get latoSemiBold14 => lato.semiBold.size(FontSizes.f14);
  static TextStyle get latoSemiBold12=> lato.semiBold.size(FontSizes.f12);

  static TextStyle get montserratSemiBold124=> montserrat.semiBold.size(FontSizes.f24);
  static TextStyle get montserratSemiBold20=> montserrat.semiBold.size(FontSizes.f20);
  static TextStyle get montserratSemiBold18=> montserrat.semiBold.size(FontSizes.f18);
  static TextStyle get montserratSemiBold16=> montserrat.semiBold.size(FontSizes.f16);
  static TextStyle get montserratSemiBold15=> montserrat.semiBold.size(FontSizes.f15);
  static TextStyle get montserratSemiBold14=> montserrat.semiBold.size(FontSizes.f14);
  static TextStyle get montserratSemiBold12=> montserrat.semiBold.size(FontSizes.f12);
  static TextStyle get montserratSemiBold10=> montserrat.semiBold.size(FontSizes.f10);

  static TextStyle get interSemiBold24 => inter.semiBold.size(FontSizes.f24);
  static TextStyle get interSemiBold22 => inter.semiBold.size(FontSizes.f22);
  static TextStyle get interSemiBold20 => inter.semiBold.size(FontSizes.f20);
  static TextStyle get interSemiBold16 => inter.semiBold.size(FontSizes.f16);
  static TextStyle get interSemiBold14 => inter.semiBold.size(FontSizes.f14);
  static TextStyle get interSemiBold12 => inter.semiBold.size(FontSizes.f12);
  static TextStyle get interSemiBold10 => inter.semiBold.size(FontSizes.f10);

  static TextStyle get mulishSemiBold14 => mulish.semiBold.size(FontSizes.f14);

  static TextStyle get rubikSemiBold50 => rubik.semiBold.size(FontSizes.f50);
  static TextStyle get rubikSemiBold30 => rubik.semiBold.size(FontSizes.f30);
  static TextStyle get rubikSemiBold22 => rubik.semiBold.size(FontSizes.f22);
  static TextStyle get rubikSemiBold20 => rubik.semiBold.size(FontSizes.f20);
  static TextStyle get rubikSemiBold16 => rubik.semiBold.size(FontSizes.f16);
  static TextStyle get rubikSemiBold14 => rubik.semiBold.size(FontSizes.f14);
  static TextStyle get rubikSemiBold12 => rubik.semiBold.size(FontSizes.f12);

  static TextStyle get publicSansSemiBold18 =>
      publicSans.bold.size(FontSizes.f18);
  static TextStyle get publicSansSemiBold16 =>
      publicSans.bold.size(FontSizes.f16);
  static TextStyle get publicSansSemiBold14 =>
      publicSans.bold.size(FontSizes.f14);
  static TextStyle get publicSansSemiBold12 =>
      publicSans.bold.size(FontSizes.f12);

  static TextStyle get robotoSemiBold35  => roboto.semiBold.size(FontSizes.f35);
  static TextStyle get robotoSemiBold20 => roboto.semiBold.size(FontSizes.f20);
  static TextStyle get robotoSemiBold18 => roboto.semiBold.size(FontSizes.f18);
  static TextStyle get robotoSemiBold16 => roboto.semiBold.size(FontSizes.f16);
  static TextStyle get robotoSemiBold14 => roboto.semiBold.size(FontSizes.f14);


  //Text Style montserrat medium
  static TextStyle get montserratMedium28 => montserrat.medium.size(FontSizes.f28);
  static TextStyle get montserratMedium20 => montserrat.medium.size(FontSizes.f20);
  static TextStyle get montserratMedium18 => montserrat.medium.size(FontSizes.f18);
  static TextStyle get montserratMedium16 => montserrat.medium.size(FontSizes.f16);
  static TextStyle get montserratMedium14 => montserrat.medium.size(FontSizes.f14);
  static TextStyle get montserratMedium12 => montserrat.medium.size(FontSizes.f12);
  static TextStyle get montserratMedium10 => montserrat.medium.size(FontSizes.f10);

  static TextStyle get pubSansMedium20 => publicSans.medium.size(FontSizes.f20);
  static TextStyle get pubSansMedium16 => publicSans.medium.size(FontSizes.f16);
  static TextStyle get pubSansMedium14 => publicSans.medium.size(FontSizes.f14);
  static TextStyle get pubSansMedium12 => publicSans.medium.size(FontSizes.f12);

  static TextStyle get ubuntuMedium20 => ubuntu.medium.size(FontSizes.f20);

  static TextStyle get mulishMedium12 => mulish.medium.size(FontSizes.f12);

  static TextStyle get robotoMedium22 => roboto.medium.size(FontSizes.f22);

  static TextStyle get latoMedium18 => lato.semiBold.size(FontSizes.f18);
  static TextStyle get latoMedium16 => lato.medium.size(FontSizes.f16);
  static TextStyle get latoMedium15 => lato.medium.size(FontSizes.f15);
  static TextStyle get latoMedium14 => lato.medium.size(FontSizes.f14);
  static TextStyle get latoMedium12 => lato.medium.size(FontSizes.f12);
  static TextStyle get latoMedium10 => lato.medium.size(FontSizes.f10);

  static TextStyle get interMedium20 => inter.medium.size(FontSizes.f20);
  static TextStyle get interMedium16 => inter.medium.size(FontSizes.f16);
  static TextStyle get interMedium14 => inter.medium.size(FontSizes.f14);
  static TextStyle get interMedium12 => inter.medium.size(FontSizes.f12);

    static TextStyle get rubikMedium35 => rubik.medium.size(FontSizes.f35);
    static TextStyle get rubikMedium30 => rubik.medium.size(FontSizes.f30);
  static TextStyle get rubikMedium16 => rubik.medium.size(FontSizes.f16);
  static TextStyle get rubikMedium14 => rubik.medium.size(FontSizes.f14);
  static TextStyle get rubikMedium12 => rubik.medium.size(FontSizes.f12);

  static TextStyle get robotoMedium35 => roboto.medium.size(FontSizes.f35);
  static TextStyle get robotoMedium18 => roboto.medium.size(FontSizes.f18);
  static TextStyle get robotoMedium16 => roboto.medium.size(FontSizes.f16);
  static TextStyle get robotoMedium14 => roboto.medium.size(FontSizes.f14);

  static TextStyle get nunitoMedium20 => nunitoSans.medium.size(FontSizes.f20);
  static TextStyle get nunitoMedium18 => nunitoSans.medium.size(FontSizes.f18);
  static TextStyle get nunitoMedium16 => nunitoSans.medium.size(FontSizes.f16);
  static TextStyle get nunitoMedium14 => nunitoSans.medium.size(FontSizes.f14);

  //Text Style montserrat regular
  static TextStyle get montserratRegular18 => montserrat.regular.size(FontSizes.f18);
  static TextStyle get montserratRegular16 => montserrat.regular.size(FontSizes.f16);
  static TextStyle get montserratRegular14 => montserrat.regular.size(FontSizes.f14);
  static TextStyle get montserratRegular12 => montserrat.regular.size(FontSizes.f12);
  static TextStyle get montserratRegular11 => montserrat.regular.size(FontSizes.f11);

  static TextStyle get nunitoSansRegular22 => nunitoSans.regular.size(FontSizes.f22);
  static TextStyle get nunitoSansRegular20 => nunitoSans.regular.size(FontSizes.f20);
  static TextStyle get nunitoSansRegular18 => nunitoSans.regular.size(FontSizes.f18);
  static TextStyle get nunitoSansRegular16 => nunitoSans.regular.size(FontSizes.f16);
  static TextStyle get nunitoSansRegular14 => nunitoSans.regular.size(FontSizes.f14);
    static TextStyle get nunitoSansRegular12 => nunitoSans.regular.size(FontSizes.f12);

  static TextStyle get latoRegular16 => lato.regular.size(FontSizes.f16);
  static TextStyle get latoRegular14 => lato.regular.size(FontSizes.f14);
  static TextStyle get latoRegular12 => lato.regular.size(FontSizes.f12);
  static TextStyle get latoRegular10 => lato.regular.size(FontSizes.f10);

  static TextStyle get interRegular24 => inter.regular.size(FontSizes.f24);
  static TextStyle get interRegular20 => inter.regular.size(FontSizes.f20);
  static TextStyle get interRegular18 => inter.regular.size(FontSizes.f18);
  static TextStyle get interRegular16 => inter.regular.size(FontSizes.f16);
  static TextStyle get interRegular14 => inter.regular.size(FontSizes.f14);
  static TextStyle get interRegular12 => inter.regular.size(FontSizes.f12);
  static TextStyle get interRegular10 => inter.regular.size(FontSizes.f10);
  static TextStyle get interRegular8 => inter.regular.size(FontSizes.f8);

  static TextStyle get rubikRegular14 => rubik.regular.size(FontSizes.f14);
  static TextStyle get rubikRegular12 => rubik.regular.size(FontSizes.f12);

  static TextStyle get robotoRegular18 => roboto.regular.size(FontSizes.f18);
  static TextStyle get robotoRegular16 => roboto.regular.size(FontSizes.f16);
  static TextStyle get robotoRegular14 => roboto.regular.size(FontSizes.f14);
  static TextStyle get robotoRegular12 => roboto.regular.size(FontSizes.f12);

  static TextStyle get josefinSansRegular12 => josefinSans.regular.size(FontSizes.f12);


  static TextStyle get publicSansRegular16 =>
      publicSans.regular.size(FontSizes.f16);
  static TextStyle get publicSansRegular14 =>
      publicSans.regular.size(FontSizes.f14);
  static TextStyle get publicSansRegular12 =>
      publicSans.regular.size(FontSizes.f12);
  static TextStyle get pubSansRegular10 => publicSans.regular.size(FontSizes.f10);

  static TextStyle get interLight14 => inter.light.size(FontSizes.f14);

  static TextStyle get rubikLight16 => rubik.light.size(FontSizes.f16);

  static TextStyle get rowdiesLight35 => rowdies.light.size(FontSizes.f35);
  static TextStyle get rowdiesLight25 => rowdies.light.size(FontSizes.f25);
  static TextStyle get montserratLight16 => montserrat.light.size(FontSizes.f16);

  static TextStyle get interLight12 => inter.extraLight.size(FontSizes.f12);


}
