/// The platform's PageResource: one page of items plus the paging totals.
class PageDto<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  const new({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageDto.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic> item) itemFromJson) {
    return PageDto(
      content: [for (final item in json['content']) itemFromJson(item)],
      page: json['page'],
      size: json['size'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
    );
  }
}
