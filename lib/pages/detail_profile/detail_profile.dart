// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taaruf_app/main.dart';

import '../../services/image_picker_service.dart';
import '../../widget/loading.dart';

class DetailProfile extends StatefulWidget {
  const DetailProfile({super.key});

  @override
  State<DetailProfile> createState() => _DetailProfileState();
}

class _DetailProfileState extends State<DetailProfile> {
  bool isLoading = true;
  Map<String, dynamic>? profileData;
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    Future<bool> requestPermissions(ImageSource source) async {
      if (source == ImageSource.camera) {
        return await Permission.camera.request().isGranted;
      } else {
        if (Platform.isAndroid) {
          final deviceInfo = await DeviceInfoPlugin().androidInfo;
          final sdkInt = deviceInfo.version.sdkInt;

          if (sdkInt >= 33) {
            // Android 13+
            return await Permission.photos.request().isGranted;
          } else {
            // Android 12 ke bawah
            return await Permission.storage.request().isGranted;
          }
        } else {
          // iOS
          return await Permission.photos.request().isGranted;
        }
      }
    }

    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () async {
                    bool granted = await requestPermissions(ImageSource.camera);
                    if (!granted) {
                      Navigator.pop(context);
                      _showPermissionDialog();
                      return;
                    }
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 85,
                    );
                    Navigator.pop(context, image);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () async {
                    bool granted = await requestPermissions(
                      ImageSource.gallery,
                    );
                    if (!granted) {
                      Navigator.pop(context);
                      _showPermissionDialog();
                      return;
                    }
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 85,
                    );
                    Navigator.pop(context, image);
                  },
                ),
              ],
            ),
          ),
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Auto upload setelah pick image
      await _uploadProfilePicture();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Izin Diperlukan'),
            content: const Text(
              'Aplikasi memerlukan izin kamera/galeri untuk mengambil foto. '
              'Silakan berikan izin melalui pengaturan aplikasi.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Pengaturan'),
              ),
            ],
          ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _uploadProfilePicture() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      _showErrorSnackBar('User tidak ditemukan');
      return;
    }

    if (_imageFile == null) {
      _showErrorSnackBar('File gambar tidak ditemukan');
      return;
    }

    LoadingOverlay.show(context, message: 'Mengupload foto profil...');

    try {
      final imageUploadService = ImageUploadService();

      // Ambil semua asset lama
      final oldAssets = await supabase
          .from('assets')
          .select('id, file_url')
          .eq('user_id', userId)
          .eq('asset_type', 'profile_photo');

      // Hapus gambar lama dari storage dan database
      for (final asset in oldAssets) {
        final fileUrl = asset['file_url'] as String;
        final uri = Uri.parse(fileUrl);
        final storagePath = uri.pathSegments.skip(3).join('/');

        await supabase.storage.from('user-assets').remove([storagePath]);
        await supabase.from('assets').delete().eq('id', asset['id']);
      }

      // Upload gambar baru
      final assetId = await imageUploadService.uploadProfilePicture(
        imageFile: _imageFile!,
        userId: userId,
        isPrimary: true,
      );

      if (assetId != null) {
        await fetchProfile();
        setState(() => _imageFile = null);
        _showSuccessSnackBar('Foto profil berhasil diupload!');
      } else {
        _showErrorSnackBar('Gagal mengupload foto profil');
      }
    } catch (_) {
      _showErrorSnackBar('Terjadi kesalahan saat mengupload foto profil.');
    } finally {
      try {
        LoadingOverlay.hide();
      } catch (_) {
        // silently fail; don't log di production
      }
    }
  }

  Future<void> fetchProfile() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response =
          await supabase
              .from('profiles')
              .select('''
          full_name, date_of_birth, gender,
          biodata(height, weight, education_level, occupation_category, occupation_detail, province, city, about_me, marital_status, wali_name, wali_contact, age),
          nasab_profile(tribe, origin_province, origin_city, family_background, father_name, father_occupation, mother_name, mother_occupation, siblings_count, child_position),
          assets(id, file_url, is_primary, asset_type)
        ''')
              .eq('id', userId)
              .maybeSingle();

      final data = response ?? {};
      final assets = data['assets'] as List<dynamic>?;

      final profileAsset = assets?.firstWhere(
        (a) => a['is_primary'] == true && a['asset_type'] == 'profile_photo',
        orElse: () => null,
      );

      if (profileAsset != null && profileAsset['file_url'] != null) {
        final signedUrl = await _getSignedImageUrl(profileAsset['file_url']);
        profileAsset['signed_url'] = signedUrl;
      }

      setState(() {
        profileData = data;
        debugPrint('👉 profileData updated: $profileData');
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Gagal memuat data profil');
    }
  }

  Future<String?> getSignedImageUrlFromPublicUrl(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);

      // Temukan index 'user-assets', lalu ambil path setelah itu
      final index = uri.pathSegments.indexOf('user-assets');
      if (index == -1 || index + 1 >= uri.pathSegments.length) {
        return null; // Invalid path
      }

      final storagePath = uri.pathSegments.sublist(index + 1).join('/');

      final signedUrl = await supabase.storage
          .from('user-assets')
          .createSignedUrl(storagePath, 60 * 60); // 1 jam

      return signedUrl;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getSignedImageUrl(String storagePath) async {
    try {
      final response = await supabase.storage
          .from('user-assets')
          .createSignedUrl(storagePath, 60 * 60);

      return response;
    } catch (_) {
      return null;
    }
  }

  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => EditProfileModal(
            profileData: profileData,
            onProfileUpdated: () {
              fetchProfile(); // Refresh data setelah update
            },
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final biodata = profileData?['biodata'] ?? {};
    final nasab = profileData?['nasab_profile'] ?? {};

    // Get primary profile photo
    final photoUrl =
        (profileData?['assets'] as List?)?.firstWhere(
          (a) => a['is_primary'] == true && a['asset_type'] == 'profile_photo',
          orElse: () => null,
        )?['file_url'];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header dengan gambar full screen
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Get.back(),
              ),
            ),
            actions: [
              // Tombol ganti foto
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.black87),
                  onPressed: _pickImage,
                ),
              ),

              // Tombol edit profil
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black87),
                  onPressed: _showEditProfileModal,
                ),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Container(
                    height: 200, // opsional, sesuaikan kebutuhan
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image:
                          _imageFile != null || photoUrl != null
                              ? DecorationImage(
                                image:
                                    _imageFile != null
                                        ? FileImage(_imageFile!)
                                        : NetworkImage(photoUrl!)
                                            as ImageProvider,
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _imageFile == null && photoUrl == null
                            ? Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap untuk tambah foto',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : null,
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
                  // Profile info overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileData?['full_name'] ?? 'Belum diisi',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Umur : ${biodata?['age']?.toString() ?? '-'}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
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
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Biodata Section
                    _buildModernSection("Biodata Pribadi", Icons.person, [
                      _buildModernInfoCard(
                        "Tinggi & Berat",
                        "${biodata['height'] ?? '-'} cm • ${biodata['weight'] ?? '-'} kg",
                        Icons.height,
                      ),
                      _buildModernInfoCard(
                        "Pendidikan terakhir",
                        biodata['education_level'] ?? 'Belum diisi',
                        Icons.school,
                      ),
                      _buildModernInfoCard(
                        "Jenis Pekerjaan",
                        biodata['occupation_category'] ?? 'Belum diisi',
                        Icons.work,
                      ),
                      _buildModernInfoCard(
                        "detail Pekerjaan",
                        biodata['occupation_detail'] ?? 'Belum diisi',
                        Icons.work_outline,
                      ),
                      _buildModernInfoCard(
                        "Status Pernikahan",
                        biodata['marital_status'] ?? 'Belum diisi',
                        Icons.favorite,
                      ),
                      _buildModernInfoCard(
                        "Provinsi",
                        biodata['province'] ?? 'Belum diisi',
                        Icons.map,
                      ),
                      _buildModernInfoCard(
                        "Kota",
                        biodata['city'] ?? 'Belum diisi',
                        Icons.location_city,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Wali Section - SELALU TAMPIL UNTUK DEBUG
                    _buildModernSection(
                      "Informasi Wali",
                      Icons.supervisor_account,
                      [
                        _buildModernInfoCard(
                          "Nama Wali",
                          biodata['wali_name']?.toString() ?? 'Belum diisi',
                          Icons.person_outline,
                        ),
                        _buildModernInfoCard(
                          "Kontak Wali",
                          biodata['wali_contact']?.toString() ?? 'Belum diisi',
                          Icons.phone,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // About Me Section - SELALU TAMPIL UNTUK DEBUG
                    _buildAboutSection(
                      "Tentang Saya",
                      biodata['about_me']?.toString() ?? 'Belum diisi',
                      Icons.info_outline,
                    ),

                    const SizedBox(height: 24),

                    // Nasab Section
                    _buildModernSection(
                      "Informasi Keluarga & Nasab",
                      Icons.family_restroom,
                      [
                        _buildModernInfoCard(
                          "Suku",
                          nasab['tribe'] ?? 'Belum diisi',
                          Icons.groups,
                        ),
                        _buildModernInfoCard(
                          "Asal Daerah",
                          "${nasab['origin_city'] ?? '-'}, ${nasab['origin_province'] ?? '-'}",
                          Icons.place,
                        ),
                        _buildModernInfoCard(
                          "Posisi Keluarga",
                          "Anak ke-${nasab['child_position'] ?? '-'} dari ${nasab['siblings_count'] ?? '-'} bersaudara",
                          Icons.people,
                        ),
                        // TAMBAHAN UNTUK DEBUG - SELALU TAMPIL
                        _buildModernInfoCard(
                          "Nama Ayah",
                          nasab['father_name']?.toString() ?? 'Belum diisi',
                          Icons.man,
                        ),
                        _buildModernInfoCard(
                          "Pekerjaan Ayah",
                          nasab['father_occupation']?.toString() ??
                              'Belum diisi',
                          Icons.work,
                        ),
                        _buildModernInfoCard(
                          "Nama Ibu",
                          nasab['mother_name']?.toString() ?? 'Belum diisi',
                          Icons.woman,
                        ),
                        _buildModernInfoCard(
                          "Pekerjaan Ibu",
                          nasab['mother_occupation']?.toString() ??
                              'Belum diisi',
                          Icons.work_outline,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Family Background Section - SELALU TAMPIL UNTUK DEBUG
                    _buildAboutSection(
                      "Latar Belakang Keluarga",
                      nasab['family_background']?.toString() ?? 'Belum diisi',
                      Icons.home,
                    ),

                    const SizedBox(height: 24),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF4A90E2), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildModernInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(String title, String content, [IconData? icon]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon ?? Icons.info_outline,
                color: const Color(0xFF4A90E2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// Modal untuk Edit Profile
class EditProfileModal extends StatefulWidget {
  final Map<String, dynamic>? profileData;
  final VoidCallback onProfileUpdated;

  const EditProfileModal({
    super.key,
    required this.profileData,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();

  List<String> _educationLevels = [];
  List<String> _maritalStatuses = [];
  List<String> _occupationCategories = [];
  List<String> _provinces = [];
  List<String> _originProvinces = []; // Separate list for origin provinces
  List<String> _genders = [];
  List<String> _tribes = [];

  String? _selectedEducationLevel;
  String? _selectedMaritalStatus;
  String? _selectedOccupationCategory;
  String? _selectedProvince;
  String? _selectedGender;
  String? _selectedTribe;
  String? _selectedOriginProvince;

  bool _isLoading = false;
  DateTime? _selectedDateOfBirth;

  // Controllers untuk form fields
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final biodata = widget.profileData?['biodata'] ?? {};
    final nasabProfile = widget.profileData?['nasab_profile'] ?? {};

    // Debug print to check data

    _controllers = {
      // Basic Profile
      'fullName': TextEditingController(
        text: widget.profileData?['full_name'] ?? '',
      ),
      'phone': TextEditingController(text: widget.profileData?['phone'] ?? ''),

      // Biodata
      'age': TextEditingController(text: biodata['age']?.toString() ?? ''),
      'height': TextEditingController(
        text: biodata['height']?.toString() ?? '',
      ),
      'weight': TextEditingController(
        text: biodata['weight']?.toString() ?? '',
      ),
      'education': TextEditingController(
        text: biodata['education_level'] ?? '',
      ),
      'occupationCategory': TextEditingController(
        text: biodata['occupation_category'] ?? '',
      ),
      'occupationDetail': TextEditingController(
        text: biodata['occupation_detail'] ?? '',
      ),
      'province': TextEditingController(text: biodata['province'] ?? ''),
      'city': TextEditingController(text: biodata['city'] ?? ''),
      'aboutMe': TextEditingController(text: biodata['about_me'] ?? ''),
      'maritalStatus': TextEditingController(
        text: biodata['marital_status'] ?? '',
      ),
      'waliName': TextEditingController(text: biodata['wali_name'] ?? ''),
      'waliContact': TextEditingController(text: biodata['wali_contact'] ?? ''),

      // Nasab Profile
      'tribe': TextEditingController(text: nasabProfile['tribe'] ?? ''),
      'originProvince': TextEditingController(
        text: nasabProfile['origin_province'] ?? '',
      ),
      'originCity': TextEditingController(
        text: nasabProfile['origin_city'] ?? '',
      ),
      'familyBackground': TextEditingController(
        text: nasabProfile['family_background'] ?? '',
      ),
      'fatherName': TextEditingController(
        text: nasabProfile['father_name'] ?? '',
      ),
      'fatherOccupation': TextEditingController(
        text: nasabProfile['father_occupation'] ?? '',
      ),
      'motherName': TextEditingController(
        text: nasabProfile['mother_name'] ?? '',
      ),
      'motherOccupation': TextEditingController(
        text: nasabProfile['mother_occupation'] ?? '',
      ),
      'siblingsCount': TextEditingController(
        text: nasabProfile['siblings_count']?.toString() ?? '',
      ),
      'childPosition': TextEditingController(
        text: nasabProfile['child_position']?.toString() ?? '',
      ),
    };

    // Set selected values
    _selectedEducationLevel = biodata['education_level'];
    _selectedMaritalStatus = biodata['marital_status'];
    _selectedOccupationCategory = biodata['occupation_category'];
    _selectedProvince = biodata['province'];
    _selectedGender = widget.profileData?['gender'];
    _selectedTribe = nasabProfile['tribe'];
    _selectedOriginProvince = nasabProfile['origin_province'];

    // Debug prints

    // Parse date of birth
    if (widget.profileData?['date_of_birth'] != null) {
      _selectedDateOfBirth = DateTime.parse(
        widget.profileData!['date_of_birth'],
      );
    }

    _fetchEnumValues();
  }

  Future<void> _fetchEnumValues() async {
    try {
      // Create individual RPC calls for each enum
      final educationFuture = supabase.rpc('get_education_level_enum');
      final maritalStatusFuture = supabase.rpc('get_mariage_status_enum');
      final occupationFuture = supabase.rpc('get_occupation_category_enum');
      final provinceFuture = supabase.rpc('get_province_enum');
      final genderFuture = supabase.rpc('get_gender_enum');
      final tribeFuture = supabase.rpc('get_tribe_enum');

      final responses = await Future.wait([
        educationFuture,
        maritalStatusFuture,
        occupationFuture,
        provinceFuture,
        genderFuture,
        tribeFuture,
      ]);

      setState(() {
        _educationLevels = (responses[0] as List<dynamic>).cast<String>();
        _maritalStatuses = (responses[1] as List<dynamic>).cast<String>();
        _occupationCategories = (responses[2] as List<dynamic>).cast<String>();
        _provinces = (responses[3] as List<dynamic>).cast<String>();
        _originProvinces = (responses[3] as List<dynamic>).cast<String>();
        _genders = (responses[4] as List<dynamic>).cast<String>();
        _tribes = (responses[5] as List<dynamic>).cast<String>();
      });
    } catch (e) {
      // Fallback values based on your database enums
      setState(() {
        _educationLevels = [
          'sd',
          'smp',
          'sma',
          'smk',
          'd1',
          'd2',
          'd3',
          's1',
          'd4',
          's2',
          's3',
        ];
        _maritalStatuses = ['single', 'divorced', 'widowed'];
        _occupationCategories = [
          'pns',
          'tni_polri',
          'swasta',
          'wiraswasta',
          'pegawai_bumn',
          'mahasiswa',
          'ibu_rumah_tangga',
          'lainnya',
        ];
        _genders = ['lkhwan', 'akhwat'];
        _tribes = [
          'jawa',
          'sunda',
          'batak',
          'minangkabau',
          'betawi',
          'madura',
          'banjar',
          'bali',
          'sasak',
          'bugis',
          'makassar',
          'toraja',
          'dayak',
          'papua',
          'ambon',
          'flores',
          'aceh',
          'melayu',
          'lampung',
          'palembang',
          'arab',
          'tionghoa',
          'india',
          'lainnya',
        ];
        _provinces = [
          'aceh',
          'sumatera_utara',
          'sumatera_barat',
          'riau',
          'kepulauan_riau',
          'jambi',
          'sumatera_selatan',
          'kepulauan_bangka_belitung',
          'bengkulu',
          'lampung',
          'dki_jakarta',
          'jawa_barat',
          'jawa_tengah',
          'di_yogyakarta',
          'jawa_timur',
          'banten',
          'bali',
          'nusa_tenggara_barat',
          'nusa_tenggara_timur',
          'kalimantan_barat',
          'kalimantan_tengah',
          'kalimantan_selatan',
          'kalimantan_timur',
          'kalimantan_utara',
          'sulawesi_utara',
          'sulawesi_tengah',
          'sulawesi_selatan',
          'sulawesi_tenggara',
          'gorontalo',
          'sulawesi_barat',
          'maluku',
          'maluku_utara',
          'papua',
          'papua_barat',
          'papua_selatan',
          'papua_tengah',
          'papua_pegunungan',
          'papua_barat_daya',
        ];
        _originProvinces = _provinces;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateOfBirth ??
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime.now().subtract(
        const Duration(days: 36500),
      ), // 100 years ago
      lastDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Update profiles table
      await supabase.from('profiles').upsert({
        'id': userId,
        'full_name': _controllers['fullName']!.text,
        'phone':
            _controllers['phone']!.text.isNotEmpty
                ? _controllers['phone']!.text
                : null,
        'date_of_birth': _selectedDateOfBirth?.toIso8601String().split('T')[0],
        'gender': _selectedGender,
        'profile_completed': true,
      });

      // Update biodata table
      await supabase.from('biodata').upsert({
        'user_id': userId,
        'height': int.tryParse(_controllers['height']!.text),
        'weight': int.tryParse(_controllers['weight']!.text),
        'education_level': _selectedEducationLevel,
        'occupation_category': _selectedOccupationCategory,
        'occupation_detail': _controllers['occupationDetail']!.text,
        'province': _selectedProvince,
        'city': _controllers['city']!.text,
        'about_me': _controllers['aboutMe']!.text,
        'marital_status': _selectedMaritalStatus,
        'wali_name': _controllers['waliName']!.text,
        'wali_contact': _controllers['waliContact']!.text,
        'age': int.tryParse(_controllers['age']!.text),
      }, onConflict: 'user_id');

      // Update nasab_profile table
      await supabase.from('nasab_profile').upsert({
        'user_id': userId,
        'tribe': _selectedTribe,
        'origin_province': _selectedOriginProvince,
        'origin_city': _controllers['originCity']!.text,
        'family_background': _controllers['familyBackground']!.text,
        'father_name': _controllers['fatherName']!.text,
        'father_occupation': _controllers['fatherOccupation']!.text,
        'mother_name': _controllers['motherName']!.text,
        'mother_occupation': _controllers['motherOccupation']!.text,
        'siblings_count':
            int.tryParse(_controllers['siblingsCount']!.text) ?? 0,
        'child_position': int.tryParse(_controllers['childPosition']!.text),
      }, onConflict: 'user_id');

      widget.onProfileUpdated();
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Profile berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Dasar
                    _buildSectionTitle('Informasi Dasar'),
                    _buildTextField(
                      'Nama Lengkap *',
                      _controllers['fullName']!,
                      required: true,
                    ),
                    _buildTextField(
                      'Nomor Telepon',
                      _controllers['phone']!,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildDateField(
                      'Tanggal Lahir *',
                      _selectedDateOfBirth,
                      _selectDateOfBirth,
                      required: true,
                    ),
                    _buildDropdown(
                      'Jenis Kelamin *',
                      _genders,
                      _selectedGender,
                      (val) {
                        setState(() => _selectedGender = val);
                      },
                      required: true,
                    ),

                    const SizedBox(height: 24),

                    // Biodata Pribadi
                    _buildSectionTitle('Biodata Pribadi'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Tinggi (cm) *',
                            _controllers['height']!,
                            keyboardType: TextInputType.number,
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'Berat (kg) *',
                            _controllers['weight']!,
                            keyboardType: TextInputType.number,
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      'Umur *',
                      _controllers['age']!,
                      keyboardType: TextInputType.number,
                      required: true,
                    ),

                    _buildDropdown(
                      'Pendidikan *',
                      _educationLevels,
                      _selectedEducationLevel,
                      (val) {
                        setState(() {
                          _selectedEducationLevel = val;
                          _controllers['education']!.text = val!;
                        });
                      },
                      required: true,
                    ),

                    _buildDropdown(
                      'Status Pernikahan *',
                      _maritalStatuses,
                      _selectedMaritalStatus,
                      (val) {
                        setState(() {
                          _selectedMaritalStatus = val;
                          _controllers['maritalStatus']!.text = val!;
                        });
                      },
                      required: true,
                    ),

                    _buildDropdown(
                      'Kategori Pekerjaan *',
                      _occupationCategories,
                      _selectedOccupationCategory,
                      (val) {
                        setState(() {
                          _selectedOccupationCategory = val;
                          _controllers['occupationCategory']!.text = val!;
                        });
                      },
                      required: true,
                    ),

                    _buildTextField(
                      'Detail Pekerjaan *',
                      _controllers['occupationDetail']!,
                      required: true,
                    ),

                    _buildDropdown(
                      'Provinsi *',
                      _provinces,
                      _selectedProvince,
                      (val) {
                        setState(() {
                          _selectedProvince = val;
                          _controllers['province']!.text = val!;
                        });
                      },
                      required: true,
                    ),

                    _buildTextField(
                      'Kota *',
                      _controllers['city']!,
                      required: true,
                    ),
                    _buildTextField(
                      'Tentang Saya *',
                      _controllers['aboutMe']!,
                      maxLines: 4,
                      required: true,
                    ),

                    const SizedBox(height: 24),

                    // Informasi Wali
                    _buildSectionTitle('Informasi Wali'),
                    _buildTextField(
                      'Nama Wali *',
                      _controllers['waliName']!,
                      required: true,
                    ),
                    _buildTextField(
                      'Kontak Wali *',
                      _controllers['waliContact']!,
                      keyboardType: TextInputType.phone,
                      required: true,
                    ),

                    const SizedBox(height: 24),

                    // Nasab Profile
                    _buildSectionTitle('Profil Nasab'),
                    _buildDropdown('Suku *', _tribes, _selectedTribe, (val) {
                      setState(() {
                        _selectedTribe = val;
                        _controllers['tribe']!.text = val!;
                      });
                    }, required: true),

                    _buildDropdown(
                      'Provinsi Asal *',
                      _originProvinces,
                      _selectedOriginProvince,
                      (val) {
                        setState(() {
                          _selectedOriginProvince = val;
                          _controllers['originProvince']!.text = val ?? '';
                        });
                      },
                      required: true,
                    ),

                    _buildTextField(
                      'Kota Asal *',
                      _controllers['originCity']!,
                      required: true,
                    ),
                    _buildTextField(
                      'Latar Belakang Keluarga',
                      _controllers['familyBackground']!,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Informasi Orang Tua
                    _buildSectionTitle('Informasi Orang Tua'),
                    _buildTextField(
                      'Nama Ayah *',
                      _controllers['fatherName']!,
                      required: true,
                    ),
                    _buildTextField(
                      'Pekerjaan Ayah *',
                      _controllers['fatherOccupation']!,
                      required: true,
                    ),
                    _buildTextField(
                      'Nama Ibu *',
                      _controllers['motherName']!,
                      required: true,
                    ),
                    _buildTextField(
                      'Pekerjaan Ibu *',
                      _controllers['motherOccupation']!,
                      required: true,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Jumlah Saudara *',
                            _controllers['siblingsCount']!,
                            keyboardType: TextInputType.number,
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'Anak Ke- *',
                            _controllers['childPosition']!,
                            keyboardType: TextInputType.number,
                            required: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
          ),
          const Expanded(
            child: Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A90E2),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(label),
        validator:
            required
                ? (value) =>
                    (value == null || value.isEmpty)
                        ? '${label.replaceAll(' *', '')} tidak boleh kosong'
                        : null
                : null,
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    VoidCallback onTap, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: _inputDecoration(label),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : 'Pilih tanggal lahir',
                style: TextStyle(
                  color: selectedDate != null ? Colors.black : Colors.grey[600],
                ),
              ),
              const Icon(Icons.calendar_today, color: Color(0xFF4A90E2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged, {
    bool required = false,
  }) {
    // Debug print

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value:
            items.contains(selectedValue)
                ? selectedValue
                : null, // Only set if value exists in items
        decoration: _inputDecoration(label),
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
        validator:
            required
                ? (value) =>
                    (value == null || value.isEmpty)
                        ? '${label.replaceAll(' *', '')} tidak boleh kosong'
                        : null
                : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A90E2)),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
