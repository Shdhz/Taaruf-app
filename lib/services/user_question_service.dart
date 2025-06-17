import 'package:taaruf_app/main.dart';

class UserQuestionService {

  Future<List<Map<String, dynamic>>> getUserQuestions(String userId) async {
    final response = await supabase
        .from('user_questions')
        .select('custom_question_text, question_order')
        .eq('user_id', userId)
        .order('question_order');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addUserQuestion({
    required String userId,
    String? customText,
    String? defaultQuestionId,
    required int questionOrder,
  }) async {
    final data = {
      'user_id': userId,
      'question_order': questionOrder,
      'custom_question_text': customText,
      'question_id': defaultQuestionId,
    };

    // Jika pakai customText saja, defaultQuestionId = null
    await supabase.from('user_questions').insert(data);
  }

  Future<void> deleteUserQuestion(String userQuestionId) async {
    await supabase.from('user_questions').delete().eq('id', userQuestionId);
  }
}
