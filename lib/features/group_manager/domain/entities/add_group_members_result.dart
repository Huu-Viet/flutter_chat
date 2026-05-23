class AddGroupMembersResult {
  final bool success;
  final bool requiresApproval;

  const AddGroupMembersResult({
    required this.success,
    required this.requiresApproval,
  });
}
