import 'package:taaruf_app/main.dart';

class UserQuestionService {
  // Ambil pertanyaan custom dari user
  Future<List<Map<String, dynamic>>> getUserQuestions(String userId) async {
    final response = await supabase
        .from('user_questions')
        .select('custom_question_text, question_order')
        .eq('user_id', userId)
        .order('question_order');

    return List<Map<String, dynamic>>.from(response);
  }

  // Tambah pertanyaan user
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

    await supabase.from('user_questions').insert(data);
  }

  // Hapus pertanyaan user berdasarkan id
  Future<void> deleteUserQuestion(String userQuestionId) async {
    await supabase.from('user_questions').delete().eq('id', userQuestionId);
  }

  // 🔹 Proses submit taaruf (buat match + pertanyaan)
  Future<String> submitTaarufProposal({
    required String requesterId,
    required String requestedId,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      // Cek apakah sudah ada pengajuan dari si requested ke requester (dibalik)
      final existingMatch =
          await supabase
              .from('matches')
              .select('id')
              .or(
                'and(requester_id.eq.$requestedId,requested_id.eq.$requesterId,status.eq.pending)',
              )
              .maybeSingle();

      if (existingMatch != null) {
        return 'PENGAJUAN_SUDAH_ADA';
      }

      // Buat match baru
      final matchResponse =
          await supabase
              .from('matches')
              .insert({
                'requester_id': requesterId,
                'requested_id': requestedId,
                'status': 'pending',
              })
              .select('id')
              .single();

      final matchId = matchResponse['id'] as String?;
      if (matchId == null) throw Exception('Gagal membuat match.');

      // Simpan pertanyaan
      for (final q in questions) {
        await supabase.from('match_answers').insert({
          'match_id': matchId,
          'question_id': q['question_id'],
          'questioner_id': requesterId,
          'responder_id': requestedId,
          'answer_text': q['answer_text'],
        });
      }

      return 'OK';
    } catch (e) {
      return 'ERROR';
    }
  }
}
