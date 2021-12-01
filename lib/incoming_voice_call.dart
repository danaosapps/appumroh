import 'dart:async';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_manager/flutter_audio_manager.dart';

void main() {
  runApp(IncomingVoiceCall(null, null, null));
}

class IncomingVoiceCall extends StatefulWidget {
  final context, string, opponentID;
  IncomingVoiceCall(this.context, this.string, this.opponentID);

  @override
  IncomingVoiceCallState createState() => IncomingVoiceCallState();
}

class IncomingVoiceCallState extends State<IncomingVoiceCall> with WidgetsBindingObserver {
  var channel = null;
  var SERVER = "xabber.org";
  var HOST = "139.162.240.38";
  var SENDER = "danaos";
  var RECEIVER = "danaos2";
  var PASSWORD = "HaloDunia123";
  var PORT = 5222;
  var XMPP_SERVER = "xabber.org";
  var XMPP_HOST = "139.162.240.38";
  var XMPP_PORT = 5222;
  var XMPP_SENDER_USER_ID = "";
  var XMPP_RECEIVER_USER_ID = "";
  var XMPP_MESSAGE_LISTENER = null;
  RTCPeerConnection? _peerConnection;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  var localRendererShown = false;
  var remoteRendererShown = false;
  MediaStream? _localStream;
  var callShown = true;
  var iceCandidates = [];
  var iceCandidateBuffered = true;
  var callAnswered = false;
  var acceptButtonShown = false;
  var totalSecondsShown = false;
  var totalSeconds = 0;
  var callTimer = null;

  final mediaConstraints = <String, dynamic>{
    'audio': true,
    'video': false
  };

  var configuration = <String, dynamic>{
    'iceServers': [
      {'urls':'stun:stun01.sipphone.com'},
      {'urls':'stun:stun.ekiga.net'},
      {'urls':'stun:stun.fwdnet.net'},
      {'urls':'stun:stun.ideasip.com'},
      {'urls':'stun:stun.iptel.org'},
      {'urls':'stun:stun.rixtelecom.se'},
      {'urls':'stun:stun.schlund.de'},
      {'urls':'stun:stun.l.google.com:19302'},
      {'urls':'stun:stun1.l.google.com:19302'},
      {'urls':'stun:stun2.l.google.com:19302'},
      {'urls':'stun:stun3.l.google.com:19302'},
      {'urls':'stun:stun4.l.google.com:19302'},
      {'urls':'stun:stunserver.org'},
      {'urls':'stun:stun.softjoys.com'},
      {'urls':'stun:stun.voiparound.com'},
      {'urls':'stun:stun.voipbuster.com'},
      {'urls':'stun:stun.voipstunt.com'},
      {'urls':'stun:stun.voxgratia.org'},
      {'urls':'stun:stun.xten.com'},
      {
        'urls': 'turn:numb.viagenie.ca',
        'credential': 'muazkh',
        'username': 'webrtc@live.com'
      },
      {
        'urls': 'turn:192.158.29.39:3478?transport=udp',
        'credential': 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
        'username': '28224511:1379330808'
      },
      {
        'urls': 'turn:192.158.29.39:3478?transport=tcp',
        'credential': 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
        'username': '28224511:1379330808'
      },
      {'urls': 'turn:49.50.10.47:3478',
        'username': 'test',
        'credential': 'test123'
      }
    ]
  };

  final offerSdpConstraints = <String, dynamic>{
    'mandatory': {
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': false,
    },
    'optional': [],
  };

  final loopbackConstraints = <String, dynamic>{
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': false},
    ],
  };

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "incoming_voice_call";
    });
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();
    //await FlutterAudioManager.changeToHeadphones();
    final _channel = WebSocketChannel.connect(
      Uri.parse('ws://'+Global.WS_SERVER+':8080?user_id='+Global.USER_ID.toString()),
    );
    setState(() {
      channel = _channel;
      XMPP_SENDER_USER_ID = Global.USER_ID.toString();
      XMPP_RECEIVER_USER_ID = widget.opponentID.toString();
    });
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    await initializePC();
    sendMessage(jsonEncode({
      "type": "incoming_voice_call_ack"
    }));
  }

  void _onSignalingState(RTCSignalingState state) {
    print("UPDATED STATE _onSignalingState:");
    print(state);
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    print("UPDATED STATE _onIceGatheringState:");
    print(state);
    if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
      Timer timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        setState(() {
          totalSeconds++;
        });
      });
      setState(() {
        totalSecondsShown = true;
        totalSeconds = 0;
        callTimer = timer;
      });
    }
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    print("UPDATED STATE _onIceConnectionState:");
    print(state);

  }

  void _onPeerConnectionState(RTCPeerConnectionState state) {
    print("UPDATED STATE _onPeerConnectionState:");
    print(state);
  }

  void _onAddStream(MediaStream stream) async {
    print('UPDATED STATE New stream: ');
    print(stream.id);
    _remoteRenderer.srcObject = stream;
    setState(() {
      remoteRendererShown = true;
    });
    await _peerConnection!.addStream(stream);
  }

  void _onRemoveStream(MediaStream stream) {
    print("UPDATED STATE _onRemoveStream:");
    _remoteRenderer.srcObject = null;
  }

  void _onCandidate(RTCIceCandidate candidate) {
    print('UPDATED STATE onCandidate: ${candidate.candidate}, sdpMid: '+candidate.sdpMid!);
    if (candidate != null && candidate.candidate != null) {
      _peerConnection?.addCandidate(candidate);
      if (iceCandidateBuffered) {
        iceCandidates.add({
          "candidate": candidate.candidate,
          "sdpMid": candidate.sdpMid,
          "sdpMLineIndex": candidate.sdpMlineIndex.toString()
        });
      } else {
        sendMessage(jsonEncode({
          "type": "ice_candidate",
          "ice_candidate": {
            "candidate": candidate.candidate,
            "sdpMid": candidate.sdpMid,
            "sdpMLineIndex": candidate.sdpMlineIndex.toString()
          }
        }));
      }
    }
  }

  void _onTrack(RTCTrackEvent event) {
    print('UPDATED STATE onTrack, kind: '+event.track.kind!);
    print(event);
  }

  void _onAddTrack(MediaStream stream, MediaStreamTrack track) async {
    print("UPDATED STATE _onAddTrack, kind: "+track.kind!);
    await _peerConnection!.addStream(stream);
  }

  void _onRemoveTrack(MediaStream stream, MediaStreamTrack track) {
    print("UPDATED STATE _onRemoveTrack, kind: "+track.kind!);
  }

  void _onRenegotiationNeeded() {
    print('UPDATED STATE RenegotiationNeeded');
  }

  Future<void> initializePC() async {
    _peerConnection = await createPeerConnection(configuration, loopbackConstraints);
    _peerConnection!.onSignalingState = _onSignalingState;
    _peerConnection!.onIceGatheringState = _onIceGatheringState;
    _peerConnection!.onIceConnectionState = _onIceConnectionState;
    _peerConnection!.onConnectionState = _onPeerConnectionState;
    _peerConnection!.onIceCandidate = _onCandidate;
    _peerConnection!.onRenegotiationNeeded = _onRenegotiationNeeded;
    _peerConnection!.onAddStream = _onAddStream;
    _peerConnection!.onRemoveStream = _onRemoveStream;
    _peerConnection!.onAddTrack = _onAddTrack;
    _peerConnection!.onTrack = _onTrack;
    _peerConnection!.onRemoveTrack = _onRemoveTrack;
  }

  Future<void> sendMessage(message) async {
    channel.sink.add(jsonEncode({
      "from": XMPP_SENDER_USER_ID,
      "to": XMPP_RECEIVER_USER_ID,
      "message": message
    }));
  }

  void messageReceived(context, message) async {
    var obj = jsonDecode(jsonDecode(message)['message'].toString());
    print("Message received:");
    print(obj);
    var type = obj['type'].toString();
    if (type == "offer") {
      await _peerConnection!.setRemoteDescription(RTCSessionDescription(obj['sdp'].toString(), type));
      await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
      var availableDevices = await navigator.mediaDevices.enumerateDevices();
      var audioConstraints = {};
      for (var device in availableDevices) {
        print("DEVICE KIND: "+device.kind!+", ID: "+device.deviceId);
      }
      for (var device in availableDevices) {
        if (device.kind == 'audioinput') {
          setState(() {
            audioConstraints = {'deviceId': device.deviceId};
          });
        }
      }
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': audioConstraints,
        'video': false
      });
      _localRenderer.srcObject = _localStream;
      setState(() {});
      setState(() {
        acceptButtonShown = true;
      });
      var description = await _peerConnection!.createAnswer();
      var sdp = description.sdp;
      print('sdp = $sdp');
      await _peerConnection!.setLocalDescription(description);
      sendMessage(jsonEncode({
        "type": description.type,
        "sdp": sdp
      }));
    } else if (type == "ice_candidates") {
      var candidates = obj['ice_candidates'];
      for (var i=0; i<candidates.length; i++) {
        var candidate = candidates[i];
        _peerConnection?.addCandidate(
            RTCIceCandidate(candidate['candidate'].toString(),
                candidate['sdpMid'].toString(),
                int.parse(candidate['sdpMLineIndex'].toString())));
      }
      iceCandidateBuffered = false;
      sendMessage(jsonEncode({
        "type": "ice_candidates",
        "ice_candidates": iceCandidates
      }));
    } else if (type == "ice_candidate") {
      var candidate = obj['ice_candidate'];
      _peerConnection?.addCandidate(
          RTCIceCandidate(candidate['candidate'].toString(),
              candidate['sdpMid'].toString(),
              int.parse(candidate['sdpMLineIndex'].toString())));
    } else if (type == "call_cancelled") {
      Future.delayed(Duration.zero, () {
        Navigator.pop(context);
      });
      if (_peerConnection != null) {
        _peerConnection!.close();
      }
    }
  }

  void answerCall() async {
    var description = await _peerConnection!.createAnswer();
    var sdp = description.sdp;
    print('sdp = $sdp');
    await _peerConnection!.setLocalDescription(description);
    sendMessage(jsonEncode({
      "type": description.type,
      "sdp": sdp
    }));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Container(
        width: width,
        height: height,
        child: Stack(
            children: [
              Container(
                  width: width,
                  height: height,
                  child: Image.asset("assets/images/call_bg.jpg", width: width, height: height, fit: BoxFit.cover)
              ),
              Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                width: 150,
                                height: 150,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(75),
                                    child: Image.network(Global.USERDATA_URL+Global.USER_INFO['photo'].toString(),
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover)
                                )
                            ),
                            SizedBox(height: 40),
                            (() {
                              if (totalSecondsShown) {
                                return Text(Global.formatDuration(Duration(seconds: totalSeconds)),
                                    style: TextStyle(color: Colors.white, fontSize: 18));
                              } else {
                                return Text(widget.string.text99, style: TextStyle(color: Colors.white, fontSize: 18));
                              }
                            }())
                          ]
                      )
                  )
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 50, left: 40, right: 40),
                      child: (() {
                        if (callAnswered) {
                          return Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                  color: Color(0xffe74c3c),
                                  borderRadius: BorderRadius.circular(35)
                              ),
                              child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () async {
                                    await sendMessage(jsonEncode({
                                      "type": "call_rejected"
                                    }));
                                    if (_peerConnection != null) {
                                      await _peerConnection!.close();
                                    }
                                    if (callTimer != null) {
                                      callTimer.cancel();
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Center(
                                      child: Icon(Ionicons.call, size: 30, color: Colors.white)
                                  )
                              )
                          );
                        } else {
                          if (acceptButtonShown) {
                            return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          color: Color(0xffe74c3c),
                                          borderRadius: BorderRadius.circular(35)
                                      ),
                                      child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () async {
                                            await sendMessage(jsonEncode({
                                              "type": "call_rejected"
                                            }));
                                            Navigator.pop(context);
                                          },
                                          child: Center(
                                              child: Icon(Ionicons.call, size: 30, color: Colors.white)
                                          )
                                      )
                                  ),
                                  Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          color: Color(0xff2ecc71),
                                          borderRadius: BorderRadius.circular(35)
                                      ),
                                      child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            setState(() {
                                              callAnswered = true;
                                            });
                                            answerCall();
                                          },
                                          child: Center(
                                              child: Icon(Ionicons.call, size: 30, color: Colors.white)
                                          )
                                      )
                                  )
                                ]
                            );
                          } else {
                            return Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Color(0xffe74c3c),
                                    borderRadius: BorderRadius.circular(35)
                                ),
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      await sendMessage(jsonEncode({
                                        "type": "call_rejected"
                                      }));
                                      Navigator.pop(context);
                                    },
                                    child: Center(
                                        child: Icon(Ionicons.call, size: 30, color: Colors.white)
                                    )
                                )
                            );
                          }
                        }
                      }())
                  )
              ),
              (() {
                if (channel == null) {
                  return SizedBox.shrink();
                } else {
                  return StreamBuilder(
                      stream: channel.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          messageReceived(context, snapshot.data);
                        }
                        return SizedBox.shrink();
                      }
                  );
                }
              }())
            ]
        )
    )));
  }
}
