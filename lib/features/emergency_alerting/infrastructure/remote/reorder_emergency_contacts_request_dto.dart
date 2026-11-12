class ReorderEmergencyContactsRequestDto {
  final List<String> orderedEmergencyContactIds;

  const new({required this.orderedEmergencyContactIds});

  Map<String, dynamic> toJson() => {'orderedEmergencyContactIds': orderedEmergencyContactIds};
}
