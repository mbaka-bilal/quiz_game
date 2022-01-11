import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class Audio {
  static AudioCache player = AudioCache();

  //
  // Initialization.  We pre-load all sounds.
  //
  static Future<dynamic> init() async {
    await player.loadAll([
      'audio/game_start.wav',
      'audio/win.wav',
      'audio/lost.wav',
      'audio/move_down.wav',
      'audio/swap.wav'
          'audio/click_sound.wav'
    ]);
  }

  static playAsset(AudioType audioType) {
    player.play('audio/${describeEnum(audioType)}.wav');
  }
}

enum AudioType {
  // swap,
  // move_down,
  // bomb,
  game_start,
  win,
  lost,
  move_down,
  swap,
  click_sound
}
