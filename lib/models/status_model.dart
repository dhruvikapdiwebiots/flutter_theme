
class Status {
  String? uid;
  String? username;
  String? phoneNumber;
  List<PhotoUrl>? photoUrl;
  String? createdAt;
  String? profilePic;
  bool? isSeenByOwn;

  Status(
      {this.uid,
        this.username,
        this.phoneNumber,
        this.photoUrl,
        this.createdAt,
        this.profilePic,
        this.isSeenByOwn});

  Status.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    username = json['username'];
    phoneNumber = json['phoneNumber'];
    createdAt = json['createdAt'];
    profilePic = json['profilePic'];
    isSeenByOwn = json['isSeenByOwn'];
    if (json['photoUrl'] != null) {
      photoUrl = <PhotoUrl>[];
      json['photoUrl'].forEach((v) {
        photoUrl!.add(PhotoUrl.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['username'] = username;
    data['phoneNumber'] = phoneNumber;
    data['createdAt'] = createdAt;
    data['profilePic'] = profilePic;
    data['isSeenByOwn'] = isSeenByOwn;
    if (photoUrl != null) {
      data['photoUrl'] = photoUrl!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PhotoUrl {
  String? image;
  String? timestamp;
  bool? isExpired;

  PhotoUrl({this.image, this.timestamp, this.isExpired});

  PhotoUrl.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    timestamp = json['timestamp'];
    isExpired = json['isExpired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['timestamp'] = timestamp;
    data['isExpired'] = isExpired;
    return data;
  }
}
