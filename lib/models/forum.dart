class ForumAuthor {
  final String id;
  final String nombre;

  ForumAuthor({required this.id, required this.nombre});

  factory ForumAuthor.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ForumAuthor(id: '', nombre: 'Anónimo');
    return ForumAuthor(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? 'Anónimo',
    );
  }
}

class ForumComment {
  final String id;
  final String body;
  final ForumAuthor author;
  final String? createdAt;

  ForumComment({
    required this.id,
    required this.body,
    required this.author,
    this.createdAt,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id']?.toString() ?? '',
      body: json['body'] ?? '',
      author: ForumAuthor.fromJson(json['author']),
      createdAt: json['createdAt'],
    );
  }
}

class ForumTopic {
  final String id;
  final String title;
  final String description;
  final ForumAuthor author;
  final int commentsCount;
  final String? createdAt;
  final String? lastActivityAt;

  ForumTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.commentsCount,
    this.createdAt,
    this.lastActivityAt,
  });

  factory ForumTopic.fromJson(Map<String, dynamic> json) {
    return ForumTopic(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: ForumAuthor.fromJson(json['author']),
      commentsCount: json['commentsCount'] ?? 0,
      createdAt: json['createdAt'],
      lastActivityAt: json['lastActivityAt'],
    );
  }
}

class ForumTopicDetail extends ForumTopic {
  final List<ForumComment> comments;

  ForumTopicDetail({
    required super.id,
    required super.title,
    required super.description,
    required super.author,
    required super.commentsCount,
    super.createdAt,
    super.lastActivityAt,
    required this.comments,
  });

  factory ForumTopicDetail.fromJson(Map<String, dynamic> json) {
    final base = ForumTopic.fromJson(json);
    return ForumTopicDetail(
      id: base.id,
      title: base.title,
      description: base.description,
      author: base.author,
      commentsCount: base.commentsCount,
      createdAt: base.createdAt,
      lastActivityAt: base.lastActivityAt,
      comments: (json['comments'] as List? ?? [])
          .map((e) => ForumComment.fromJson(e))
          .toList(),
    );
  }
}
