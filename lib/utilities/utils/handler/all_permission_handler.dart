import 'dart:async';

import 'package:flutter_theme/models/position_item.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../config.dart';

class PermissionHandlerController extends GetxController{
  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';
  final GeolocatorPlatform geoLocatorPlatform = GeolocatorPlatform.instance;
  final List<PositionItem> _positionItems = <PositionItem>[];

  Future<bool> handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await geoLocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      updatePositionList(
        PositionItemType.log,
        _kLocationServicesDisabledMessage,
      );
      return false;
    }

    permission = await geoLocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geoLocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        updatePositionList(
          PositionItemType.log,
          _kPermissionDeniedMessage,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {

      updatePositionList(
        PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );
      return false;
    }
    updatePositionList(
      PositionItemType.log,
      _kPermissionGrantedMessage,
    );
    return true;
  }

  void updatePositionList(PositionItemType type, String displayValue) {
    _positionItems.add(PositionItem(type, displayValue));
    update();
  }

  static Future<bool> checkAndRequestPermission(Permission permission) {
    Completer<bool> completer = Completer<bool>();
    permission.request().then((status) {
      if (status != PermissionStatus.granted) {
        permission.request().then((status) {
          bool granted = status == PermissionStatus.granted;
          completer.complete(granted);
        });
      } else {
        completer.complete(true);
      }
    });
    return completer.future;
  }
}