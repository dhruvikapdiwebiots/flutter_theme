import 'dart:convert';
import 'dart:math';

import '../config.dart';

Helper helper = Helper();

final _storage = GetStorage();
var loadingCtrl = Get.find<LoadingController>();

class Helper {
  Future<dynamic> getStorage(String name) async {
    dynamic info = await _storage.read(name) ?? '';
    return info != '' ? json.decode(info) : info;
  }

  Future<dynamic> writeStorage(String key, dynamic value) async {
    dynamic object = value != null ? json.encode(value) : value;
    return await _storage.write(key, object);
  }

  dynamic removeSpecificKeyStorage(String key) {
    _storage.remove(key);
  }

  clearStorage() {
    _storage.erase();
  }

  getRandomColor() {
    return Colors.primaries[Random().nextInt(Colors.primaries.length)];
  }


  getToast(String message, Color color) {
    Get.rawSnackbar(message: message, backgroundColor: color, duration: const Duration(milliseconds: 1000));
  }


  void showLoading() => loadingCtrl.showLoading();

  void hideLoading() => loadingCtrl.hideLoading();
}
