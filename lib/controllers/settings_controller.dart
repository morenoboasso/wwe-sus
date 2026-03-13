import 'package:get_storage/get_storage.dart';

class SettingsController {
  static const String _startupSoundKey = 'startupSoundEnabled';

  final GetStorage _box;

  SettingsController({GetStorage? box}) : _box = box ?? GetStorage();

  bool get startupSoundEnabled {
    final value = _box.read(_startupSoundKey);
    if (value is bool) return value;
    return true;
  }

  Future<void> setStartupSoundEnabled(bool enabled) async {
    await _box.write(_startupSoundKey, enabled);
  }
}
