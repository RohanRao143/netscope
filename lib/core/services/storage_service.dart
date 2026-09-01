// lib/core/services/storage_service.dart

class StorageService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
  }
}