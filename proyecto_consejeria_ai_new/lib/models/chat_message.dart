import 'package:uuid/uuid.dart';

enum MessageType {
  text,
  voice,
  error,
  system
}

enum MessageStatus {
  sending,
  sent,
  error,
  received
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String? voiceUrl;
  final Duration? voiceDuration;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    String? id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.voiceUrl,
    this.voiceDuration,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.text({
    required String content,
    required bool isUser,
    MessageStatus status = MessageStatus.sent,
  }) {
    return ChatMessage(
      content: content,
      isUser: isUser,
      type: MessageType.text,
      status: status,
    );
  }

  factory ChatMessage.voice({
    required String content,
    required bool isUser,
    required String voiceUrl,
    required Duration voiceDuration,
    MessageStatus status = MessageStatus.sent,
  }) {
    return ChatMessage(
      content: content,
      isUser: isUser,
      type: MessageType.voice,
      status: status,
      voiceUrl: voiceUrl,
      voiceDuration: voiceDuration,
    );
  }

  factory ChatMessage.error({
    required String content,
  }) {
    return ChatMessage(
      content: content,
      isUser: false,
      type: MessageType.error,
      status: MessageStatus.error,
    );
  }

  factory ChatMessage.system({
    required String content,
  }) {
    return ChatMessage(
      content: content,
      isUser: false,
      type: MessageType.system,
      status: MessageStatus.sent,
    );
  }

  ChatMessage copyWith({
    String? content,
    bool? isUser,
    MessageType? type,
    MessageStatus? status,
    String? voiceUrl,
    Duration? voiceDuration,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'status': status.toString(),
      'voiceUrl': voiceUrl,
      'voiceDuration': voiceDuration?.inSeconds,
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      voiceUrl: json['voiceUrl'] as String?,
      voiceDuration: json['voiceDuration'] != null
          ? Duration(seconds: json['voiceDuration'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}