class Topic {
  final String id;
  final String spaceId;
  final String authorId;
  final String encryptedContent;
  final String status;
  final int importanceLevel;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  Topic({
    required this.id,
    required this.spaceId,
    required this.authorId,
    required this.encryptedContent,
    required this.status,
    required this.importanceLevel,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['ID'].toString(),
      spaceId: json['SpaceID'].toString(),
      authorId: json['AuthorID'].toString(),
      encryptedContent: json['EncryptedContent'],
      status: json['Status'],
      importanceLevel: json['ImportanceLevel'],
      createdAt: DateTime.parse(json['CreatedAt']),
      resolvedAt: json['ResolvedAt'] != null ? DateTime.parse(json['ResolvedAt']) : null,
    );
  }
}
