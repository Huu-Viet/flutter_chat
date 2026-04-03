class PeerConnectionParams {
  final bool videoCallEnabled;
  final bool loopback;
  final int videoWidth;
  final int videoHeight;
  final int videoFps;
  final int videoStartBitrate;
  final String videoCodec;
  final bool videoCodecHwAcceleration;
  final int audioStartBitrate;
  final String audioCodec;
  final bool cpuOveruseDetection;

  const PeerConnectionParams({
    required this.videoCallEnabled,
    required this.loopback,
    required this.videoWidth,
    required this.videoHeight,
    required this.videoFps,
    required this.videoStartBitrate,
    required this.videoCodec,
    required this.videoCodecHwAcceleration,
    required this.audioStartBitrate,
    required this.audioCodec,
    required this.cpuOveruseDetection,
  });

  factory PeerConnectionParams.defaultConfig() {
    return const PeerConnectionParams(
      videoCallEnabled: true,
      loopback: false,
      videoWidth: 640,
      videoHeight: 480,
      videoFps: 30,
      videoStartBitrate: 1000,
      videoCodec: 'VP9',
      videoCodecHwAcceleration: true,
      audioStartBitrate: 32,
      audioCodec: 'opus',
      cpuOveruseDetection: true,
    );
  }

  // Convert to getUserMedia constraints
  Map<String, dynamic> toMediaConstraints() {
    return {
      'audio': true,
      'video': videoCallEnabled ? {
        'mandatory': {
          'minWidth': videoWidth.toString(),
          'minHeight': videoHeight.toString(),
          'minFrameRate': videoFps.toString(),
          'maxWidth': videoWidth.toString(),
          'maxHeight': videoHeight.toString(),
          'maxFrameRate': videoFps.toString(),
        },
        'facingMode': 'user',
        'optional': [],
      } : false,
    };
  }

  // Convert to PeerConnection config
  Map<String, dynamic> toPeerConnectionConfig(List<Map<String, String>> iceServers) {
    return {
      'iceServers': iceServers,
      'sdpSemantics': 'unified-plan',
      'rtcpMuxPolicy': 'require',
      'bundlePolicy': 'max-bundle',
    };
  }
}