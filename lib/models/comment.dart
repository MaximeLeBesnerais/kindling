class Comment {
  final String id;
  final String topicId;
  final String authorId;
  final String encryptedContent;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.topicId,
    required this.authorId,
    required this.encryptedContent,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['ID'].toString(),
      topicId: json['TopicID'].toString(),
      authorId: json['AuthorID'].toString(),
      encryptedContent: json['EncryptedContent'],
      createdAt: DateTime.parse(json['CreatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TopicID': topicId,
      'AuthorID': authorId,
      'EncryptedContent': encryptedContent,
      'CreatedAt': createdAt.toIso8601String(),
    };
  }
}
