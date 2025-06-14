import 'package:taaruf_app/main.dart';

class UserProfileService {
  static Future<String?> fetchProfileImageUrl() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      final userId = user.id;

      try {
        final response = await supabase
            .from('assets')
            .select('file_url')
            .eq('user_id', userId)
            .eq('asset_type', 'profile_photo')
            .limit(1)
            .maybeSingle();

        if (response != null && response['file_url'] != null) {
          final fileUrl = response['file_url'] as String;
          if (fileUrl.isNotEmpty && fileUrl.startsWith('http')) {
            return fileUrl;
          }
        }
      } catch (e) {
        // 
      }
    }

    return null;
  }
}
