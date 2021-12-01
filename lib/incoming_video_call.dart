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
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(IncomingVideoCall(null, null, null));
}

class IncomingVideoCall extends StatefulWidget {
  final context, string, opponentID;
  IncomingVideoCall(this.context, this.string, this.opponentID);

  @override
  IncomingVideoCallState createState() => IncomingVideoCallState();
}

class IncomingVideoCallState extends State<IncomingVideoCall> with WidgetsBindingObserver {
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
  AudioPlayer player = AudioPlayer();

  final mediaConstraints = <String, dynamic>{
    'audio': true,
    'video': {
      'facingMode': 'user',
      'optional': [],
    }
  };
  /*final mediaConstraints = <String, dynamic>{
    'audio': true,
    'video': {
      'mandatory': {
        'minWidth':
        '640', // Provide your own width, height and frame rate here
        'minHeight': '480',
        'minFrameRate': '30',
      },
      'facingMode': 'user',
      'optional': [],
    }
  };*/

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
      'offerToReceiveVideo': true,
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
      Global.CURRENT_SCREEN = "incoming_video_call";
    });
    await player.play("file:///android_asset/ringtone.mp3", isLocal: true);
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
  }

  void _onSignalingState(RTCSignalingState state) {
    print("UPDATED STATE _onSignalingState:");
    print(state);
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    print("UPDATED STATE _onIceGatheringState:");
    print(state);
    if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
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
    if (event.track.kind == 'video') {
      _remoteRenderer.srcObject = event.streams[0];
    }
  }

  void _onAddTrack(MediaStream stream, MediaStreamTrack track) async {
    print("UPDATED STATE _onAddTrack, kind: "+track.kind!);
    if (track.kind == 'video') {
      _remoteRenderer.srcObject = stream;
    }
    await _peerConnection!.addStream(stream);
  }

  void _onRemoveTrack(MediaStream stream, MediaStreamTrack track) {
    print("UPDATED STATE _onRemoveTrack, kind: "+track.kind!);
    if (track.kind == 'video') {
      _remoteRenderer.srcObject = null;
    }
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
      var availableDevices = await navigator.mediaDevices.enumerateDevices();
      for (var device in availableDevices) {
        if (device.kind == 'videoinput') {
          _localStream = await navigator.mediaDevices.getUserMedia({
            'audio': true,
            'video': {
              'deviceId': {'exact': device.deviceId},
              'facingMode': 'user',
              'optional': [],
            }
          });
          _localRenderer.srcObject = _localStream;
          setState(() {});
          setState(() {
            localRendererShown = true;
          });
          await _peerConnection!.addStream(_localStream!);
          break;
        }
      }
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
    await player.stop();
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
              Container(width: width, height: height, child: RTCVideoView(_remoteRenderer)),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(width: 150, height: 220,
                    margin: EdgeInsets.only(right: 10, bottom: 10),
                    child: RTCVideoView(_localRenderer, mirror: true)),
              ),
              /*Align(
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
                            Text(widget.string.text99, style: TextStyle(color: Colors.white, fontSize: 18))
                          ]
                      )
                  )
              ),*/
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
                                    /*await sendMessage(jsonEncode({
                                      "type": "call_rejected"
                                    }));*/
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
