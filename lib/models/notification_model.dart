class AppNotification {
  final String id;

  final String title;

  final String body;

  final DateTime time;

  final String type;

  final String severity;

  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.severity,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'time': time.toIso8601String(),
      'type': type,
      'severity': severity,
      'isRead': isRead,
    };
  }

  factory AppNotification.fromJson(
    Map<String, dynamic> json,
  ) {
    return AppNotification(
      id: json['id'],

      title: json['title'],

      body: json['body'],

      time: DateTime.parse(json['time']),

      type: json['type'],

      severity: json['severity'],

      isRead: json['isRead'] ?? false,
    );
  }
}

