part of 'message.dart';

class ContactCardMessage extends Message {
  final String cardType;
  final String clientMessageId;
  final String contactUserId;

  ContactCardMessage({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.offset,
    required super.isDeleted,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.reactions,
    super.isRevoked,
    super.forwardInfo,
    required this.cardType,
    required this.clientMessageId,
    required this.contactUserId,
  });

  @override
  String get content => '';

  @override
  String get type => 'contact_card';

}