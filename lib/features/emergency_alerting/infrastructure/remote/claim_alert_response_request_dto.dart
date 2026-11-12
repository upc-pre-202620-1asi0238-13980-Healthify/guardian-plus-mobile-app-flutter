class ClaimAlertResponseRequestDto {
  final String responderUserId;

  const new({required this.responderUserId});

  Map<String, dynamic> toJson() => {'responderUserId': responderUserId};
}
