import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/education_cubit.dart';
import '../cubit/education_state.dart';
import '../widgets/education_article_card.dart';

class EducationPage extends StatelessWidget {
  final String courseId;

  const EducationPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EducationCubit()..fetchEducationArticles(courseId: courseId),
      child: BlocBuilder<EducationCubit, EducationState>(
        builder: (context, state) {
          if (state is EducationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EducationLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: state.articles
                  .map((article) => EducationArticleCard(article: article))
                  .toList(),
            );
          }

          if (state is EducationError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
