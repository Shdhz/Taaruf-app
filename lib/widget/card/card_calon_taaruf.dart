// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taaruf_app/main.dart';
import 'package:taaruf_app/routes/app_routes.dart';

class CardCalonTaaruf {
  final String name;
  final int age;
  final String imageUrl;
  final double distance;
  final bool isVerified;
  final Map<String, dynamic> biodata;
  final Map<String, dynamic> nasab;
  final List<Map<String, dynamic>> userQuestions;

  const CardCalonTaaruf({
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.distance,
    required this.isVerified,
    required this.biodata,
    required this.nasab,
    required this.userQuestions,
  });

  factory CardCalonTaaruf.fromMap(
    Map<String, dynamic> profile,
    Map<String, dynamic> biodata,
    Map<String, dynamic> nasab,
    List<Map<String, dynamic>> userQuestions,
    String imageUrl,
  ) {
    return CardCalonTaaruf(
      name: profile['full_name'] ?? 'Tanpa Nama',
      age: biodata['age'] ?? 0,
      imageUrl: imageUrl,
      distance: 0.0,
      isVerified: profile['profile_completed'] ?? false,
      biodata: biodata,
      nasab: nasab,
      userQuestions: userQuestions,
    );
  }
}

class CalonTaarufWidget extends StatefulWidget {
  const CalonTaarufWidget({super.key});

  @override
  State<CalonTaarufWidget> createState() => _CalonTaarufWidgetState();
}

class _CalonTaarufWidgetState extends State<CalonTaarufWidget>
    with AutomaticKeepAliveClientMixin {
  // DATA CONFIGURATION - Ubah data di sini
  static const int crossAxisCount = 2;
  static const double crossAxisSpacing = 12.0;
  static const double mainAxisSpacing = 12.0;
  static const double childAspectRatio = 0.75;
  static const double cacheExtent = 2000.0;
  static const EdgeInsets containerPadding = EdgeInsets.all(16.0);
  static const Duration snackBarDuration = Duration(seconds: 1);
  static const String loveClickMessage = 'Love icon clicked!';
  static const String imageNotFoundText = 'Image not found';

  List<CardCalonTaaruf> _users = [];
  bool _isLoading = true;

  late final ScrollController _scrollController;

  // Bug relasi foto pada user tidak bisa ditampilkan
  Future<void> _fetchUsers() async {
    final client = supabase;
    final currentUser = client.auth.currentUser;

    if (currentUser == null) return;

    try {
      // Ambil gender dari user yang sedang login
      final profileRes =
          await client
              .from('profiles')
              .select('gender')
              .eq('id', currentUser.id)
              .single();

      final myGender = profileRes['gender'];
      final targetGender = myGender == 'Ikhwan' ? 'Akhwat' : 'Ikhwan';

      // Ambil semua profile dari target gender yang aktif
      final profilesResult = await client
          .from('profiles')
          .select(
            'id, full_name, profile_completed, biodata(*), nasab_profile(tribe, origin_province, origin_city, father_name, mother_name, siblings_count, child_position),  user_questions(custom_question_text, question_order)',
          )
          .eq('gender', targetGender)
          .eq('is_active', true);

      // Ambil list ID dari profile
      final profileIds =
          profilesResult
              .map((p) => p['id'].toString().trim())
              .where((id) => id.isNotEmpty)
              .toList();

      debugPrint('[INFO] Jumlah profile ditemukan: ${profileIds.length}');
      debugPrint('[INFO] Profile IDs: $profileIds');

      // Ambil semua assets yang terkait dengan profileIds
      final assetResponse = await client
          .from('assets')
          .select('user_id, asset_type, file_url')
          .inFilter('user_id', profileIds);

      debugPrint('[INFO] Asset total: ${assetResponse.length}');

      // Filter hanya asset dengan tipe "profile_photo"
      final filteredAssets =
          assetResponse
              .where((a) => a['asset_type'].toString() == 'profile_photo')
              .toList();

      // Buat mapping user_id -> file_url
      final Map<String, String> assetMap = {};
      for (final row in filteredAssets) {
        final uid = row['user_id'].toString().trim();
        final url = row['file_url'].toString().trim();
        assetMap[uid] = url;
      }

      // Debug jika ada profile yang tidak punya foto
      for (final id in profileIds) {
        if (!assetMap.containsKey(id)) {
          debugPrint('[WARNING] No asset found for profile id: $id');
        }
      }

      // Siapkan list user
      final List<CardCalonTaaruf> fetchedUsers = [];

      for (final profileMap in profilesResult) {
        final id = profileMap['id'].toString().trim();
        final rawUrl = assetMap[id] ?? '';
        final fullName = profileMap['full_name'] ?? 'Tanpa Nama';
        final isVerified = profileMap['profile_completed'] ?? false;
        final biodata = Map<String, dynamic>.from(profileMap['biodata'] ?? {});
        final nasab = Map<String, dynamic>.from(
          profileMap['nasab_profile'] ?? {},
        );
        final questions = List<Map<String, dynamic>>.from(
          profileMap['user_questions'] ?? [],
        );

        final age = biodata['age'] ?? 0;

        // Susun full URL jika file_url tidak diawali http
        final imageUrl =
            rawUrl.isNotEmpty
                ? (rawUrl.startsWith('http')
                    ? rawUrl
                    : 'https://uhergrjlsgpanrqlupvx.supabase.co$rawUrl')
                : '';

        fetchedUsers.add(
          CardCalonTaaruf(
            name: fullName,
            age: age,
            imageUrl: imageUrl,
            distance: 0.0,
            isVerified: isVerified,
            biodata: biodata,
            nasab: nasab,
            userQuestions: questions,
          ),
        );
      }

      // Set state
      if (mounted) {
        setState(() {
          _users = fetchedUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Padding(
      padding: containerPadding,
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                controller: _scrollController,
                cacheExtent: cacheExtent,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  return _UserCard(
                    user: _users[index],
                    key: ValueKey('${_users[index].name}_$index'),
                    onTap: () => _handleCardTap(_users[index]),
                    onLoveTap: () => _handleLoveTap(_users[index]),
                  );
                },
              ),
    );
  }

  void _handleCardTap(CardCalonTaaruf user) {
    HapticFeedback.lightImpact();

    // Navigasi ke halaman detail lewat named route
    Get.toNamed(AppRoutes.detailProfileCalon, arguments: user);
  }

  void _handleLoveTap(CardCalonTaaruf user) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$loveClickMessage ${user.name}'),
        duration: snackBarDuration,
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final CardCalonTaaruf user;
  final VoidCallback onTap;
  final VoidCallback onLoveTap;

  // Style configuration
  static const double borderRadius = 20.0;
  static const double borderWidth = 2.0;
  static const double shadowBlurRadius = 6.0;
  static const double shadowOpacity = 0.08;
  static const Offset shadowOffset = Offset(0, 2);
  static const double contentPadding = 12.0;
  static const double iconSize = 18.0;
  static const double loveIconSize = 20.0;
  static const double verifiedIconSize = 20.0;
  static const double fontSize = 15.0;
  static const double distanceFontSize = 11.0;

  const _UserCard({
    super.key,
    required this.user,
    required this.onTap,
    required this.onLoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.deepPurple, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(shadowOpacity),
              blurRadius: shadowBlurRadius,
              offset: shadowOffset,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildOptimizedImage(user.imageUrl),
              _buildGradientOverlay(),
              _buildContentOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedImage(String imageUrl) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        // Memory optimization
        cacheWidth: 400, // Limit cache size
        // Error handling
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
        // Loading optimization
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                frame != null
                    ? child
                    : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            _CalonTaarufWidgetState.imageNotFoundText,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
          stops: const [0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildContentOverlay(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNameAndAge(),
            const SizedBox(height: 4),
            _buildDistanceAndAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAndAge() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${user.name}, ${user.age}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (user.isVerified) ...[
          const SizedBox(width: 4),
          Icon(Icons.verified_user, color: Colors.blue, size: verifiedIconSize),
        ],
      ],
    );
  }

  Widget _buildDistanceAndAction(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildDistanceInfo(), _buildLoveButton(context)],
    );
  }

  Widget _buildDistanceInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: Colors.white70, size: iconSize),
        const SizedBox(width: 2),
        Text(
          '${user.distance.toStringAsFixed(1)} km',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: distanceFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildLoveButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onLoveTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.favorite, color: Colors.white, size: loveIconSize),
        ),
      ),
    );
  }
}
