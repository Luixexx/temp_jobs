class VideoItem {
  final String id;
  final String youtubeId;
  final String url;
  final String title;
  final String description;
  final String? thumbnail;

  VideoItem({
    required this.id,
    required this.youtubeId,
    required this.url,
    required this.title,
    required this.description,
    this.thumbnail,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    final youtubeId = json['youtubeId'] ?? '';
    return VideoItem(
      id: json['id']?.toString() ?? '',
      youtubeId: youtubeId,
      url: json['url'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // Si el servidor no manda thumbnail, la generamos nosotros mismos:
      // YouTube expone una miniatura pública para cualquier video con solo su id.
      thumbnail:
          json['thumbnail'] ??
          (youtubeId.isNotEmpty
              ? 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg'
              : null),
    );
  }
}
