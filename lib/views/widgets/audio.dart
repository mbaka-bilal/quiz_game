import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class Audio {
  static AudioCache player = AudioCache();

  // Initialization.  We pre-load all sounds.

  static Future<dynamic> init() async {
    await player.loadAll([
      'audio/game_start.wav',
      'audio/win.wav',
      'audio/lost.wav',
      'audio/move_down.wav',
      'audio/swap.wav',
      'audio/click_sound.wav',
      'audio/the_cutest_bunny.wav'
    ]);
  }

  static playAsset(AudioType audioType) async {
    if (audioType == AudioType.the_cutest_bunny) {
      return await player.loop('audio/${describeEnum(audioType)}.wav');
      // player.onAudioPositionChanged
    } else {
      return await player.play('audio/${describeEnum(audioType)}.wav');
    }
  }

  static stopAsset(AudioPlayer audio) async {
    //'audio/${describeEnum(audioType)}.wav'
    await player.clearAll();
    await audio.stop();
  }
}

enum AudioType {
  game_start,
  win,
  lost,
  move_down,
  swap,
  click_sound,
  the_cutest_bunny,
}
