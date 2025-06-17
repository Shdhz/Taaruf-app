// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
                              Text(
                                '${user.age} tahun',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
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
                    title: "Pertanyaan Taaruf",
                    icon: Icons.quiz,
                    action: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Ajukan"),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                                left: 20,
                                right: 20,
                                top: 20,
                              ),
                              child: _buildFormAjukanPertanyaan(context),
                            );
                          },
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[300],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                    child: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 32),
                  // Q&A Section dengan pembatasan tinggi
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
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.snackbar(
              "Taaruf",
              "Lamaran dikirim ke ${user.name}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.deepPurple,
              colorText: Colors.white,
              borderRadius: 12,
              margin: const EdgeInsets.all(16),
              icon: const Icon(Icons.check_circle_outline),
            );
          },
          backgroundColor: Colors.deepPurple,
          elevation: 8,
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mail_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                "Kirim Lamaran Taaruf",
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
}

Widget _buildFormAjukanPertanyaan(BuildContext context) {
  final TextEditingController questionController = TextEditingController();

  return StatefulBuilder(
    builder: (context, setModalState) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ajukan Pertanyaan",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: questionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tulis pertanyaanmu untuk calon...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    // final questionText = _questionController.text.trim();
                    // if (questionText.isNotEmpty) {
                    //   await UserQuestionService.addUserQuestion(
                    //     userId: user.user_id,
                    //     customText: questionText,
                    //     questionOrder: userQuestions.length + 1,
                    //   );
                    //   Navigator.pop(context); // Tutup modal
                    //   await loadUserQuestions(); // Refresh data
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text("Kirim"),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

void loadUserQuestions() {}
