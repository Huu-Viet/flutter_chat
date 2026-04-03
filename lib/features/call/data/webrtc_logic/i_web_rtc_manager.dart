import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class IWebRtcManager {
  Future<MediaStream> setCamera();
  Future<void> call(MediaStream localStream, Function(RtcCallDataDto) onCallData);
  Future<void> answer(String sender, MediaStream localStream, RtcCallDataDto callData);
  Future<void> onRemoteSessionReceived(RTCSessionDescription sessionDescription);
  Future<void> addIceCandidate(RTCIceCandidate candidate);
  Future<void> sendIceCandidate(RTCIceCandidate candidate, Function(RtcCallDataDto) onCallData);
  void onCallingPause();
  void onCallingResume();
  Future<void> endCall();
}