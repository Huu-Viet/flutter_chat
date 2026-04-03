import 'package:flutter_chat/features/call/data/dtos/peer_connection_params.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:convert';

class WebRtcManager implements IWebRtcManager {
  final String _roomId;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localMS;
  late Map<String, dynamic> _peerConnectionConfig;
  late List<Map<String, String>> _iceServers;
  final PeerConnectionParams _peerConnectionParams;
  // late FirebaseCallManager _firebaseCallManager;

  WebRtcManager(this._roomId, this._peerConnectionParams) {
    _iceServers = [
      {'urls': 'stun:23.21.150.121'},
      {'urls': 'stun:stun.l.google.com:19302'},
    ];
    _peerConnectionConfig = {
      'iceServers': _iceServers,
      'sdpSemantics': 'unified-plan',
    };
    // _firebaseCallManager = FirebaseCallManager();
  }

  @override
  Future<void> addIceCandidate(RTCIceCandidate candidate) {
    // TODO: implement addIceCandidate
    throw UnimplementedError();
  }

  @override
  Future<void> answer(String sender, MediaStream localStream, RtcCallDataDto callData) {
    // TODO: implement answer
    throw UnimplementedError();
  }

  @override
  Future<void> call(MediaStream localStream, Function(RtcCallDataDto p1) onCallData) {
    // TODO: implement call
    throw UnimplementedError();
  }

  @override
  Future<void> endCall() {
    // TODO: implement endCall
    throw UnimplementedError();
  }

  @override
  void onCallingPause() {
    // TODO: implement onCallingPause
  }

  @override
  void onCallingResume() {
    // TODO: implement onCallingResume
  }

  @override
  Future<void> onRemoteSessionReceived(RTCSessionDescription sessionDescription) {
    // TODO: implement onRemoteSessionReceived
    throw UnimplementedError();
  }

  @override
  Future<void> sendIceCandidate(RTCIceCandidate candidate, Function(RtcCallDataDto p1) onCallData) {
    // TODO: implement sendIceCandidate
    throw UnimplementedError();
  }

  @override
  Future<MediaStream> setCamera() {
    // TODO: implement setCamera
    throw UnimplementedError();
  }

}