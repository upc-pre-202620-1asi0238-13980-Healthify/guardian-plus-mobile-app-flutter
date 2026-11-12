/// Body of stabilize, close and complete-response: optional free-text notes (up to 2000 characters).
class NotesRequestDto {
  final String? notes;

  const new({this.notes});

  Map<String, dynamic> toJson() => {'notes': notes};
}
