class Topic {
  final int id;
  final int authorId;
  final String encryptedContent;
  final String status;
  final int importanceLevel;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  Topic({
    required this.id,
    required this.authorId,
    required this.encryptedContent,
    required this.status,
    required this.importanceLevel,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['ID'],
      authorId: json['AuthorID'],
      encryptedContent: json['EncryptedContent'],
      status: json['Status'],
      importanceLevel: json['ImportanceLevel'],
      createdAt: DateTime.parse(json['CreatedAt']),
      resolvedAt: json['ResolvedAt'] != null ? DateTime.parse(json['ResolvedAt']) : null,
    );
  }
}
