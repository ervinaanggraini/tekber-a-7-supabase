import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/education/presentation/cubit/education_cubit.dart';
import 'package:flutter_application/features/education/presentation/cubit/education_state.dart';
import 'package:flutter_application/features/education/presentation/widgets/course_card.dart';
import 'package:get_it/get_it.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<EducationCubit>()..loadCourses(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Investment Courses'),
        ),
        body: BlocBuilder<EducationCubit, EducationState>(
          builder: (context, state) {
            if (state is EducationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CoursesLoaded) {
              if (state.courses.isEmpty) {
                return const Center(child: Text('No courses available.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.courses.length,
                itemBuilder: (context, index) {
                  return CourseCard(course: state.courses[index]);
                },
              );
            } else if (state is EducationError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
