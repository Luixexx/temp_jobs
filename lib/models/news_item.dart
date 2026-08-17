class NewsItem {
  final String title;
  final String image;
  final String summary;
  final String? date;
  final String url;
  final String source;

  NewsItem({
    required this.title,
    required this.image,
    required this.summary,
    this.date,
    required this.url,
    required this.source,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      summary: json['summary'] ?? '',
      date: json['date'],
      url: json['url'] ?? '',
      source: json['source'] ?? '',
    );
  }
}
