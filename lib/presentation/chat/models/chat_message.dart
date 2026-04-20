class ChatMessage {
  final String? text;
  final String? imagePath;
  final String? mediaId;
  final String? stickerId;
  final String type;
  final bool isSentByMe;
  final String? senderId;
  final DateTime timestamp;
  final bool isUploading;
  final bool isResolvingImage;
  final String? localId;
  final String? serverId;
  final String? conversationAvatarUrl;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  ChatMessage({
    this.text,
    this.imagePath,
    this.mediaId,
    this.stickerId,
    this.type = 'text',
    required this.isSentByMe,
    this.senderId,
    required this.timestamp,
    this.isUploading = false,
    this.isResolvingImage = false,
    this.localId,
    this.serverId,
    this.conversationAvatarUrl,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  ChatMessage copyWith({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return ChatMessage(
      text: text,
      imagePath: imagePath,
      mediaId: mediaId,
      stickerId: stickerId,
      type: type,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isUploading: isUploading,
      isResolvingImage: isResolvingImage,
      localId: localId,
      serverId: serverId,
      conversationAvatarUrl: conversationAvatarUrl,
      isFirstInGroup: isFirstInGroup ?? this.isFirstInGroup,
      isLastInGroup: isLastInGroup ?? this.isLastInGroup,
    );
  }
}
