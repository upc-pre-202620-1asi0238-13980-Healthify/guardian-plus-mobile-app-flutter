class AlertDeliveryDto {
  final String id;
  final String recipientUserId;
  final String recipientLevel;
  final String channel;
  final String deliveryStatus;
  final String? sentAt;
  final String? deliveredAt;

  const new({
    required this.id,
    required this.recipientUserId,
    required this.recipientLevel,
    required this.channel,
    required this.deliveryStatus,
    this.sentAt,
    this.deliveredAt,
  });

  factory AlertDeliveryDto.fromJson(Map<String, dynamic> json) {
    return AlertDeliveryDto(
      id: json['id'],
      recipientUserId: json['recipientUserId'],
      recipientLevel: json['recipientLevel'],
      channel: json['channel'],
      deliveryStatus: json['deliveryStatus'],
      sentAt: json['sentAt'],
      deliveredAt: json['deliveredAt'],
    );
  }
}
