import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/education/domain/entities/course.dart';
import 'package:flutter_application/features/education/presentation/cubit/education_cubit.dart';
import 'package:flutter_application/features/education/presentation/cubit/education_state.dart';
import 'package:flutter_application/features/education/presentation/widgets/article_card.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<EducationCubit>().loadCourseArticles(widget.course.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
      ),
      body: BlocBuilder<EducationCubit, EducationState>(
        builder: (context, state) {
          if (state is EducationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourseArticlesLoaded) {
            if (state.articles.isEmpty) {
              return const Center(child: Text('No articles found for this course.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                final article = state.articles[index];
                return ArticleCard(
                  article: article,
                  onTap: () {
                    context.read<EducationCubit>().markArticleAsRead(
                          widget.course.id,
                          article.url,
                        );
                  },
                );
              },
            );
          } else if (state is EducationError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
