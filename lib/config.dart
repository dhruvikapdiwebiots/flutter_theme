import 'config.dart';
export 'package:get_storage/get_storage.dart';

export 'package:get/get.dart';
export 'package:flutter/material.dart';
export 'package:google_fonts/google_fonts.dart';
export 'package:font_awesome_flutter/font_awesome_flutter.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'utilities/index.dart';
export 'common/theme/index.dart';
export '../../common/config.dart';
export 'common/theme/index.dart';
export 'common/language/index.dart';
export '../../routes/index.dart';
export 'extensions/spacing.dart';
export '../widgets/directionality_rtl.dart';
export 'extensions/text_extension.dart';
export 'extensions/text_span_extension.dart';
export 'extensions/textstyle_extensions.dart';
export 'extensions/widget_extension.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'controllers/common_controller/app_controller.dart';
export '../../../controllers/index.dart';
export 'routes/screen_list.dart';
export 'widgets/common_button.dart';
export '../../models/index.dart';
export 'pages/auth_pages/intro/layouts/page_pop.dart';
export 'pages/index.dart';
export 'widgets/common_text_box.dart';
export 'pages/plugin_route.dart';

final appCtrl = Get.isRegistered<AppController>()
    ? Get.find<AppController>()
    : Get.put(AppController());

final firebaseCtrl = Get.isRegistered<FirebaseCommonController>()
    ? Get.find<FirebaseCommonController>()
    : Get.put(FirebaseCommonController());

