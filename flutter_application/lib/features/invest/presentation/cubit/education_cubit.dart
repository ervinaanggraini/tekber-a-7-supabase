import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'education_state.dart';
import '../../data/models/investment_article_model.dart';

class EducationCubit extends Cubit<EducationState> {
  EducationCubit() : super(EducationInitial());

  Future<void> fetchEducationArticles({
  required String courseId,
}) async {
  emit(EducationLoading());

  try {
    final response = await Supabase.instance.client
        .from('courses')
        .select('content')
        .eq('id', courseId)
        .single();

    final List articlesJson = response['content'];

    final articles = articlesJson
        .map((e) => InvestmentArticle.fromJson(e))
        .toList();

    emit(EducationLoaded(articles));
  } catch (e) {
    emit(EducationError(e.toString()));
  }
}

}
