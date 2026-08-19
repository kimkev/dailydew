import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  Future<bool> _areSoundsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('soundsEnabled') ?? true;
  }

  Future<void> _play(String assetPath) async {
    if (!await _areSoundsEnabled()) return;

    final player = AudioPlayer();

    await player.play(AssetSource(assetPath));

    player.onPlayerComplete.listen((_) {
      player.dispose();
    });
  }

  Future<void> playWater() => _play('sounds/water_drop.wav');

  Future<void> playWaterAll() => _play('sounds/water_all.wav');

  Future<void> playPlantAdded() => _play('sounds/plant_added.wav');

  Future<void> playGrowth() => _play('sounds/growth_chime.wav');

  Future<void> playGardenChirp() => _play('sounds/garden_bird_chirp.wav');
}