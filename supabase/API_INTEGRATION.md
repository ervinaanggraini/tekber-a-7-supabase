# MoneyStocks API Integration Guide

## Setup Supabase Client

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(MyApp());
}

final supabase = Supabase.instance.client;
```

## 1. Authentication & User Profile

### Sign Up with Profile Creation
```dart
Future<void> signUpWithProfile({
  required String email,
  required String password,
  required String fullName,
}) async {
  // 1. Sign up user
  final response = await supabase.auth.signUp(
    email: email,
    password: password,
  );
  
  final userId = response.user!.id;
  
  // 2. Create user profile (triggers auto-create settings & portfolio)
  await supabase.from('user_profiles').insert({
    'id': userId,
    'full_name': fullName,
    'preferred_chatbot_persona': 'wise_mentor',
  });
}
```

### Get User Profile
```dart
Future<Map<String, dynamic>> getUserProfile() async {
  final userId = supabase.auth.currentUser!.id;
  
  final response = await supabase
      .from('user_profiles')
      .select()
      .eq('id', userId)
      .single();
  
  return response;
}
```

### Update User Profile
```dart
Future<void> updateProfile({
  String? fullName,
  String? avatarUrl,
  String? riskProfile,
  String? preferredPersona,
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  await supabase.from('user_profiles').update({
    if (fullName != null) 'full_name': fullName,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (riskProfile != null) 'risk_profile': riskProfile,
    if (preferredPersona != null) 'preferred_chatbot_persona': preferredPersona,
  }).eq('id', userId);
}
```

## 2. Categories

### Get All Categories
```dart
Future<List<Map<String, dynamic>>> getCategories({String? type}) async {
  var query = supabase.from('categories').select();
  
  if (type != null) {
    query = query.eq('type', type);
  }
  
  final response = await query.order('name');
  return List<Map<String, dynamic>>.from(response);
}
```

### Create Custom Category
```dart
Future<Map<String, dynamic>> createCategory({
  required String name,
  required String type, // 'income' or 'expense'
  String? icon,
  String? color,
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  final response = await supabase.from('categories').insert({
    'name': name,
    'type': type,
    'icon': icon,
    'color': color,
    'user_id': userId,
    'is_system': false,
  }).select().single();
  
  return response;
}
```

## 3. Transactions

### Create Transaction (Manual)
```dart
Future<Map<String, dynamic>> createTransaction({
  required String categoryId,
  required String type, // 'income' or 'expense'
  required double amount,
  String? description,
  String? notes,
  DateTime? transactionDate,
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  final response = await supabase.from('transactions').insert({
    'user_id': userId,
    'category_id': categoryId,
    'type': type,
    'amount': amount,
    'description': description,
    'notes': notes,
    'transaction_date': (transactionDate ?? DateTime.now()).toIso8601String(),
    'input_method': 'manual',
  }).select().single();
  
  return response;
}
```

### Get Transactions (Paginated)
```dart
Future<List<Map<String, dynamic>>> getTransactions({
  DateTime? startDate,
  DateTime? endDate,
  String? type,
  String? categoryId,
  int limit = 20,
  int offset = 0,
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  var query = supabase
      .from('transactions')
      .select('*, categories(name, icon, color)')
      .eq('user_id', userId);
  
  if (startDate != null) {
    query = query.gte('transaction_date', startDate.toIso8601String());
  }
  if (endDate != null) {
    query = query.lte('transaction_date', endDate.toIso8601String());
  }
  if (type != null) {
    query = query.eq('type', type);
  }
  if (categoryId != null) {
    query = query.eq('category_id', categoryId);
  }
  
  final response = await query
      .order('transaction_date', ascending: false)
      .order('created_at', ascending: false)
      .range(offset, offset + limit - 1);
  
  return List<Map<String, dynamic>>.from(response);
}
```

### Create Transaction from OCR (OpenRouter Vision)
```dart
Future<Map<String, dynamic>> scanReceiptAndCreateTransaction({
  required String receiptImageUrl, // URL gambar di Supabase Storage
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  // 1. Call OCR Edge Function
  final ocrResponse = await supabase.functions.invoke(
    'ocr-receipt',
    body: {
      'image_url': receiptImageUrl,
      'user_id': userId,
    },
  );
  
  if (ocrResponse.status != 200 || ocrResponse.data['success'] != true) {
    throw Exception('OCR failed: ${ocrResponse.data['error']}');
  }
  
  final ocrData = ocrResponse.data['data'];
  
  // 2. Show confirmation dialog to user
  // User can edit amount, choose category, add notes
  
  // 3. Create transaction
  final transaction = await supabase.from('transactions').insert({
    'user_id': userId,
    'category_id': ocrData['suggested_category']['id'], // User bisa ganti
    'type': 'expense',
    'amount': ocrData['total_amount'],
    'description': ocrData['merchant_name'] ?? 'Belanja',
    'receipt_image_url': receiptImageUrl,
    'merchant_name': ocrData['merchant_name'],
    'ocr_raw_data': {
      'items': ocrData['items'],
      'confidence': ocrData['confidence'],
      'ocr_log_id': ocrData['ocr_log_id'],
    },
    'input_method': 'ocr',
  }).select().single();
  
  return transaction;
}

// Full flow example:
Future<void> scanReceiptFlow() async {
  // 1. User ambil foto atau pilih dari galeri
  final imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
  
  // 2. Upload ke Supabase Storage
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  await supabase.storage
      .from('receipts')
      .upload('${supabase.auth.currentUser!.id}/$fileName', imageFile!);
  
  final imageUrl = supabase.storage
      .from('receipts')
      .getPublicUrl('${supabase.auth.currentUser!.id}/$fileName');
  
  // 3. Scan with OCR
  final transaction = await scanReceiptAndCreateTransaction(
    receiptImageUrl: imageUrl,
  );
  
  print('Transaction created: ${transaction['amount']}');
}
```

### Get Monthly Summary
```dart
Future<Map<String, dynamic>> getMonthlySummary({
  required int year,
  required int month,
}) async {
  final userId = supabase.auth.currentUser!.id;
  final startDate = DateTime(year, month, 1);
  final endDate = DateTime(year, month + 1, 0);
  
  final transactions = await supabase
      .from('transactions')
      .select('type, amount')
      .eq('user_id', userId)
      .gte('transaction_date', startDate.toIso8601String())
      .lte('transaction_date', endDate.toIso8601String());
  
  double totalIncome = 0;
  double totalExpense = 0;
  
  for (var tx in transactions) {
    if (tx['type'] == 'income') {
      totalIncome += tx['amount'];
    } else {
      totalExpense += tx['amount'];
    }
  }
  
  return {
    'total_income': totalIncome,
    'total_expense': totalExpense,
    'net_savings': totalIncome - totalExpense,
  };
}
```

## 4. Budgets

### Create Budget
```dart
Future<Map<String, dynamic>> createBudget({
  required String name,
  required double amount,
  required String period, // 'daily', 'weekly', 'monthly', 'yearly'
  required DateTime startDate,
  required DateTime endDate,
  String? categoryId,
  int alertThreshold = 80,
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  final response = await supabase.from('budgets').insert({
    'user_id': userId,
    'name': name,
    'amount': amount,
    'period': period,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'category_id': categoryId,
    'alert_threshold': alertThreshold,
    'is_active': true,
  }).select().single();
  
  return response;
}
```

### Get Active Budgets with Spending
```dart
Future<List<Map<String, dynamic>>> getActiveBudgets() async {
  final userId = supabase.auth.currentUser!.id;
  final now = DateTime.now();
  
  final budgets = await supabase
      .from('budgets')
      .select('*, categories(name, icon, color)')
      .eq('user_id', userId)
      .eq('is_active', true)
      .lte('start_date', now.toIso8601String())
      .gte('end_date', now.toIso8601String());
  
  // Calculate spending for each budget
  for (var budget in budgets) {
    final spending = await _getBudgetSpending(
      budget['id'],
      DateTime.parse(budget['start_date']),
      DateTime.parse(budget['end_date']),
      budget['category_id'],
    );
    
    budget['current_spending'] = spending;
    budget['percentage'] = (spending / budget['amount'] * 100).clamp(0, 100);
  }
  
  return List<Map<String, dynamic>>.from(budgets);
}

Future<double> _getBudgetSpending(
  String budgetId,
  DateTime startDate,
  DateTime endDate,
  String? categoryId,
) async {
  final userId = supabase.auth.currentUser!.id;
  
  var query = supabase
      .from('transactions')
      .select('amount')
      .eq('user_id', userId)
      .eq('type', 'expense')
      .gte('transaction_date', startDate.toIso8601String())
      .lte('transaction_date', endDate.toIso8601String());
  
  if (categoryId != null) {
    query = query.eq('category_id', categoryId);
  }
  
  final transactions = await query;
  
  return transactions.fold<double>(
    0,
    (sum, tx) => sum + (tx['amount'] as num).toDouble(),
  );
}
```

## 5. AI Chatbot

### Create Conversation
```dart
Future<Map<String, dynamic>> createConversation({
  String? title,
  String persona = 'wise_mentor', // 'wise_mentor', 'friendly_companion', 'professional_advisor'
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  final response = await supabase.from('chat_conversations').insert({
    'user_id': userId,
    'title': title ?? 'Chat ${DateTime.now().toString().split(' ')[0]}',
    'persona': persona,
  }).select().single();
  
  return response;
}
```

### Send Message & Get AI Response (OpenRouter)
```dart
Future<Map<String, dynamic>> sendMessage({
  required String conversationId,
  required String message,
}) async {
  // Call Edge Function (yang pake OpenRouter)
  final response = await supabase.functions.invoke(
    'ai-chat',
    body: {
      'conversation_id': conversationId,
      'message': message,
    },
  );
  
  if (response.status != 200) {
    throw Exception('Failed to send message: ${response.data}');
  }
  
  return response.data;
}

// Usage example:
void main() async {
  final conv = await createConversation(persona: 'friendly_companion');
  
  final reply = await sendMessage(
    conversationId: conv['id'],
    message: 'Halo! Aku beli makan siang 50rb tadi',
  );
  
  print('AI Reply: ${reply['message']}');
  print('Persona: ${reply['persona']}'); // Dina
  
  // Jika AI detect transaksi
  if (reply['intent'] == 'record_transaction') {
    print('Amount: ${reply['extracted_data']['amount']}');
    print('Type: ${reply['extracted_data']['type']}');
    // Flutter akan show dialog untuk confirm & pilih category
  }
}
```

### Get Conversation History
```dart
Future<List<Map<String, dynamic>>> getMessages({
  required String conversationId,
  int limit = 50,
}) async {
  final response = await supabase
      .from('chat_messages')
      .select()
      .eq('conversation_id', conversationId)
      .order('created_at', ascending: true)
      .limit(limit);
  
  return List<Map<String, dynamic>>.from(response);
}
```

## 6. Gamification

### Get User Badges
```dart
Future<List<Map<String, dynamic>>> getUserBadges() async {
  final userId = supabase.auth.currentUser!.id;
  
  final response = await supabase
      .from('user_badges')
      .select('*, badges(*)')
      .eq('user_id', userId)
      .order('earned_at', ascending: false);
  
  return List<Map<String, dynamic>>.from(response);
}
```

### Get Daily Missions
```dart
Future<List<Map<String, dynamic>>> getDailyMissions() async {
  final userId = supabase.auth.currentUser!.id;
  final today = DateTime.now();
  
  // Get or create today's missions
  var userMissions = await supabase
      .from('user_missions')
      .select('*, missions(*)')
      .eq('user_id', userId)
      .gte('started_at', DateTime(today.year, today.month, today.day).toIso8601String())
      .eq('status', 'in_progress');
  
  if (userMissions.isEmpty) {
    // Create today's missions
    await _createDailyMissions(userId);
    userMissions = await supabase
        .from('user_missions')
        .select('*, missions(*)')
        .eq('user_id', userId)
        .gte('started_at', DateTime(today.year, today.month, today.day).toIso8601String());
  }
  
  return List<Map<String, dynamic>>.from(userMissions);
}

Future<void> _createDailyMissions(String userId) async {
  final dailyMissions = await supabase
      .from('missions')
      .select()
      .eq('type', 'daily')
      .eq('is_active', true);
  
  for (var mission in dailyMissions) {
    await supabase.from('user_missions').insert({
      'user_id': userId,
      'mission_id': mission['id'],
      'current_progress': 0,
      'target_progress': mission['requirement_value'],
      'expires_at': DateTime.now().add(Duration(days: 1)).toIso8601String(),
    });
  }
}
```

### Update Mission Progress
```dart
Future<void> updateMissionProgress({
  required String userMissionId,
  required int progress,
}) async {
  final response = await supabase
      .from('user_missions')
      .select('target_progress, missions(xp_reward, points_reward)')
      .eq('id', userMissionId)
      .single();
  
  final targetProgress = response['target_progress'];
  final isCompleted = progress >= targetProgress;
  
  await supabase.from('user_missions').update({
    'current_progress': progress,
    'status': isCompleted ? 'completed' : 'in_progress',
    'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
  }).eq('id', userMissionId);
  
  if (isCompleted) {
    // Award XP & points
    final xp = response['missions']['xp_reward'] ?? 0;
    final points = response['missions']['points_reward'] ?? 0;
    await _awardXPAndPoints(xp, points);
  }
}

Future<void> _awardXPAndPoints(int xp, int points) async {
  final userId = supabase.auth.currentUser!.id;
  
  await supabase.rpc('add_xp_and_points', params: {
    'user_id': userId,
    'xp_amount': xp,
    'points_amount': points,
  });
}
```

## 7. Investment Education

### Get Courses (News-based)
```dart
Future<List<Map<String, dynamic>>> getCourses({
  String? level,
  String? category,
}) async {
  var query = supabase
      .from('courses')
      .select()
      .eq('is_published', true);
  
  if (level != null) {
    query = query.eq('level', level);
  }
  if (category != null) {
    query = query.eq('category', category);
  }
  
  final response = await query.order('order_index');
  return List<Map<String, dynamic>>.from(response);
}
```

### Get Course News/Articles
```dart
Future<List<Map<String, dynamic>>> getCourseArticles({
  required String courseId,
}) async {
  // Call Edge Function to fetch news
  final response = await supabase.functions.invoke(
    'fetch-news',
    body: {
      'course_id': courseId,
    },
  );
  
  if (response.status != 200 || response.data['success'] != true) {
    throw Exception('Failed to fetch news: ${response.data['error']}');
  }
  
  return List<Map<String, dynamic>>.from(response.data['articles']);
}

// Usage example:
void main() async {
  final courses = await getCourses(level: 'beginner');
  
  for (var course in courses) {
    print('Course: ${course['title']}');
    
    final articles = await getCourseArticles(courseId: course['id']);
    
    for (var article in articles) {
      print('  - ${article['title']}');
      print('    Source: ${article['source']}');
      print('    URL: ${article['url']}');
      if (article['image_url'] != null) {
        print('    Image: ${article['image_url']}');
      }
    }
  }
}
```

### Enroll in Course (Track Reading)
```dart
Future<Map<String, dynamic>> enrollInCourse({
  required String courseId,
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  final response = await supabase.from('user_course_progress').insert({
    'user_id': userId,
    'course_id': courseId,
    'read_articles': [],
    'total_articles_read': 0,
  }).select().single();
  
  return response;
}
```

### Update Course Progress
```dart
Future<void> markArticleAsRead({
  required String courseId,
  required String articleUrl,
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  // Get or create progress
  var progress = await supabase
      .from('user_course_progress')
      .select()
      .eq('user_id', userId)
      .eq('course_id', courseId)
      .maybeSingle();
  
  if (progress == null) {
    // Create new progress
    progress = await supabase.from('user_course_progress').insert({
      'user_id': userId,
      'course_id': courseId,
      'read_articles': [],
      'total_articles_read': 0,
    }).select().single();
  }
  
  // Add article URL to read list
  final readArticles = List<String>.from(progress['read_articles'] ?? []);
  if (!readArticles.contains(articleUrl)) {
    readArticles.add(articleUrl);
    
    await supabase.from('user_course_progress').update({
      'read_articles': readArticles,
      'total_articles_read': readArticles.length,
      'last_accessed_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId).eq('course_id', courseId);
    
    // Award XP for reading
    // Optional: bisa tambah XP setiap baca artikel
  }
}

// Get reading stats
Future<Map<String, dynamic>> getCourseReadingStats({
  required String courseId,
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  final progress = await supabase
      .from('user_course_progress')
      .select()
      .eq('user_id', userId)
      .eq('course_id', courseId)
      .maybeSingle();
  
  return {
    'total_articles_read': progress?['total_articles_read'] ?? 0,
    'read_articles': progress?['read_articles'] ?? [],
    'last_accessed': progress?['last_accessed_at'],
  };
}
```

## 8. Virtual Trading

### Get Portfolio
```dart
Future<Map<String, dynamic>> getVirtualPortfolio() async {
  final userId = supabase.auth.currentUser!.id;
  
  final response = await supabase
      .from('virtual_portfolios')
      .select('*, virtual_positions(*)')
      .eq('user_id', userId)
      .eq('is_active', true)
      .single();
  
  return response;
}
```

### Execute Trade
```dart
Future<Map<String, dynamic>> executeTrade({
  required String portfolioId,
  required String type, // 'buy' or 'sell'
  required String assetSymbol,
  required String assetType,
  required double quantity,
  required double price,
}) async {
  final totalAmount = quantity * price;
  final fee = totalAmount * 0.001; // 0.1% fee
  
  // Insert transaction
  final transaction = await supabase.from('virtual_transactions').insert({
    'portfolio_id': portfolioId,
    'type': type,
    'asset_symbol': assetSymbol,
    'asset_type': assetType,
    'quantity': quantity,
    'price': price,
    'total_amount': totalAmount,
    'fee': fee,
  }).select().single();
  
  // Update portfolio balance
  final portfolio = await supabase
      .from('virtual_portfolios')
      .select('current_balance')
      .eq('id', portfolioId)
      .single();
  
  final newBalance = type == 'buy'
      ? portfolio['current_balance'] - (totalAmount + fee)
      : portfolio['current_balance'] + (totalAmount - fee);
  
  await supabase.from('virtual_portfolios').update({
    'current_balance': newBalance,
  }).eq('id', portfolioId);
  
  // Update or create position
  if (type == 'buy') {
    await _createOrUpdatePosition(portfolioId, assetSymbol, assetType, quantity, price);
  } else {
    await _reducePosition(portfolioId, assetSymbol, quantity);
  }
  
  return transaction;
}
```

## 9. Financial Insights

### Get Insights
```dart
Future<List<Map<String, dynamic>>> getFinancialInsights({
  bool unreadOnly = false,
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  var query = supabase
      .from('financial_insights')
      .select()
      .eq('user_id', userId)
      .eq('is_dismissed', false);
  
  if (unreadOnly) {
    query = query.eq('is_read', false);
  }
  
  final response = await query
      .order('priority', ascending: false)
      .order('created_at', ascending: false);
  
  return List<Map<String, dynamic>>.from(response);
}
```

### Get Spending Pattern
```dart
Future<Map<String, dynamic>?> getSpendingPattern({
  required DateTime periodStart,
  required DateTime periodEnd,
}) async {
  final userId = supabase.auth.currentUser!.id;
  
  final response = await supabase
      .from('spending_patterns')
      .select()
      .eq('user_id', userId)
      .eq('period_start', periodStart.toIso8601String().split('T')[0])
      .eq('period_end', periodEnd.toIso8601String().split('T')[0])
      .maybeSingle();
  
  return response;
}
```

---

## Supabase Edge Functions

Edge Functions sudah dibuat di folder `supabase/functions/`:

### 1. AI Chat Function (`ai-chat/index.ts`)
- **Purpose**: Chatbot dengan 3 persona menggunakan OpenRouter API
- **Models**: 
  - Pak Arief (Claude 3.5 Sonnet) - Mentor bijaksana
  - Dina (GPT-4 Turbo) - Teman friendly
  - Sarah (Gemini Pro 1.5) - Advisor profesional
- **Features**:
  - Auto-detect transaction intent
  - Extract amount dari chat
  - Save conversation history

### 2. OCR Receipt Function (`ocr-receipt/index.ts`)
- **Purpose**: Scan struk belanja menggunakan OpenRouter Vision
- **Model**: Google Gemini Pro Vision
- **Features**:
  - Extract merchant name, total, items
  - Auto-suggest category
  - High accuracy OCR

### 3. Fetch News Function (`fetch-news/index.ts`)
- **Purpose**: Fetch berita investasi dari News API
- **Features**:
  - Real-time financial news
  - Filter by category & language
  - Customizable per course

## Environment Variables

Set di Supabase Dashboard → Settings → Edge Functions:

```bash
# OpenRouter API (untuk AI Chat & OCR)
OPENROUTER_API_KEY=sk-or-v1-xxxxx

# News API (untuk Investment Courses)
NEWS_API_KEY=xxxxx

# Supabase (auto-provided)
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=xxxxx
```

## Deploy Edge Functions

```bash
# Deploy semua functions
supabase functions deploy ai-chat
supabase functions deploy ocr-receipt
supabase functions deploy fetch-news

# Atau deploy sekaligus
supabase functions deploy
```

## Get API Keys

1. **OpenRouter**: https://openrouter.ai/keys
   - Daftar gratis
   - Support 100+ AI models
   - Pay per use (sangat murah)
   
2. **News API**: https://newsapi.org/register
   - Free tier: 100 requests/day
   - Berita dari 80,000+ sumber

---

## Testing

### Run Local Supabase
```bash
supabase start
supabase db reset
```

### Test API Calls
```dart
void main() async {
  // Setup
  await Supabase.initialize(...);
  
  // Test sign up
  await signUpWithProfile(
    email: 'test@example.com',
    password: 'password123',
    fullName: 'Test User',
  );
  
  // Test create transaction
  final categories = await getCategories(type: 'expense');
  await createTransaction(
    categoryId: categories.first['id'],
    type: 'expense',
    amount: 50000,
    description: 'Makan siang',
  );
  
  // Test get transactions
  final transactions = await getTransactions(limit: 10);
  print('Transactions: ${transactions.length}');
}
```

---

**Note**: Pastikan untuk menangani error dengan proper try-catch dan memberikan feedback ke user!
