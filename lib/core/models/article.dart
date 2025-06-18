// lib/models/article.dart

class Article {
  final String title;
  final String? description; // Deskripsi bisa null
  final String? urlToImage; // Gambar bisa null
  final String url;
  final String sourceName;
  final DateTime publishedAt;
  final String? content; // Konten bisa null

  Article({
    required this.title,
    this.description,
    this.urlToImage,
    required this.url,
    required this.sourceName,
    required this.publishedAt,
    this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title', // Default jika judul null
      description: json['description'],
      urlToImage: json['urlToImage'],
      url: json['url'] ?? '', // URL harus ada
      sourceName:
          json['source']['name'] ??
          'Unknown Source', // Ambil dari objek 'source'
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ??
          DateTime.now(), // Parse tanggal
      content: json['content'],
    );
  }
}
