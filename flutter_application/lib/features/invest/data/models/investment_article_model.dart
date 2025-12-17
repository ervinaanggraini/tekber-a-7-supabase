class InvestmentArticle {
  final String title;
  final String? description;
  final String url;
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;

  InvestmentArticle({
    required this.title,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.description,
    this.imageUrl,
  });

  factory InvestmentArticle.fromJson(Map<String, dynamic> json) {
    return InvestmentArticle(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      imageUrl: json['image_url'],
      source: json['source'],
      publishedAt: DateTime.parse(json['published_at']),
    );
  }
}
