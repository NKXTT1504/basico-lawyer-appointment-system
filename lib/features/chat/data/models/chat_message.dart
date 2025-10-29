class ChatMessage {
  final String? id;
  final String? content;
  final String? senderId;
  final String? senderName;
  final String? senderType; // 'user', 'ai', 'lawyer'
  final DateTime? timestamp;
  final bool? isRead;
  final String? conversationId;

  const ChatMessage({
    this.id,
    this.content,
    this.senderId,
    this.senderName,
    this.senderType,
    this.timestamp,
    this.isRead,
    this.conversationId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    String? pickStr(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return null;
    }

    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return ChatMessage(
      id: pickStr(['id', 'messageId', 'Id', 'MessageId']),
      content: pickStr(['content', 'message', 'text', 'body']),
      senderId: pickStr(['senderId', 'userId', 'sender_id', 'user_id']),
      senderName:
          pickStr(['senderName', 'userName', 'sender_name', 'user_name']),
      senderType: pickStr(['senderType', 'type', 'sender_type', 'messageType']),
      timestamp: parseDateTime(
          json['timestamp'] ?? json['createdAt'] ?? json['created_at']),
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      conversationId:
          pickStr(['conversationId', 'chatId', 'conversation_id', 'chat_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'timestamp': timestamp?.toIso8601String(),
      'isRead': isRead,
      'conversationId': conversationId,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    String? senderId,
    String? senderName,
    String? senderType,
    DateTime? timestamp,
    bool? isRead,
    String? conversationId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}
