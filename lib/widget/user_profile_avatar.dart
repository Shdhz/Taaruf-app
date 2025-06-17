import 'package:flutter/material.dart';
import 'package:taaruf_app/services/user_profile_service.dart';

class UserProfileAvatar extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;

  const UserProfileAvatar({super.key, this.size = 70, this.onTap});

  @override
  State<UserProfileAvatar> createState() => _UserProfileAvatarState();
}

class _UserProfileAvatarState extends State<UserProfileAvatar> {
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final url = await UserProfileService.fetchProfileImageUrl();

    if (!mounted) return; // Tambahkan ini

    setState(() {
      imageUrl = url;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        (imageUrl != null)
            ? NetworkImage(imageUrl!)
            : const AssetImage('images/default_picture.jpg') as ImageProvider;

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipOval(
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
          child:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : null,
        ),
      ),
    );
  }
}
