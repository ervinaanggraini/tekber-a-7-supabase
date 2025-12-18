import 'package:flutter/foundation.dart';
import 'package:flutter_application/features/education/data/models/course_model.dart';
import 'package:flutter_application/features/education/domain/entities/education_article.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class EducationRemoteDataSource {
  Future<List<CourseModel>> getCourses();
  Future<List<EducationArticle>> getCourseArticles(String courseId);
  Future<void> markArticleAsRead(String courseId, String articleUrl);
}

@LazySingleton(as: EducationRemoteDataSource)
class EducationRemoteDataSourceImpl implements EducationRemoteDataSource {
  final SupabaseClient _supabaseClient;

  EducationRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await _supabaseClient
          .from('courses')
          .select()
          .order('order_index', ascending: true);

      return (response as List).map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      return [];
    }
  }

  @override
  Future<List<EducationArticle>> getCourseArticles(String courseId) async {
    try {
      // Call the Edge Function with specific courseId
      final functionResponse = await _supabaseClient.functions.invoke(
        'fetch-news',
        body: {'course_id': courseId},
      );

      if (functionResponse.status != 200) {
        debugPrint('Failed to fetch news: ${functionResponse.status}');
        return _getMockArticles();
      }

      final data = functionResponse.data;
      final List<dynamic> articlesJson = data['articles'] ?? [];

      if (articlesJson.isEmpty) {
        return _getMockArticles();
      }

      return articlesJson.map((json) {
        return EducationArticle(
          id: json['id'] ?? '',
          title: json['title'] ?? 'No Title',
          description: json['description'] ?? '',
          imageUrl: json['image_url'] ?? 'https://via.placeholder.com/150',
          url: json['url'] ?? '',
          publishedAt: json['published_at'] != null
              ? DateTime.parse(json['published_at'])
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching news: $e');
      return _getMockArticles();
    }
  }

  @override
  Future<void> markArticleAsRead(String courseId, String articleUrl) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Get current progress
      final progressResponse = await _supabaseClient
          .from('user_course_progress')
          .select()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();

      List<String> readArticles = [];
      if (progressResponse != null) {
        readArticles = List<String>.from(progressResponse['read_articles'] ?? []);
      }

      // 2. Add new article if not exists
      if (!readArticles.contains(articleUrl)) {
        readArticles.add(articleUrl);

        // 3. Upsert progress
        await _supabaseClient.from('user_course_progress').upsert({
          'user_id': userId,
          'course_id': courseId,
          'read_articles': readArticles,
          'total_articles_read': readArticles.length,
          'last_accessed_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id, course_id');
      }
    } catch (e) {
      debugPrint('Error marking article as read: $e');
    }
  }

  List<EducationArticle> _getMockArticles() {
    return [
      EducationArticle(
        id: '1',
        title: 'Dasar-Dasar Investasi Saham',
        description: 'Pelajari cara memulai investasi saham dengan aman dan menguntungkan.',
        imageUrl: 'https://via.placeholder.com/150',
        url: 'https://example.com/article1',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      EducationArticle(
        id: '2',
        title: 'Tips Mengatur Keuangan Pribadi',
        description: 'Cara efektif mengelola gaji bulanan agar tidak cepat habis.',
        imageUrl: 'https://via.placeholder.com/150',
        url: 'https://example.com/article2',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      EducationArticle(
        id: '3',
        title: 'Mengenal Reksadana',
        description: 'Apa itu reksadana dan bagaimana cara kerjanya?',
        imageUrl: 'https://via.placeholder.com/150',
        url: 'https://example.com/article3',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
