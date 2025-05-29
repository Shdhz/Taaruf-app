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

class CalonTaarufWidget extends StatelessWidget {
  // Data dummy
  static const List<CardCalonTaaruf> _dummyUsers = [
    CardCalonTaaruf(
      name: "Tini",
      age: 33,
      imageUrl: "images/cewek_cakep.jpg",
      distance: 1,
      isVerified: true,
    ),
  ];

  const CalonTaarufWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          // Tambahkan physics untuk performa yang lebih baik
          cacheExtent: 1000,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          // Tambahkan itemCount yang jelas
          itemCount: _dummyUsers.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: _UserCard(
                user: _dummyUsers[index],
                key: ValueKey(_dummyUsers[index].name),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final CardCalonTaaruf user;

  const _UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clicked on ${user.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Hero(
        tag:
            'user_${user.name}', // Untuk animasi smooth jika navigasi ke detail
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.deepPurple,
              width: 2,
            ), // Kurangi border width
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08), // Kurangi opacity shadow
                blurRadius: 6, // Kurangi blur radius
                offset: const Offset(0, 2), // Kurangi offset
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand, // Tambahkan untuk optimasi
              children: [
                // Optimized image loading
                _buildImageWidget(),
                // Content
                _buildGradientOverlay(),
                _buildContentOverlay(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return Image.asset(
      user.imageUrl,
      fit: BoxFit.cover,
      gaplessPlayback: true, // Smooth transition
      // Error builder yang lebih baik
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Image not found',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.6), // Kurangi opacity
          ],
          stops: const [0.6, 1.0], // Tambahkan stops untuk optimasi
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name and age with verification
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${user.name}, ${user.age}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15, // Sedikit kurangi font size
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (user.isVerified) ...[
                  const SizedBox(width: 3),
                  const Icon(Icons.verified_user, color: Colors.blue, size: 24),
                ],
              ],
            ),
            const SizedBox(height: 4),
            // Distance and action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${user.distance.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Love icon clicked!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
