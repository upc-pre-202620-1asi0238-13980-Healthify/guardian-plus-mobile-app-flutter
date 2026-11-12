class AcknowledgeAlertRequestDto {
  final String userId;

  const new({required this.userId});

  Map<String, dynamic> toJson() => {'userId': userId};
}
