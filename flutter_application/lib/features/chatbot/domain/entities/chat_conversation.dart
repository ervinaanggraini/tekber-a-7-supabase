import 'package:equatable/equatable.dart';

enum ChatPersona {
  angryMom('angry_mom', 'Finny', 'The Angry Mom', '😠'),
  supportiveCheerleader(
      'supportive_cheerleader', 'Mona', 'The Supportive Cheerleader', '💖'),
  wiseMentor('wise_mentor', 'Vesto', 'The Wise Mentor', '🧙‍♂️');

  final String value;
  final String name;
  final String description;
  final String emoji;

  const ChatPersona(this.value, this.name, this.description, this.emoji);

  static ChatPersona fromString(String value) {
    return ChatPersona.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChatPersona.wiseMentor,
    );
  }
}

class ChatConversation extends Equatable {
  final String id;
  final String userId;
  final String? title;
  final ChatPersona persona;
  final String? contextSummary;
  final DateTime? lastMessageAt;
  final bool isArchived;
  final DateTime createdAt;

  const ChatConversation({
    required this.id,
    required this.userId,
    this.title,
    required this.persona,
    this.contextSummary,
    this.lastMessageAt,
    this.isArchived = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        persona,
        contextSummary,
        lastMessageAt,
        isArchived,
        createdAt,
      ];
}
