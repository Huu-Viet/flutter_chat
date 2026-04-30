enum CallActionType {
  accepted,
  declined,
  ended,
}

class CallAction {
  final String callId;
  final CallActionType type;

  CallAction({
    required this.callId,
    required this.type,
  });


  factory CallAction.accepted(String callId) =>
      CallAction(callId: callId, type: CallActionType.accepted);

  factory CallAction.declined(String callId) =>
      CallAction(callId: callId, type: CallActionType.declined);

  factory CallAction.ended(String callId) =>
      CallAction(callId: callId, type: CallActionType.ended);
}