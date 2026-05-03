enum Role { admin, member, owner }

class UserGroupSetting {
  final String groupId;
  final String userId;
  final Role role;
  final bool isMute;

  final int? lastReadMessageId;
  final bool isPinned;
  final bool isHidden;

  UserGroupSetting(
    this.groupId,
    this.userId,
    this.role,
    this.isMute, {
    this.lastReadMessageId,
    this.isPinned = false,
    this.isHidden = false,
  });
}