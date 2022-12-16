
import '../../../config.dart';

/*
import 'package:agora_uikit/agora_uikit.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  AgoraClient? client;
  String baseUrl = 'https://whatsapp-clone-rrr.herokuapp.com';

  @override
  void initState() {
    super.initState();
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: "01254a6c76514e4787628f4b6bdc1786",
        channelName: "d4cafc0cc7d3466d9b51b9d604d971ff",

      ),
    );
    initAgora();
  }

  makeCall(){
    */
/*
    Call senderCallData = Call(
      callerId: auth.currentUser!.uid,
      callerName: value!.name,
      callerPic: value.profilePic,
      receiverId: receiverUid,
      receiverName: receiverName,
      receiverPic: receiverProfilePic,
      callId: callId,
      hasDialled: true,
    );

    Call recieverCallData = Call(
      callerId: auth.currentUser!.uid,
      callerName: value.name,
      callerPic: value.profilePic,
      receiverId: receiverUid,
      receiverName: receiverName,
      receiverPic: receiverProfilePic,
      callId: callId,
      hasDialled: false,
    );
    if (isGroupChat) {
      callRepository.makeGroupCall(senderCallData, context, recieverCallData);
    } else {
      callRepository.makeCall(senderCallData, context, recieverCallData);
    }*//*

  }

  void initAgora() async {
    await client!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: client == null
          ?  Container()
          : SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(client: client!),
            AgoraVideoButtons(
              client: client!,
              disconnectButtonChild: IconButton(
                onPressed: () async {
                  await client!.engine.leaveChannel();
                 */
/* ref.read(callControllerProvider).endCall(
                    widget.call.callerId,
                    widget.call.receiverId,
                    context,
                  );
                  Navigator.pop(context);*//*

                },
                icon: const Icon(Icons.call_end),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class Call {
  final String callerId;
  final String callerName;
  final String callerPic;
  final String receiverId;
  final String receiverName;
  final String receiverPic;
  final String callId;
  final bool hasDialled;
  Call({
    required this.callerId,
    required this.callerName,
    required this.callerPic,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPic,
    required this.callId,
    required this.hasDialled,
  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPic': callerPic,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPic': receiverPic,
      'callId': callId,
      'hasDialled': hasDialled,
    };
  }

  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerPic: map['callerPic'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      receiverPic: map['receiverPic'] ?? '',
      callId: map['callId'] ?? '',
      hasDialled: map['hasDialled'] ?? false,
    );
  }
}
*/

class CallScreen extends StatelessWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
