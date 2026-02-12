class NotificationModel {
  final String id;
  final String receiverId;
  final String senderId;
  final String title;
  final String message;
  final String entityType;
  final String entityId;
  final String action;
  final DateTime? readAt;
  final DateTime createdAt;
  final NotificationSender sender;

  NotificationModel({
    required this.id,
    required this.receiverId,
    required this.senderId,
    required this.title,
    required this.message,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.readAt,
    required this.createdAt,
    required this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      receiverId: json['receiver_id'],
      senderId: json['sender_id'],
      title: json['title'],
      message: json['message'],
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      action: json['action'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      sender: NotificationSender.fromJson(json['notificationSenderId']),
    );
  }
}

class NotificationSender {
  final String id;
  final String name;

  NotificationSender({required this.id, required this.name});

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['id'],
      name: json['name'],
    );
  }
}