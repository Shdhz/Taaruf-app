import 'package:taaruf_app/main.dart';

class UserQuestionService {
  // 🔹 Ambil pertanyaan custom dari user
  Future<List<Map<String, dynamic>>> getUserQuestions(String userId) async {
    final response = await supabase
        .from('user_questions')
        .select('''
          id, 
          custom_question_text, 
          question_order,
          question_id,
          default_questions!inner(question_text)
        ''')
        .eq('user_id', userId)
        .order('question_order');

    return List<Map<String, dynamic>>.from(response);
  }

  // 🔹 Tambah pertanyaan user (custom atau default)
  Future<String?> addUserQuestion({
    required String userId,
    String? customText,
    String? defaultQuestionId,
    int? questionOrder, // sekarang optional
  }) async {
    try {
      // 🔍 Hitung order terakhir jika tidak diberikan
      int finalOrder = questionOrder ?? 1;

      if (questionOrder == null) {
        final existing = await supabase
            .from('user_questions')
            .select('question_order')
            .eq('user_id', userId);

        final existingOrders =
            existing
                .map((q) => q['question_order'] as int?)
                .where((q) => q != null)
                .toList();

        if (existingOrders.isNotEmpty) {
          finalOrder =
              (existingOrders.reduce((a, b) => a! > b! ? a : b) ?? 0) + 1;
        }
      }

      final Map<String, dynamic> data = {
        'user_id': userId,
        'question_order': finalOrder,
      };

      // Jika custom question
      if (customText != null && customText.trim().isNotEmpty) {
        data['custom_question_text'] = customText.trim();
      }

      // Jika default question
      if (defaultQuestionId != null && defaultQuestionId.isNotEmpty) {
        data['question_id'] = defaultQuestionId;
      }

      final response =
          await supabase
              .from('user_questions')
              .insert(data)
              .select('id')
              .single();

      return response['id']?.toString();
    } catch (e) {
      print('❌ Error addUserQuestion: $e');
      return null;
    }
  }

  // 🔹 Hapus pertanyaan user berdasarkan ID
  Future<void> deleteUserQuestion(String userQuestionId) async {
    await supabase.from('user_questions').delete().eq('id', userQuestionId);
  }

  // 🔹 Submit taaruf proposal: buat match + pertanyaan
  Future<String> submitTaarufProposal({
    required String requesterId,
    required String requestedId,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      // 🔍 Cek apakah requested user juga pernah mengirim (reverse match)
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

      // 🔒 Batasi maksimal 2 lamaran pending
      final pendingCount = await supabase
          .from('matches')
          .select('id')
          .eq('requester_id', requesterId)
          .eq('status', 'pending');

      if (pendingCount.length >= 2) {
        return 'MAX_PENGAJUAN';
      }

      // ✅ Buat match baru
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

      final matchId = matchResponse['id'];
      if (matchId == null) {
        throw Exception('Failed to create match');
      }

      // 💾 Simpan pertanyaan ke match_answers
      for (final q in questions) {
        if (q['question_id'] != null) {
          await supabase.from('match_answers').insert({
            'match_id': matchId,
            'question_id': q['question_id'],
            'questioner_id': requesterId,
            'responder_id': requestedId,
            'answer_text': q['answer_text'] ?? '',
          });
        }
      }

      return 'OK';
    } catch (e) {
      return 'ERROR';
    }
  }

  // 🔹 Ambil pertanyaan untuk match tertentu (untuk responden)
  Future<List<Map<String, dynamic>>> getMatchQuestions(String matchId) async {
    try {
      final response = await supabase
          .from('match_answers')
          .select('''
            id,
            answer_text,
            user_questions!inner(
              id,
              custom_question_text,
              question_order,
              default_questions(question_text)
            )
          ''')
          .eq('match_id', matchId)
          .order('user_questions.question_order');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // 🔹 Submit jawaban dari responder
  Future<bool> submitAnswers({
    required String matchId,
    required List<Map<String, dynamic>>
    answers, // [{'answer_id': 'uuid', 'answer_text': 'text'}]
  }) async {
    try {
      for (final answer in answers) {
        await supabase
            .from('match_answers')
            .update({
              'answer_text': answer['answer_text'],
              'answered_at': DateTime.now().toIso8601String(),
            })
            .eq('id', answer['answer_id']);
      }

      // Update status match menjadi answered dari sisi responder
      await supabase
          .from('matches')
          .update({'requested_answered': true})
          .eq('id', matchId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // 🔹 Cek apakah user sudah pernah membuat pertanyaan dengan order tertentu
  Future<bool> hasQuestionOrder(String userId, int order) async {
    try {
      final response =
          await supabase
              .from('user_questions')
              .select('id')
              .eq('user_id', userId)
              .eq('question_order', order)
              .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // 🔹 Hapus pertanyaan user yang tidak terpakai (setelah match selesai/ditolak)
  Future<void> cleanupUserQuestions(String userId, String matchId) async {
    try {
      // Ambil question_ids yang digunakan di match ini
      final usedQuestions = await supabase
          .from('match_answers')
          .select('question_id')
          .eq('match_id', matchId)
          .eq('questioner_id', userId);

      final usedQuestionIds =
          usedQuestions
              .map((q) => q['question_id'])
              .where((id) => id != null)
              .toList();

      if (usedQuestionIds.isNotEmpty) {
        // Hapus user_questions yang digunakan untuk match ini
        await supabase
            .from('user_questions')
            .delete()
            .eq('user_id', userId)
            .inFilter('id', usedQuestionIds);
      }
    } catch (e) {
      return;
    }
  }

  // 🔹 Cek apakah user memiliki lamaran pending
  Future<bool> hasPendingMatches(String userId) async {
    try {
      final response =
          await supabase
              .from('matches')
              .select('id')
              .eq('requester_id', userId)
              .eq('status', 'pending')
              .limit(1)
              .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
