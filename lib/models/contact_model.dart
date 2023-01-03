
import 'package:flutter/services.dart';

class ContactModel {
  String? title;
  List<UserContactModel>? userTitle;

  ContactModel(
      {this.title,
        this.userTitle});

  ContactModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['userTitle'] != null) {
      userTitle = <UserContactModel>[];
      json['userTitle'].forEach((v) {
        userTitle!.add(UserContactModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    if (userTitle != null) {
      data['userTitle'] = userTitle!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserContactModel {
  String? uid;
  String? username;
  String? phoneNumber;
  String? image;
  Uint8List? contactImage;
  bool? isRegister;

  UserContactModel(
      {this.uid,
        this.username,
        this.phoneNumber,
        this.image,
        this.contactImage,
        this.isRegister});

  UserContactModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    username = json['username'];
    phoneNumber = json['phoneNumber'];
    image = json['image'];
    contactImage = json['contactImage'];
    isRegister = json['isRegister'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['username'] = username;
    data['phoneNumber'] = phoneNumber;
    data['image'] = image;
    data['contactImage'] = contactImage;
    data['isRegister'] = isRegister;
    return data;
  }
}
