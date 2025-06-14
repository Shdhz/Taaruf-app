import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

// ignore: constant_identifier_names
enum AssetType { profile_photo, gallery, document }

extension AssetTypeExtension on AssetType {
  String get value {
    switch (this) {
      case AssetType.profile_photo:
        return 'profile_photo';
      case AssetType.gallery:
        return 'gallery';
      case AssetType.document:
        return 'document';
    }
  }
}

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadImage({
    required File imageFile,
    required String userId,
    required AssetType assetType,
    bool isPrimary = false,
    int? sortOrder,
    String bucketName = 'user-assets',
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalName = path.basename(imageFile.path);
      final extension = path.extension(originalName);
      final fileName =
          '${timestamp}_${path.basenameWithoutExtension(originalName)}$extension';
      final filePath = '$userId/${assetType.value}/$fileName';

      await _supabase.storage.from(bucketName).upload(filePath, imageFile);
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      final assetData = {
        'user_id': userId,
        'file_url': publicUrl,
        'file_name': fileName,
        'file_type': _getFileType(extension),
        'asset_type': assetType.value,
        'is_primary': isPrimary,
        'sort_order':
            sortOrder ?? await _getNextSortOrder(userId, assetType.value),
      };

      final response =
          await _supabase
              .from('assets')
              .insert(assetData)
              .select('id')
              .single();
      return response['id'] as String;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadAndSetPrimaryImage({
    required File imageFile,
    required String userId,
    required AssetType assetType,
    String bucketName = 'user-assets',
  }) async {
    try {
      // Ambil semua asset lama
      final oldAssets = await _supabase
          .from('assets')
          .select('id, file_url')
          .eq('user_id', userId)
          .eq('asset_type', assetType.value);

      // Hapus semua dari storage dan tabel
      for (final asset in oldAssets) {
        final uri = Uri.parse(asset['file_url']);
        final filePath = uri.pathSegments.skip(3).join('/');
        await _supabase.storage.from(bucketName).remove([filePath]);
        await _supabase.from('assets').delete().eq('id', asset['id']);
      }

      // Upload gambar baru
      return await uploadImage(
        imageFile: imageFile,
        userId: userId,
        assetType: assetType,
        isPrimary: true,
        bucketName: bucketName,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteImage({
    required String assetId,
    String bucketName = 'user-assets',
  }) async {
    try {
      final asset =
          await _supabase
              .from('assets')
              .select('file_url')
              .eq('id', assetId)
              .single();

      final uri = Uri.parse(asset['file_url']);
      final filePath = uri.pathSegments.skip(3).join('/');

      await _supabase.storage.from(bucketName).remove([filePath]);
      await _supabase.from('assets').delete().eq('id', assetId);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserAssets({
    required String userId,
    AssetType? assetType,
    bool primaryOnly = false,
  }) async {
    try {
      final query = _supabase.from('assets').select('*').eq('user_id', userId);

      if (assetType != null) query.eq('asset_type', assetType.value);
      if (primaryOnly) query.eq('is_primary', true);

      final response = await query.order('sort_order', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<String?> getPrimaryImageUrl({
    required String userId,
    required AssetType assetType,
  }) async {
    final assets = await getUserAssets(
      userId: userId,
      assetType: assetType,
      primaryOnly: true,
    );
    return assets.isNotEmpty ? assets.first['file_url'] : null;
  }

  Future<bool> setPrimaryImage({
    required String userId,
    required String assetId,
    required AssetType assetType,
  }) async {
    try {
      await _supabase
          .from('assets')
          .update({'is_primary': false})
          .eq('user_id', userId)
          .eq('asset_type', assetType.value);

      await _supabase
          .from('assets')
          .update({'is_primary': true})
          .eq('id', assetId);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> _getNextSortOrder(String userId, String assetType) async {
    try {
      final response = await _supabase
          .from('assets')
          .select('sort_order')
          .eq('user_id', userId)
          .eq('asset_type', assetType)
          .order('sort_order', ascending: false)
          .limit(1);

      return response.isNotEmpty ? (response.first['sort_order'] ?? 0) + 1 : 0;
    } catch (_) {
      return 0;
    }
  }

  String _getFileType(String extension) {
    final ext = extension.toLowerCase();
    return {
          '.jpg': 'image/jpeg',
          '.jpeg': 'image/jpeg',
          '.png': 'image/png',
          '.gif': 'image/gif',
          '.webp': 'image/webp',
          '.svg': 'image/svg+xml',
          '.pdf': 'application/pdf',
        }[ext] ??
        'application/octet-stream';
  }
}

extension ImageUploadHelper on ImageUploadService {
  Future<String?> uploadProfilePicture({
    required File imageFile,
    required String userId,
    required bool isPrimary,
  }) => uploadAndSetPrimaryImage(
    imageFile: imageFile,
    userId: userId,
    assetType: AssetType.profile_photo,
  );

  Future<String?> uploadGalleryImage({
    required File imageFile,
    required String userId,
    bool isPrimary = false,
  }) => uploadImage(
    imageFile: imageFile,
    userId: userId,
    assetType: AssetType.gallery,
    isPrimary: isPrimary,
  );

  Future<String?> uploadDocument({
    required File file,
    required String userId,
  }) => uploadImage(
    imageFile: file,
    userId: userId,
    assetType: AssetType.document,
  );

  Future<String?> getProfilePictureUrl(String userId) =>
      getPrimaryImageUrl(userId: userId, assetType: AssetType.profile_photo);
}

class ImagePickerHelper {
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService();

  Future<String?> pickAndUploadImage({
    required String userId,
    required AssetType assetType,
    bool isPrimary = false,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return null;

      final imageFile = File(pickedFile.path);

      if (assetType == AssetType.profile_photo && isPrimary) {
        return await _uploadService.uploadAndSetPrimaryImage(
          imageFile: imageFile,
          userId: userId,
          assetType: assetType,
        );
      } else {
        return await _uploadService.uploadImage(
          imageFile: imageFile,
          userId: userId,
          assetType: assetType,
          isPrimary: isPrimary,
        );
      }
    } catch (e) {
      return null;
    }
  }
}
