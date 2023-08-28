
import 'package:flutter/services.dart';

class UserContactModel {
  String? uid;
  String? username;
  String? phoneNumber;
  String? image;
  String? description;
  Uint8List? contactImage;
  bool? isRegister;

  UserContactModel(
      {this.uid,
        this.username,
        this.phoneNumber,
        this.image,
        this.description,
        this.contactImage,
        this.isRegister});

  UserContactModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    username = json['username'];
    phoneNumber = json['phoneNumber'];
    image = json['image'];
    description = json['description'];
    contactImage = json['contactImage'];
    isRegister = json['isRegister'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['username'] = username;
    data['phoneNumber'] = phoneNumber;
    data['image'] = image;
    data['description'] = description;
    data['contactImage'] = contactImage;
    data['isRegister'] = isRegister;
    return data;
  }
}
