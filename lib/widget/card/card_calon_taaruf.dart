// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CardCalonTaaruf {
  final String name;
  final int age;
  final String imageUrl;
  final double distance;
  final bool isVerified;

  const CardCalonTaaruf({
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.distance,
    this.isVerified = false,
  });
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
  static const String cardClickMessage = 'Clicked on';
  static const String loveClickMessage = 'Love icon clicked!';
  static const String imageNotFoundText = 'Image not found';

  // Data dummy - Bisa diganti dengan data dari database
  static const List<CardCalonTaaruf> _dummyUsers = [
    CardCalonTaaruf(
      name: "Tini",
      age: 33,
      imageUrl: "images/cewek_cakep.jpg",
      distance: 1.0,
      isVerified: true,
    ),
    CardCalonTaaruf(
      name: "Sari",
      age: 28,
      imageUrl: "images/cewek_cakep.jpg",
      distance: 2.5,
      isVerified: false,
    ),
    CardCalonTaaruf(
      name: "Maya",
      age: 30,
      imageUrl: "images/cewek_cakep.jpg",
      distance: 0.8,
      isVerified: true,
    ),
    CardCalonTaaruf(
      name: "Dewi",
      age: 25,
      imageUrl: "images/cewek_cakep.jpg",
      distance: 3.2,
      isVerified: false,
    ),
    // Tambah lebih banyak data untuk testing performa
    CardCalonTaaruf(
      name: "Rina",
      age: 29,
      imageUrl: "images/cewek_cakep.jpg",
      distance: 1.8,
      isVerified: true,
    ),
  ];
  // END DATA CONFIGURATION

  late final ScrollController _scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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
      child: GridView.builder(
        controller: _scrollController,
        // Performance optimizations
        cacheExtent: cacheExtent,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),

        // Grid configuration
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),

        // Performance settings
        itemCount: _dummyUsers.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        addSemanticIndexes: false,

        itemBuilder: (context, index) {
          // Lazy loading optimization
          return _UserCard(
            user: _dummyUsers[index],
            key: ValueKey('${_dummyUsers[index].name}_$index'),
            onTap: () => _handleCardTap(_dummyUsers[index]),
            onLoveTap: () => _handleLoveTap(_dummyUsers[index]),
          );
        },
      ),
    );
  }

  void _handleCardTap(CardCalonTaaruf user) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$cardClickMessage ${user.name}'),
        duration: snackBarDuration,
      ),
    );
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
              _buildOptimizedImage(),
              _buildGradientOverlay(),
              _buildContentOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedImage() {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 5.0,
        sigmaY: 5.0,
      ), // Adjust blur intensity
      child: Image.asset(
        user.imageUrl,
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
