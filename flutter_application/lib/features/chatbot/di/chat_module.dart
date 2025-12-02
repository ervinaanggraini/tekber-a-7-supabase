import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/data_sources/chat_remote_data_source.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../domain/repositories/chat_repository.dart';

@module
abstract class ChatModule {
  @lazySingleton
  ChatRemoteDataSource get chatRemoteDataSource => 
      ChatRemoteDataSourceImpl(Supabase.instance.client);

  @lazySingleton
  ChatRepository get chatRepository =>
      ChatRepositoryImpl(chatRemoteDataSource);
}
