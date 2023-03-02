import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:dartx/dartx_io.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../config.dart';

var loadingCtrl = Get.find<AppController>();

String trans(String val) {
  if (val.isNotEmpty) {
    return val.tr;
  }
  return val;
}

List arrayFilter(List val) {
  if (val.isNotEmpty) {
    List newArray = [];
    for (int i = 0; i < val.length; i++) {
      if (val[i] != null) {
        newArray.add(val[i]);
      }
    }
    return newArray;
  } else {
    return [];
  }

  //ex : helper.array_filter(data);
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() =>
      replaceAll(RegExp(' +'), ' ')
          .split(' ')
          .map((str) => str.toCapitalized())
          .join(' ');
}

//phone number split
String phoneNumberExtension(phoneNumber) {
  String phone = phoneNumber;
  if (phone.length > 10) {
    if (phone.contains(" ")) {
      phone = phone.replaceAll(" ", "");
    }
    if (phone.contains("-")) {
      phone = phone.replaceAll("-", "");
    }
    if (phone.contains("+")) {
      phone = phone.replaceAll("+91", "");
    }
    if (phone.contains(" ")) {
      phone = phone.replaceAll("  ", "");
    }
  }
  return phone;
}

Future<List<Contact>> getAllContacts() async {
  var contacts = (await FlutterContacts.getContacts(
      withPhoto: true, withProperties: true, withThumbnail: true));
  return contacts;
}

const double degrees2Radians = math.pi / 180.0;

/// Constant factor to convert and angle from radians to degrees.
const double radians2Degrees = 180.0 / math.pi;

/// Convert [radians] to degrees.
double degrees(double radians) => radians * radians2Degrees;

/// Convert [degrees] to radians.
double radians(double degrees) => degrees * degrees2Radians;

/// Interpolate between [min] and [max] with the amount of [a] using a linear
/// interpolation. The computation is equivalent to the GLSL function mix.
double mix(double min, double max, double a) => min + a * (max - min);

/// Do a smooth step (hermite interpolation) interpolation with [edge0] and
/// [edge1] by [amount]. The computation is equivalent to the GLSL function
/// smoothstep.
double smoothStep(double edge0, double edge1, double amount) {
  final t = ((amount - edge0) / (edge1 - edge0)).clamp(0.0, 1.0).toDouble();

  return t * t * (3.0 - 2.0 * t);
}

//learning dashboard bottom nav bar size
const double alphaOff = 0;
const double alphaOn = 1;
const int animDuration = 300;


String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) {
    return '0 B';
  }
  const List<String> suffixes = <String>[
    'B',
    'KB',
    'MB',
    'GB',
    'TB',
    'PB',
    'EB',
    'ZB',
  ];
  final int i = (math.log(bytes / 100) / math.log(1024)).floor();
  return '${(bytes / math.pow(1024, i)).toStringAsFixed(
      decimals)} ${suffixes[i]}';
}


String getVideoSize({required File file}) =>
    formatBytes(file.lengthSync(), 2);


final List colors = [
  const Color(0xffF98BAE),
  const Color(0xff72CCCF),
  const Color(0xffF4ABC4),
  const Color(0xff346751),
  const Color(0xffFFC947),
  const Color(0xff3282B8),
];

int getUnseenMessagesNumber(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> items) {
  int counter = 0;
  items
      .asMap()
      .entries
      .forEach((element) {
    if (!element.value.data()["isSeen"]) {
      counter++;
    }
  });
  return counter;
}

bool checkUserExist(phone) {
  bool isExist = false;
  log("appCtrl.userContactList : ${appCtrl.userContactList}");
  var contain = appCtrl.userContactList.where((element) {
    return element.phones.isNotEmpty ? phoneNumberExtension(
        element.phones[0].number.toString()) == phone : false;
  });
  log("contain : $contain");
  if (contain.isNotEmpty) {
    isExist = true;
  } else {
    isExist = false;
  }
  return isExist;
}