// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_application/core/app/app_module.dart' as _i690;
import 'package:flutter_application/features/analytics/data/data_sources/analytics_remote_data_source.dart'
    as _i125;
import 'package:flutter_application/features/analytics/data/repositories/analytics_repository_impl.dart'
    as _i36;
import 'package:flutter_application/features/analytics/domain/repositories/analytics_repository.dart'
    as _i905;
import 'package:flutter_application/features/analytics/domain/use_cases/get_analytics_summary_use_case.dart'
    as _i652;
import 'package:flutter_application/features/analytics/domain/use_cases/update_savings_goal_use_case.dart'
    as _i646;
import 'package:flutter_application/features/analytics/presentation/cubit/analytics_cubit.dart'
    as _i870;
import 'package:flutter_application/features/auth/data/repository/supabase_auth_repository.dart'
    as _i476;
import 'package:flutter_application/features/auth/domain/repository/auth_repository.dart'
    as _i946;
import 'package:flutter_application/features/auth/domain/use_case/get_current_auth_state_use_case.dart'
    as _i781;
import 'package:flutter_application/features/auth/domain/use_case/get_logged_in_user_use_case.dart'
    as _i981;
import 'package:flutter_application/features/auth/domain/use_case/login_with_email_and_password_use_case.dart'
    as _i459;
import 'package:flutter_application/features/auth/domain/use_case/login_with_email_use_case.dart'
    as _i602;
import 'package:flutter_application/features/auth/domain/use_case/logout_use_case.dart'
    as _i603;
import 'package:flutter_application/features/auth/domain/use_case/sign_up_with_email_and_password_use_case.dart'
    as _i829;
import 'package:flutter_application/features/auth/presentation/bloc/auth_bloc.dart'
    as _i964;
import 'package:flutter_application/features/auth/presentation/bloc/login/login_cubit.dart'
    as _i723;
import 'package:flutter_application/features/auth/presentation/bloc/register/register_cubit.dart'
    as _i553;
import 'package:flutter_application/features/budget/data/data_sources/budget_remote_data_source.dart'
    as _i628;
import 'package:flutter_application/features/budget/data/repositories/budget_repository_impl.dart'
    as _i962;
import 'package:flutter_application/features/budget/domain/repositories/budget_repository.dart'
    as _i363;
import 'package:flutter_application/features/budget/domain/use_cases/create_budget_use_case.dart'
    as _i203;
import 'package:flutter_application/features/budget/domain/use_cases/delete_budget_use_case.dart'
    as _i910;
import 'package:flutter_application/features/budget/domain/use_cases/get_budgets_use_case.dart'
    as _i131;
import 'package:flutter_application/features/budget/domain/use_cases/update_budget_use_case.dart'
    as _i869;
import 'package:flutter_application/features/budget/presentation/cubit/budget_cubit.dart'
    as _i860;
import 'package:flutter_application/features/chatbot/data/data_sources/chat_remote_data_source.dart'
    as _i592;
import 'package:flutter_application/features/chatbot/di/chat_module.dart'
    as _i428;
import 'package:flutter_application/features/chatbot/domain/repositories/chat_repository.dart'
    as _i159;
import 'package:flutter_application/features/chatbot/presentation/cubit/chat_cubit.dart'
    as _i914;
import 'package:flutter_application/features/education/data/data_sources/education_remote_data_source.dart'
    as _i85;
import 'package:flutter_application/features/education/data/repositories/education_repository_impl.dart'
    as _i339;
import 'package:flutter_application/features/education/domain/repositories/education_repository.dart'
    as _i261;
import 'package:flutter_application/features/education/domain/use_cases/get_courses_use_case.dart'
    as _i154;
import 'package:flutter_application/features/education/domain/use_cases/get_education_articles_use_case.dart'
    as _i401;
import 'package:flutter_application/features/education/domain/use_cases/mark_article_read_use_case.dart'
    as _i259;
import 'package:flutter_application/features/education/presentation/cubit/education_cubit.dart'
    as _i84;
import 'package:flutter_application/features/financial_insights/data/data_sources/financial_insights_remote_data_source.dart'
    as _i271;
import 'package:flutter_application/features/financial_insights/data/repositories/financial_insights_repository_impl.dart'
    as _i500;
import 'package:flutter_application/features/financial_insights/domain/repositories/financial_insights_repository.dart'
    as _i287;
import 'package:flutter_application/features/financial_insights/domain/use_cases/get_financial_insights_use_case.dart'
    as _i884;
import 'package:flutter_application/features/financial_insights/presentation/cubit/financial_insights_cubit.dart'
    as _i466;
import 'package:flutter_application/features/home/presentation/bloc/bottom_navigation_bar/bottom_navigation_bar_cubit.dart'
    as _i740;
import 'package:flutter_application/features/home/presentation/bloc/home/home_cubit.dart'
    as _i436;
import 'package:flutter_application/features/notification/data/data_sources/notification_remote_data_source.dart'
    as _i180;
import 'package:flutter_application/features/notification/data/repositories/notification_repository_impl.dart'
    as _i461;
import 'package:flutter_application/features/notification/domain/repositories/notification_repository.dart'
    as _i409;
import 'package:flutter_application/features/notification/domain/use_cases/get_notifications_use_case.dart'
    as _i827;
import 'package:flutter_application/features/notification/domain/use_cases/mark_notification_read_use_case.dart'
    as _i160;
import 'package:flutter_application/features/notification/presentation/cubit/notification_cubit.dart'
    as _i915;
import 'package:flutter_application/features/ocr_receipt/data/data_sources/ocr_remote_data_source.dart'
    as _i248;
import 'package:flutter_application/features/ocr_receipt/data/repositories/ocr_repository_impl.dart'
    as _i398;
import 'package:flutter_application/features/ocr_receipt/domain/repositories/ocr_repository.dart'
    as _i743;
import 'package:flutter_application/features/ocr_receipt/domain/use_cases/scan_receipt_use_case.dart'
    as _i49;
import 'package:flutter_application/features/ocr_receipt/presentation/cubit/ocr_cubit.dart'
    as _i427;
import 'package:flutter_application/features/onboarding/data/repository/onboarding_repository.dart'
    as _i483;
import 'package:flutter_application/features/onboarding/presentation/cubit/onboarding_cubit.dart'
    as _i177;
import 'package:flutter_application/features/reports/data/data_sources/report_remote_data_source.dart'
    as _i873;
import 'package:flutter_application/features/reports/data/repositories/report_repository_impl.dart'
    as _i194;
import 'package:flutter_application/features/reports/domain/repositories/report_repository.dart'
    as _i62;
import 'package:flutter_application/features/reports/domain/use_cases/get_report_summary_use_case.dart'
    as _i161;
import 'package:flutter_application/features/reports/presentation/cubit/reports_cubit.dart'
    as _i180;
import 'package:flutter_application/features/savings_goal/data/data_sources/savings_goal_remote_data_source.dart'
    as _i784;
import 'package:flutter_application/features/savings_goal/data/repositories/savings_goal_repository_impl.dart'
    as _i673;
import 'package:flutter_application/features/savings_goal/domain/repositories/savings_goal_repository.dart'
    as _i402;
import 'package:flutter_application/features/savings_goal/domain/use_cases/create_savings_goal_use_case.dart'
    as _i287;
import 'package:flutter_application/features/savings_goal/domain/use_cases/delete_savings_goal_use_case.dart'
    as _i445;
import 'package:flutter_application/features/savings_goal/domain/use_cases/get_savings_goals_use_case.dart'
    as _i1;
import 'package:flutter_application/features/savings_goal/domain/use_cases/update_savings_goal_use_case.dart'
    as _i87;
import 'package:flutter_application/features/savings_goal/presentation/cubit/savings_goal_cubit.dart'
    as _i354;
import 'package:flutter_application/features/theme_mode/data/repository/theme_mode_hive_repository.dart'
    as _i279;
import 'package:flutter_application/features/theme_mode/domain/repository/theme_mode_repository.dart'
    as _i12;
import 'package:flutter_application/features/theme_mode/domain/use_case/get_or_set_initial_theme_mode_use_case.dart'
    as _i1023;
import 'package:flutter_application/features/theme_mode/domain/use_case/set_theme_mode_id_use_case.dart'
    as _i727;
import 'package:flutter_application/features/theme_mode/presentation/bloc/theme_mode_cubit.dart'
    as _i621;
import 'package:flutter_application/features/transaction/presentation/bloc/transaction_bloc.dart'
    as _i124;
import 'package:flutter_application/features/transactions/data/data_sources/transaction_remote_data_source.dart'
    as _i713;
import 'package:flutter_application/features/transactions/data/repositories/transaction_repository_impl.dart'
    as _i661;
import 'package:flutter_application/features/transactions/domain/repositories/transaction_repository.dart'
    as _i993;
import 'package:flutter_application/features/transactions/domain/use_cases/create_transaction_use_case.dart'
    as _i198;
import 'package:flutter_application/features/transactions/domain/use_cases/delete_transaction_use_case.dart'
    as _i219;
import 'package:flutter_application/features/transactions/domain/use_cases/get_cashflow_summary_use_case.dart'
    as _i357;
import 'package:flutter_application/features/transactions/domain/use_cases/get_categories_use_case.dart'
    as _i268;
import 'package:flutter_application/features/transactions/domain/use_cases/get_recent_transactions_use_case.dart'
    as _i725;
import 'package:flutter_application/features/transactions/domain/use_cases/update_transaction_use_case.dart'
    as _i162;
import 'package:flutter_application/features/transactions/presentation/cubit/add_transaction_cubit.dart'
    as _i621;
import 'package:flutter_application/features/user/data/repository/supabase_user_repository.dart'
    as _i763;
import 'package:flutter_application/features/user/domain/repository/user_repository.dart'
    as _i392;
import 'package:flutter_application/features/user/domain/use_case/change_email_address_use_case.dart'
    as _i627;
import 'package:flutter_application/features/user/presentation/bloc/change_email_address/change_email_address_cubit.dart'
    as _i75;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase/supabase.dart' as _i590;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    final chatModule = _$ChatModule();
    gh.factory<_i454.SupabaseClient>(() => appModule.supabaseClient);
    gh.factory<_i454.GoTrueClient>(() => appModule.supabaseAuth);
    gh.factory<_i454.FunctionsClient>(() => appModule.functionsClient);
    gh.factory<_i740.BottomNavigationBarCubit>(
        () => _i740.BottomNavigationBarCubit());
    gh.lazySingleton<_i592.ChatRemoteDataSource>(
        () => chatModule.chatRemoteDataSource);
    gh.lazySingleton<_i159.ChatRepository>(() => chatModule.chatRepository);
    gh.lazySingleton<_i248.OcrRemoteDataSource>(
        () => _i248.OcrRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i125.AnalyticsRemoteDataSource>(
        () => _i125.AnalyticsRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i271.FinancialInsightsRemoteDataSource>(() =>
        _i271.FinancialInsightsRemoteDataSourceImpl(
            gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i784.SavingsGoalRemoteDataSource>(() =>
        _i784.SavingsGoalRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.factory<_i12.ThemeModeRepository>(() => _i279.ThemeModeHiveRepository());
    gh.factory<_i483.OnboardingRepository>(
        () => _i483.OnboardingRepositoryImpl());
    gh.lazySingleton<_i905.AnalyticsRepository>(() =>
        _i36.AnalyticsRepositoryImpl(gh<_i125.AnalyticsRemoteDataSource>()));
    gh.lazySingleton<_i873.ReportRemoteDataSource>(
        () => _i873.ReportRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.factory<_i946.AuthRepository>(() => _i476.SupabaseAuthRepository(
          gh<_i454.GoTrueClient>(),
          gh<_i454.SupabaseClient>(),
        ));
    gh.factory<_i1023.GetOrSetInitialThemeModeUseCase>(() =>
        _i1023.GetOrSetInitialThemeModeUseCase(gh<_i12.ThemeModeRepository>()));
    gh.factory<_i727.SetThemeModeUseCase>(
        () => _i727.SetThemeModeUseCase(gh<_i12.ThemeModeRepository>()));
    gh.lazySingleton<_i180.NotificationRemoteDataSource>(() =>
        _i180.NotificationRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.factory<_i392.UserRepository>(() => _i763.SupabaseUserRepository(
          gh<_i590.GoTrueClient>(),
          gh<_i590.FunctionsClient>(),
        ));
    gh.factory<_i781.GetCurrentAuthStateUseCase>(
        () => _i781.GetCurrentAuthStateUseCase(gh<_i946.AuthRepository>()));
    gh.factory<_i981.GetLoggedInUserUseCase>(
        () => _i981.GetLoggedInUserUseCase(gh<_i946.AuthRepository>()));
    gh.factory<_i459.LoginWithEmailAndPasswordUseCase>(() =>
        _i459.LoginWithEmailAndPasswordUseCase(gh<_i946.AuthRepository>()));
    gh.factory<_i602.LoginWithEmailUseCase>(
        () => _i602.LoginWithEmailUseCase(gh<_i946.AuthRepository>()));
    gh.factory<_i603.LogoutUseCase>(
        () => _i603.LogoutUseCase(gh<_i946.AuthRepository>()));
    gh.factory<_i829.SignUpWithEmailAndPasswordUseCase>(() =>
        _i829.SignUpWithEmailAndPasswordUseCase(gh<_i946.AuthRepository>()));
    gh.lazySingleton<_i628.BudgetRemoteDataSource>(
        () => _i628.BudgetRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.factory<_i652.GetAnalyticsSummaryUseCase>(() =>
        _i652.GetAnalyticsSummaryUseCase(gh<_i905.AnalyticsRepository>()));
    gh.factory<_i646.UpdateSavingsGoalUseCase>(
        () => _i646.UpdateSavingsGoalUseCase(gh<_i905.AnalyticsRepository>()));
    gh.factory<_i914.ChatCubit>(
        () => _i914.ChatCubit(gh<_i159.ChatRepository>()));
    gh.factory<_i621.ThemeModeCubit>(() => _i621.ThemeModeCubit(
          gh<_i1023.GetOrSetInitialThemeModeUseCase>(),
          gh<_i727.SetThemeModeUseCase>(),
        ));
    gh.lazySingleton<_i287.FinancialInsightsRepository>(() =>
        _i500.FinancialInsightsRepositoryImpl(
            gh<_i271.FinancialInsightsRemoteDataSource>()));
    gh.lazySingleton<_i363.BudgetRepository>(
        () => _i962.BudgetRepositoryImpl(gh<_i628.BudgetRemoteDataSource>()));
    gh.factory<_i177.OnboardingCubit>(
        () => _i177.OnboardingCubit(gh<_i483.OnboardingRepository>()));
    gh.factory<_i723.LoginCubit>(() => _i723.LoginCubit(
          gh<_i459.LoginWithEmailAndPasswordUseCase>(),
          gh<_i829.SignUpWithEmailAndPasswordUseCase>(),
        ));
    gh.lazySingleton<_i402.SavingsGoalRepository>(() =>
        _i673.SavingsGoalRepositoryImpl(
            gh<_i784.SavingsGoalRemoteDataSource>()));
    gh.lazySingleton<_i713.TransactionRemoteDataSource>(() =>
        _i713.TransactionRemoteDataSourceImpl(
            supabaseClient: gh<_i454.SupabaseClient>()));
    gh.factory<_i553.RegisterCubit>(() =>
        _i553.RegisterCubit(gh<_i829.SignUpWithEmailAndPasswordUseCase>()));
    gh.lazySingleton<_i287.CreateSavingsGoalUseCase>(() =>
        _i287.CreateSavingsGoalUseCase(gh<_i402.SavingsGoalRepository>()));
    gh.lazySingleton<_i445.DeleteSavingsGoalUseCase>(() =>
        _i445.DeleteSavingsGoalUseCase(gh<_i402.SavingsGoalRepository>()));
    gh.lazySingleton<_i1.GetSavingsGoalsUseCase>(
        () => _i1.GetSavingsGoalsUseCase(gh<_i402.SavingsGoalRepository>()));
    gh.lazySingleton<_i87.UpdateSavingsGoalUseCase>(
        () => _i87.UpdateSavingsGoalUseCase(gh<_i402.SavingsGoalRepository>()));
    gh.lazySingleton<_i85.EducationRemoteDataSource>(
        () => _i85.EducationRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i409.NotificationRepository>(() =>
        _i461.NotificationRepositoryImpl(
            gh<_i180.NotificationRemoteDataSource>()));
    gh.lazySingleton<_i743.OcrRepository>(
        () => _i398.OcrRepositoryImpl(gh<_i248.OcrRemoteDataSource>()));
    gh.lazySingleton<_i62.ReportRepository>(
        () => _i194.ReportRepositoryImpl(gh<_i873.ReportRemoteDataSource>()));
    gh.factory<_i870.AnalyticsCubit>(() => _i870.AnalyticsCubit(
          gh<_i652.GetAnalyticsSummaryUseCase>(),
          gh<_i646.UpdateSavingsGoalUseCase>(),
        ));
    gh.factory<_i627.ChangeEmailAddressUseCase>(
        () => _i627.ChangeEmailAddressUseCase(gh<_i392.UserRepository>()));
    gh.factory<_i964.AuthBloc>(() => _i964.AuthBloc(
          gh<_i981.GetLoggedInUserUseCase>(),
          gh<_i781.GetCurrentAuthStateUseCase>(),
          gh<_i603.LogoutUseCase>(),
        ));
    gh.lazySingleton<_i827.GetNotificationsUseCase>(() =>
        _i827.GetNotificationsUseCase(gh<_i409.NotificationRepository>()));
    gh.lazySingleton<_i160.MarkNotificationReadUseCase>(() =>
        _i160.MarkNotificationReadUseCase(gh<_i409.NotificationRepository>()));
    gh.lazySingleton<_i884.GetFinancialInsightsUseCase>(() =>
        _i884.GetFinancialInsightsUseCase(
            gh<_i287.FinancialInsightsRepository>()));
    gh.factory<_i161.GetReportSummaryUseCase>(
        () => _i161.GetReportSummaryUseCase(gh<_i62.ReportRepository>()));
    gh.lazySingleton<_i203.CreateBudgetUseCase>(
        () => _i203.CreateBudgetUseCase(gh<_i363.BudgetRepository>()));
    gh.lazySingleton<_i910.DeleteBudgetUseCase>(
        () => _i910.DeleteBudgetUseCase(gh<_i363.BudgetRepository>()));
    gh.lazySingleton<_i131.GetBudgetsUseCase>(
        () => _i131.GetBudgetsUseCase(gh<_i363.BudgetRepository>()));
    gh.lazySingleton<_i869.UpdateBudgetUseCase>(
        () => _i869.UpdateBudgetUseCase(gh<_i363.BudgetRepository>()));
    gh.factory<_i354.SavingsGoalCubit>(() => _i354.SavingsGoalCubit(
          gh<_i1.GetSavingsGoalsUseCase>(),
          gh<_i287.CreateSavingsGoalUseCase>(),
          gh<_i87.UpdateSavingsGoalUseCase>(),
          gh<_i445.DeleteSavingsGoalUseCase>(),
        ));
    gh.lazySingleton<_i49.ScanReceiptUseCase>(
        () => _i49.ScanReceiptUseCase(gh<_i743.OcrRepository>()));
    gh.lazySingleton<_i993.TransactionRepository>(() =>
        _i661.TransactionRepositoryImpl(
            remoteDataSource: gh<_i713.TransactionRemoteDataSource>()));
    gh.factory<_i357.GetCashflowSummaryUseCase>(() =>
        _i357.GetCashflowSummaryUseCase(
            repository: gh<_i993.TransactionRepository>()));
    gh.factory<_i725.GetRecentTransactionsUseCase>(() =>
        _i725.GetRecentTransactionsUseCase(
            repository: gh<_i993.TransactionRepository>()));
    gh.factory<_i915.NotificationCubit>(() => _i915.NotificationCubit(
          gh<_i827.GetNotificationsUseCase>(),
          gh<_i160.MarkNotificationReadUseCase>(),
        ));
    gh.lazySingleton<_i261.EducationRepository>(() =>
        _i339.EducationRepositoryImpl(gh<_i85.EducationRemoteDataSource>()));
    gh.factory<_i75.ChangeEmailAddressCubit>(() =>
        _i75.ChangeEmailAddressCubit(gh<_i627.ChangeEmailAddressUseCase>()));
    gh.factory<_i860.BudgetCubit>(() => _i860.BudgetCubit(
          gh<_i131.GetBudgetsUseCase>(),
          gh<_i203.CreateBudgetUseCase>(),
          gh<_i869.UpdateBudgetUseCase>(),
          gh<_i910.DeleteBudgetUseCase>(),
        ));
    gh.factory<_i436.HomeCubit>(() => _i436.HomeCubit(
          getCashflowSummaryUseCase: gh<_i357.GetCashflowSummaryUseCase>(),
          getRecentTransactionsUseCase:
              gh<_i725.GetRecentTransactionsUseCase>(),
        ));
    gh.factory<_i198.CreateTransactionUseCase>(() =>
        _i198.CreateTransactionUseCase(gh<_i993.TransactionRepository>()));
    gh.factory<_i219.DeleteTransactionUseCase>(() =>
        _i219.DeleteTransactionUseCase(gh<_i993.TransactionRepository>()));
    gh.factory<_i268.GetCategoriesUseCase>(
        () => _i268.GetCategoriesUseCase(gh<_i993.TransactionRepository>()));
    gh.factory<_i162.UpdateTransactionUseCase>(() =>
        _i162.UpdateTransactionUseCase(gh<_i993.TransactionRepository>()));
    gh.factory<_i427.OcrCubit>(
        () => _i427.OcrCubit(gh<_i49.ScanReceiptUseCase>()));
    gh.factory<_i124.TransactionBloc>(() => _i124.TransactionBloc(
          gh<_i725.GetRecentTransactionsUseCase>(),
          gh<_i219.DeleteTransactionUseCase>(),
        ));
    gh.factory<_i466.FinancialInsightsCubit>(() =>
        _i466.FinancialInsightsCubit(gh<_i884.GetFinancialInsightsUseCase>()));
    gh.factory<_i180.ReportsCubit>(
        () => _i180.ReportsCubit(gh<_i161.GetReportSummaryUseCase>()));
    gh.lazySingleton<_i154.GetCoursesUseCase>(
        () => _i154.GetCoursesUseCase(gh<_i261.EducationRepository>()));
    gh.lazySingleton<_i401.GetEducationArticlesUseCase>(() =>
        _i401.GetEducationArticlesUseCase(gh<_i261.EducationRepository>()));
    gh.lazySingleton<_i259.MarkArticleReadUseCase>(
        () => _i259.MarkArticleReadUseCase(gh<_i261.EducationRepository>()));
    gh.factory<_i84.EducationCubit>(() => _i84.EducationCubit(
          gh<_i154.GetCoursesUseCase>(),
          gh<_i401.GetEducationArticlesUseCase>(),
          gh<_i259.MarkArticleReadUseCase>(),
        ));
    gh.factory<_i621.AddTransactionCubit>(() => _i621.AddTransactionCubit(
          gh<_i198.CreateTransactionUseCase>(),
          gh<_i268.GetCategoriesUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i690.AppModule {}

class _$ChatModule extends _i428.ChatModule {}
