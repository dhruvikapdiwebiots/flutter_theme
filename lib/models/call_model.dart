
//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

class Call {
  String? callerId;
  String? callerName;
  String? callerPic;
  String? receiverId;
  String? receiverName;
  String? receiverPic;
  String? channelId;
  int? timestamp;
  bool? hasDialled;
  bool? isVideoCall;

  Call({
    this.callerId,
    this.callerName,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.receiverPic,
    this.timestamp,
    this.channelId,
    this.hasDialled,
    this.isVideoCall,
  });

  // to map
  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = {};
    callMap["caller_id"] = call.callerId;
    callMap["caller_name"] = call.callerName;
    callMap["caller_pic"] = call.callerPic;
    callMap["receiver_id"] = call.receiverId;
    callMap["receiver_name"] = call.receiverName;
    callMap["receiver_pic"] = call.receiverPic;
    callMap["channel_id"] = call.channelId;
    callMap["has_dialled"] = call.hasDialled;
    callMap["isVideoCall"] = call.isVideoCall;
    callMap["timestamp"] = call.timestamp;
    return callMap;
  }

  Call.fromMap(Map callMap) {
    callerId = callMap["caller_id"];
    callerName = callMap["caller_name"];
    callerPic = callMap["caller_pic"];
    receiverId = callMap["receiver_id"];
    receiverName = callMap["receiver_name"];
    receiverPic = callMap["receiver_pic"];
    channelId = callMap["channel_id"];
    hasDialled = callMap["has_dialled"];
    isVideoCall = callMap["isVideoCall"];
    timestamp = callMap["timestamp"];
  }
}
