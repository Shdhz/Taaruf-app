// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taaruf_app/services/user_question_service.dart';
import 'package:taaruf_app/widget/card/card_calon_taaruf.dart';

class DetailProfileCalon extends StatefulWidget {
  const DetailProfileCalon({super.key});

  @override
  State<DetailProfileCalon> createState() => _DetailProfileCalonState();
}

class _DetailProfileCalonState extends State<DetailProfileCalon> {
  final CardCalonTaaruf user = Get.arguments;
  final userQuestionService = UserQuestionService();
  final TextEditingController questionController = TextEditingController();

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Get.back(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Profile Image
                  Image.network(
                    user.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Name and age overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      user.gender == 'Ikhwan'
                                          ? Icons.male
                                          : Icons.female,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${user.age} tahun",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),
                              if (user.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Siap taaruf',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Biodata Section
                  _buildModernSection(
                    title: "Biodata",
                    icon: Icons.person_outline,
                    child: Column(
                      children: [
                        _buildModernDetailItem(
                          Icons.work_outline,
                          "Pekerjaan",
                          user.biodata["occupation_category"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.business_center_outlined,
                          "Detail Pekerjaan",
                          user.biodata["occupation_detail"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.location_on_outlined,
                          "Domisili",
                          user.biodata["province"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.school_outlined,
                          "Pendidikan",
                          user.biodata["education_level"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.height,
                          "Tinggi Badan",
                          (user.biodata["height"] ?? "-").toString(),
                        ),
                        _buildModernDetailItem(
                          Icons.monitor_weight_outlined,
                          "Berat Badan",
                          user.biodata["weight"] != null
                              ? user.biodata["weight"].toString()
                              : "-",
                        ),
                        _buildModernDetailItem(
                          Icons.favorite_outline,
                          "Status Pernikahan",
                          user.biodata["marital_status"] ?? "-",
                        ),
                      ],
                    ),
                  ),

                  // About Me Section
                  if (user.biodata["about_me"] != null &&
                      user.biodata["about_me"].toString().trim().isNotEmpty)
                    _buildModernSection(
                      title: "Tentang Saya",
                      icon: Icons.info_outline,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          user.biodata["about_me"].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),

                  // Nasab Section
                  _buildModernSection(
                    title: "Nasab",
                    icon: Icons.family_restroom,
                    child: Column(
                      children: [
                        _buildModernDetailItem(
                          Icons.groups_outlined,
                          "Suku",
                          user.nasab["tribe"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.map_outlined,
                          "Asal Provinsi",
                          user.nasab["origin_province"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.location_city_outlined,
                          "Asal Kota",
                          user.nasab["origin_city"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.man,
                          "Nama Ayah",
                          user.nasab["father_name"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.work_outline,
                          "Pekerjaan Ayah",
                          user.nasab["father_occupation"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.woman,
                          "Nama Ibu",
                          user.nasab["mother_name"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.work_outline,
                          "Pekerjaan Ibu",
                          user.nasab["mother_occupation"] ?? "-",
                        ),
                        _buildModernDetailItem(
                          Icons.people_outline,
                          "Jumlah Saudara",
                          (user.nasab["siblings_count"] ?? "-").toString(),
                        ),
                        _buildModernDetailItem(
                          Icons.child_care,
                          "Anak ke-",
                          (user.nasab["child_position"] ?? "-").toString(),
                        ),
                        _buildModernDetailItem(
                          Icons.home_outlined,
                          "Latar Belakang Keluarga",
                          user.nasab["family_background"] ?? "-",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildModernSection(
                    title: "Jawaban Pertanyaan Taaruf",
                    icon: Icons.quiz_outlined,
                    child:
                        user.userQuestions.isEmpty
                            ? Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.quiz_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Belum mengisi jawaban pertanyaan",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 400, // Batasi tinggi maksimum
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children:
                                      user.userQuestions.map((q) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.02,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.help_outline,
                                                    size: 20,
                                                    color:
                                                        Colors.deepPurple[300],
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      q['custom_question_text'] ??
                                                          'Pertanyaan tidak diketahui',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            color:
                                                                Colors
                                                                    .deepPurple,
                                                          ),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                width: double.infinity,
                                                constraints: const BoxConstraints(
                                                  maxHeight:
                                                      120, // Batasi tinggi jawaban
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[50],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: SingleChildScrollView(
                                                  child: Text(
                                                    q['answer_text'] ?? "-",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      height: 1.4,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Indicator jika jawaban terpotong
                                              if ((q['answer_text'] ?? "")
                                                      .length >
                                                  150)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.more_horiz,
                                                        color: Colors.grey[400],
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        "Scroll untuk membaca selengkapnya",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 11,
                                                              color:
                                                                  Colors
                                                                      .grey[500],
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button for proposal
      // Floating Action Button for proposal
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: FloatingActionButton.extended(
          onPressed: () {
            _showTaarufProposalModal(context, user);
          },
          backgroundColor: Colors.deepPurple,
          elevation: 8,
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mail_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                "Kirim CV Taaruf",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Fungsi untuk menampilkan modal ajukan taaruf
void _showTaarufProposalModal(BuildContext context, CardCalonTaaruf user) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: TaarufProposalForm(
          targetUserId: user.id,
          targetUserName: user.name,
        ),
      );
    },
  );
}

Widget _buildModernSection({
  required String title,
  required IconData icon,
  required Widget child,
  Widget? action, // <- tambahkan parameter tombol atau widget tambahan
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.deepPurple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),

                  // Tampilkan tombol jika ada
                  if (action != null) ...[const SizedBox(width: 12), action],
                ],
              ),
            ),
          ),
        ),

        // Section Content
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildModernDetailItem(IconData icon, String title, String value) {
  if (value.trim().isEmpty || value == "-") {
    return const SizedBox.shrink();
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple[300]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// widget ajukan proposal taaruf
class TaarufProposalForm extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;

  const TaarufProposalForm({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  State<TaarufProposalForm> createState() => _TaarufProposalFormState();
}

class _TaarufProposalFormState extends State<TaarufProposalForm> {
  final TextEditingController customQuestionController =
      TextEditingController();
  final supabase = Supabase.instance.client;
  final userQuestionService = UserQuestionService();

  List<Map<String, dynamic>> defaultQuestions = [];
  List<dynamic> selectedQuestionIds = [];
  String customQuestion = '';
  bool isLoading = false;
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultQuestions();
  }

  @override
  void dispose() {
    customQuestionController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultQuestions() async {
    try {
      final response = await supabase
          .from('default_questions')
          .select('id, question_text')
          .eq('is_active', true)
          .order('popularity_score', ascending: false)
          .limit(5);

      setState(() {
        defaultQuestions = List<Map<String, dynamic>>.from(response);
        isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingData = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat pertanyaan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitTaarufProposal() async {
    if (selectedQuestionIds.isEmpty && customQuestion.trim().isEmpty) {
      _showSnackBar(
        'Pilih minimal 1 pertanyaan atau tulis pertanyaan custom',
        color: Colors.orange,
        icon: Icons.warning_amber_outlined,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) throw Exception('User tidak terautentikasi');

      /// ✅ Cek apakah sudah pernah kirim ke target ini dalam status pending, maksimal 2x
      final sentToTarget = await supabase
          .from('matches')
          .select('id')
          .eq('requester_id', currentUser.id)
          .eq('requested_id', widget.targetUserId)
          .eq('status', 'pending');

      if (sentToTarget.length >= 2) {
        _showSnackBar(
          'Kamu sudah mengirim lamaran ke pengguna ini maksimal 2 kali. Tunggu responnya.',
          color: Colors.orange,
          icon: Icons.info_outline,
        );
        return;
      }

      /// ✅ Siapkan pertanyaan
      final List<Map<String, dynamic>> allQuestions = [];
      int questionOrder = 1;

      // 🔹 Tambahkan pertanyaan default
      for (final questionId in selectedQuestionIds) {
        final userQuestionId = await userQuestionService.addUserQuestion(
          userId: currentUser.id,
          defaultQuestionId: questionId.toString(),
          questionOrder: questionOrder++,
        );

        if (userQuestionId != null) {
          allQuestions.add({
            'user_question_id': userQuestionId,
            'answer_text': '',
          });
        } else {
          throw Exception("Gagal menyimpan pertanyaan default");
        }
      }

      // 🔹 Tambahkan pertanyaan custom jika ada
      if (customQuestion.trim().isNotEmpty) {
        final customUserQuestionId = await userQuestionService.addUserQuestion(
          userId: currentUser.id,
          customText: customQuestion.trim(),
          questionOrder: questionOrder,
        );

        if (customUserQuestionId != null) {
          allQuestions.add({
            'user_question_id': customUserQuestionId,
            'answer_text': '',
          });
        } else {
          throw Exception("Gagal menyimpan pertanyaan custom");
        }
      }

      /// ✅ Kirim lamaran taaruf
      final result = await userQuestionService.submitTaarufProposal(
        requesterId: currentUser.id,
        requestedId: widget.targetUserId,
        questions: allQuestions,
      );

      if (result == 'PENGAJUAN_SUDAH_ADA') {
        _showSnackBar(
          'Target pengguna sudah mengirim lamaran ke kamu. Cek inbox untuk merespons.',
          color: Colors.orange,
          icon: Icons.info_outline,
        );
        return;
      }

      if (result == 'MAX_PENGAJUAN') {
        _showSnackBar(
          'Kamu hanya bisa mengirim maksimal 2 lamaran yang belum direspon.',
          color: Colors.orange,
          icon: Icons.warning_amber_outlined,
        );
        return;
      }

      if (result != 'OK') throw Exception("Gagal mengirim lamaran");

      Navigator.pop(context);
      _showSnackBar(
        'Lamaran taaruf berhasil dikirim ke ${widget.targetUserName}',
        color: Colors.green,
        icon: Icons.check_circle_outline,
      );
    } catch (e) {
      String errorMessage = 'Gagal mengirim lamaran.';

      if (e.toString().contains('terautentikasi')) {
        errorMessage = 'Silakan login terlebih dahulu.';
      } else if (e.toString().contains('default')) {
        errorMessage = 'Gagal menyimpan pertanyaan yang dipilih. Coba lagi.';
      } else if (e.toString().contains('custom')) {
        errorMessage = 'Pertanyaan custom gagal disimpan. Coba lagi.';
      } else if (e.toString().contains('lamaran')) {
        errorMessage = 'Terjadi kesalahan saat mengirim lamaran.';
      }

      _showSnackBar(errorMessage, color: Colors.red, icon: Icons.error_outline);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(
    String message, {
    Color color = Colors.red,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 10,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline, color: Colors.deepPurple, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Ajukan Taaruf",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Kepada: ${widget.targetUserName}",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(
            "Pilih pertanyaan yang ingin kamu ajukan (maksimal 5 pertanyaan):",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          if (isLoadingData)
            const Center(child: CircularProgressIndicator())
          else if (defaultQuestions.isNotEmpty) ...[
            Text(
              "Pertanyaan Pilihan:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            ...defaultQuestions.map((question) {
              final isSelected = selectedQuestionIds.contains(question['id']);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      final id = question['id'];

                      if (value == true) {
                        if (!selectedQuestionIds.contains(id) &&
                            selectedQuestionIds.length < 5) {
                          selectedQuestionIds.add(id);
                        }
                      } else {
                        selectedQuestionIds.remove(id);
                      }
                    });
                  },
                  title: Text(
                    question['question_text'],
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            }),
          ] else
            Text(
              "Tidak ada pertanyaan default yang tersedia saat ini.",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),

          const SizedBox(height: 20),

          Text(
            "Atau tambahkan pertanyaanmu sendiri:",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: customQuestionController,
            maxLines: 3,
            onChanged: (val) => setState(() => customQuestion = val),
            decoration: InputDecoration(
              hintText: "Contoh: Apa tujuan utama kamu dalam menikah?",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitTaarufProposal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        "Kirim CV taaruf",
                        style: TextStyle(fontSize: 16),
                      ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
