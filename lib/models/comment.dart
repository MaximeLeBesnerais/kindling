
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
}
