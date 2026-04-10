12. WebSocket — Realtime Gateway
Server: ws://localhost:3002
Transport: Socket.IO (hỗ trợ reconnect tự động)
Namespaces: /chat và /call (2 namespace độc lập)
Authentication: 2-phase (kết nối → authenticate)

Kết nối và xác thực
Bước 1: Kết nối Socket.IO
// Kết nối namespace /chat
const chatSocket = io('ws://localhost:3002/chat', {
  // Truyền token ngay trong auth object (ưu tiên nhất)
  auth: { token: 'Bearer <JWT>' },
  // Hoặc truyền qua query param
  // query: { token: '<JWT>' }
  reconnectionAttempts: Infinity,
  reconnectionDelay: 1000,
});

// Kết nối namespace /call
const callSocket = io('ws://localhost:3002/call', {
  auth: { token: 'Bearer <JWT>' }
});
Bước 2: Xác thực (bắt buộc trong 30 giây sau khi kết nối)
chatSocket.emit('authenticate', {
  token: '<JWT_TOKEN>',
  deviceId: 'device-unique-id',
  deviceType: 'web'  // 'web' | 'mobile' | 'desktop'
});

chatSocket.on('authenticated', (data) => {
  console.log('Authenticated:', data.userId, data.socketId);
  // Sau bước này: presence = ONLINE, đã join room user:{userId}
});
Nếu không xác thực trong 30 giây, server tự động ngắt kết nối.

Namespace /chat — Sự kiện từ client gửi lên server



Event
Payload
Mô tả




authenticate
{ token, deviceId?, deviceType? }
Xác thực socket, bắt buộc trước mọi event khác


conversation:join
{ conversationId }
Vào phòng nhận tin realtime


conversation:leave
{ conversationId }
Rời phòng conversation


message:send
{ conversationId, content, type?, replyToMessageId?, metadata?, clientMessageId? }
Gửi tin nhắn qua WebSocket


typing:start
{ conversationId }
Bắt đầu gõ phím (broadcast cho members)


typing:stop
{ conversationId }
Dừng gõ phím


conversation:update_seen_cursor
{ conversationId, upToOffset }
Cập nhật con trỏ đã đọc


conversation:update_delivered_cursor
{ conversationId, upToOffset }
Cập nhật con trỏ đã nhận


message:get_status
{ messageId }
Hỏi trạng thái tin nhắn


heartbeat
(không có payload)
Giữ kết nối sống, cập nhật presence (gọi mỗi 30s)




Namespace /chat — Sự kiện server broadcast xuống client



Event
Nguồn
Payload mẫu
Mô tả




message:new
Tin nhắn mới
{ messageId, conversationId, senderId, offset }
Broadcast cho tất cả người đang join phòng conversation đó


message:saved
Tin đã lưu (chỉ sender)
{ messageId, conversationId, offset }
Xác nhận tin nhắn đã lưu, dùng để map clientMessageId → messageId và lấy offset


message:notify
Tin nhắn mới (batch 80ms)
{ conversationId, latestOffset }
Thông báo cho member không đang active trong phòng — dùng để cập nhật badge unread


message:edited
Tin bị sửa nội dung
{ messageId, conversationId, content, editedAt }
Cập nhật nội dung tin nhắn trong UI


message:deleted
Tin bị xóa
{ messageId, conversationId }
Đánh dấu tin nhắn là đã xóa trong UI


message:updated
Attachment đổi trạng thái
{ messageId, conversationId, mediaStatus }
File xử lý xong — cập nhật trạng thái file trong tin nhắn


message:queued
Xác nhận nhận sự kiện
{ clientMessageId, messageId }
Server nhận được message:send, đã xếp vào hàng xử lý


message:rejected
ChatCore từ chối
{ clientMessageId, code, reason }
Lỗi nghiệp vụ — hiển thị lỗi, xóa optimistic UI


message:error
Lỗi hệ thống
{ clientMessageId, error }
Lỗi kỹ thuật


typing:started
Ai đó đang gõ
{ conversationId, userId }
Broadcast cho cả phòng — hiển thị "đang nhập..."


typing:stopped
Dừng gõ
{ conversationId, userId }
Ẩn chỉ báo "đang nhập..."


user:online
Bạn bè vừa online
{ userId }
Cập nhật trạng thái online trong danh sách bạn bè


user:offline
Bạn bè vừa offline
{ userId, lastSeen }
Cập nhật trạng thái offline và thời điểm cuối hoạt động


conversation:member-added
Thành viên mới
{ conversationId, userId, addedBy }
Cập nhật danh sách thành viên


conversation:member-removed
Thành viên bị xóa
{ conversationId, userId, removedBy }
Xóa khỏi phòng, cập nhật UI


conversation:removed
Bị xóa khỏi nhóm
{ conversationId }
Server force-leave socket — xóa conversation khỏi danh sách


conversation:updated
Thông tin kênh thay đổi
{ conversationId, changes, updatedBy?, timestamp? }
Tên, mô tả, hoặc avatar bị thay đổi — client gọi GET /conversations/:id để lấy avatarUrl mới (presigned URL không có trong payload)


cursor:seen_updated
Xác nhận
{ conversationId, upToOffset }
Cập nhật seen cursor thành công


cursor:delivered_updated
Xác nhận
{ conversationId, upToOffset }
Cập nhật delivered cursor thành công


heartbeat:ack
Phản hồi heartbeat
{ timestamp }
Xác nhận kết nối vẫn sống




Namespace /call — Sự kiện từ client gửi lên server



Event
Payload
Rate limit (mỗi socket)
Mô tả




authenticate
{ token }
—
Xác thực (giống /chat)


meeting:start
{ conversationId, orgId, allowWaitingRoom? }
20 event/10s
Bắt đầu cuộc gọi qua WebSocket


meeting:get_active
{ conversationId }
20 event/10s
Hỏi cuộc gọi đang diễn ra trong conversation


meeting:join
{ conversationId }
20 event/10s
Yêu cầu tham gia cuộc gọi


meeting:approve_waiting
{ meetingId, userId }
20 event/10s
Duyệt người đang chờ vào phòng


meeting:reject_waiting
{ meetingId, userId, reason? }
20 event/10s
Từ chối người đang chờ


meeting:leave
{ meetingId }
20 event/10s
Rời cuộc gọi


meeting:end
{ meetingId }
20 event/10s
Kết thúc cuộc gọi


meeting:media_state
{ meetingId, micOn, cameraOn, screenSharing }
40 event/10s
Cập nhật trạng thái mic/camera


meeting:snapshot
{ meetingId }
60 event/10s
Lấy danh sách người đang trong phòng qua WebSocket


meeting:hand_raise
{ meetingId, raised }
20 event/10s
Giơ tay / hạ tay


meeting:invite
{ meetingId, userIds[] }
20 event/10s
Mời thêm người


meeting:moderate
{ meetingId, targetUserId, action, reason? }
20 event/10s
Kiểm soát người tham gia


webrtc:offer
{ meetingId, targetUserId, sdp }
60 event/10s
WebRTC SDP offer


webrtc:answer
{ meetingId, targetUserId, sdp }
60 event/10s
WebRTC SDP answer


webrtc:ice_candidate
{ meetingId, targetUserId, candidate }
300 event/10s
ICE candidate


webrtc:leave
{ meetingId, targetUserId }
60 event/10s
Thông báo peer rời khỏi kết nối WebRTC



Khi vượt rate limit: nhận sự kiện meeting:throttled (chat) hoặc webrtc:rejected (WebRTC).

Namespace /call — Sự kiện server broadcast xuống client



Event
Target
Kafka topic
Mô tả




meeting:started
Mỗi member
call.event.started
Có cuộc gọi mới trong conversation


meeting:join_requested
Host
call.event.join_requested
Có người xếp hàng chờ vào


meeting:participant_joined
Phòng meeting
call.event.participant_joined
Thành viên mới tham gia


meeting:participant_left
Phòng meeting
call.event.participant_left
Thành viên rời đi


meeting:approved
User được duyệt
call.event.waiting_approved
Được cho vào từ waiting room


meeting:rejected
User bị từ chối
call.event.waiting_rejected
Bị host từ chối


meeting:ended
Phòng meeting
call.event.ended
Cuộc gọi kết thúc


meeting:media_state
Phòng meeting
call.event.media_state_updated
Mic/camera của ai đó thay đổi


meeting:recording_state
Phòng meeting
call.event.recording_state_updated
Trạng thái ghi âm thay đổi


meeting:participant_moderated
Phòng meeting
call.event.participant_moderated
Ai đó bị can thiệp (tắt mic, kick)


meeting:kicked
User bị kick
call.event.participant_moderated
Thông báo riêng cho người bị kick



