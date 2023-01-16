
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
    callMap["callerId"] = call.callerId;
    callMap["callerName"] = call.callerName;
    callMap["callerImage"] = call.callerPic;
    callMap["receiverId"] = call.receiverId;
    callMap["receiverName"] = call.receiverName;
    callMap["receiverImage"] = call.receiverPic;
    callMap["channelId"] = call.channelId;
    callMap["hasDialled"] = call.hasDialled;
    callMap["isVideoCall"] = call.isVideoCall;
    callMap["timestamp"] = call.timestamp;
    return callMap;
  }

  Call.fromMap(Map callMap) {
    callerId = callMap["callerId"];
    callerName = callMap["callerName"];
    callerPic = callMap["callerImage"];
    receiverId = callMap["receiverId"];
    receiverName = callMap["receiverName"];
    receiverPic = callMap["receiverImage"];
    channelId = callMap["channelId"];
    hasDialled = callMap["hasDialled"];
    isVideoCall = callMap["isVideoCall"];
    timestamp = callMap["timestamp"];
  }
}
