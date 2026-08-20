import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal();

  bool isSoundEnabled = true;
  bool isMusicEnabled = true;

  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Cached PCM WAV Byte Arrays
  Uint8List? _attackWav;
  Uint8List? _heavyWav;
  Uint8List? _hitWav;
  Uint8List? _critWav;
  Uint8List? _specialWav;
  Uint8List? _ultimateWav;
  Uint8List? _chestWav;
  Uint8List? _coinWav;
  Uint8List? _gemWav;
  Uint8List? _levelUpWav;
  Uint8List? _puzzleWav;
  Uint8List? _bossAttackWav;
  Uint8List? _victoryWav;
  Uint8List? _gameOverWav;
  Uint8List? _buttonWav;

  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    // Synthesize pristine retro/arcade SFX waveforms in-memory
    _attackWav = _generateToneWav(frequency: 440, durationMs: 90, endFrequency: 220);
    _heavyWav = _generateToneWav(frequency: 220, durationMs: 200, endFrequency: 110, isNoise: true);
    _hitWav = _generateToneWav(frequency: 180, durationMs: 70, endFrequency: 90);
    _critWav = _generateToneWav(frequency: 880, durationMs: 150, endFrequency: 440);
    _specialWav = _generateToneWav(frequency: 520, durationMs: 250, endFrequency: 880);
    _ultimateWav = _generateToneWav(frequency: 330, durationMs: 500, endFrequency: 1100);
    _chestWav = _generateToneWav(frequency: 600, durationMs: 300, endFrequency: 900);
    _coinWav = _generateToneWav(frequency: 987, durationMs: 80, endFrequency: 1318);
    _gemWav = _generateToneWav(frequency: 1046, durationMs: 120, endFrequency: 1567);
    _levelUpWav = _generateToneWav(frequency: 523, durationMs: 400, endFrequency: 1046);
    _puzzleWav = _generateToneWav(frequency: 659, durationMs: 200, endFrequency: 880);
    _bossAttackWav = _generateToneWav(frequency: 130, durationMs: 350, endFrequency: 65, isNoise: true);
    _victoryWav = _generateToneWav(frequency: 587, durationMs: 600, endFrequency: 1174);
    _gameOverWav = _generateToneWav(frequency: 330, durationMs: 500, endFrequency: 110);
    _buttonWav = _generateToneWav(frequency: 700, durationMs: 50, endFrequency: 850);
  }

  void toggleSound() => isSoundEnabled = !isSoundEnabled;
  void toggleMusic() => isMusicEnabled = !isMusicEnabled;

  void playAttack() => _playBytes(_attackWav);
  void playHeavyAttack() => _playBytes(_heavyWav);
  void playHit() => _playBytes(_hitWav);
  void playCritical() => _playBytes(_critWav);
  void playSpecial() => _playBytes(_specialWav);
  void playUltimate() => _playBytes(_ultimateWav);
  void playChest() => _playBytes(_chestWav);
  void playCoin() => _playBytes(_coinWav);
  void playGem() => _playBytes(_gemWav);
  void playLevelUp() => _playBytes(_levelUpWav);
  void playPuzzleSuccess() => _playBytes(_puzzleWav);
  void playBossAttack() => _playBytes(_bossAttackWav);
  void playVictory() => _playBytes(_victoryWav);
  void playGameOver() => _playBytes(_gameOverWav);
  void playButtonClick() => _playBytes(_buttonWav);

  Future<void> _playBytes(Uint8List? bytes) async {
    if (!isSoundEnabled || bytes == null) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(BytesSource(bytes));
    } catch (_) {}
  }

  // -------------------------------------------------------------
  // Pure Dart PCM 16-bit Mono WAV Generator (Zero External Assets)
  // -------------------------------------------------------------
  Uint8List _generateToneWav({
    required double frequency,
    required int durationMs,
    double? endFrequency,
    bool isNoise = false,
  }) {
    const int sampleRate = 22050;
    final int numSamples = (sampleRate * (durationMs / 1000.0)).round();
    final int dataSize = numSamples * 2; // 16-bit mono = 2 bytes per sample
    final int fileSize = 44 + dataSize;

    final ByteData byteData = ByteData(fileSize);

    // RIFF header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, fileSize - 8, Endian.little);

    // WAVE format
    byteData.setUint8(8, 0x57); // 'W'
    byteData.setUint8(9, 0x41); // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    byteData.setUint16(22, 1, Endian.little); // NumChannels (1 = Mono)
    byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
    byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    byteData.setUint16(32, 2, Endian.little); // BlockAlign
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample

    // data subchunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, dataSize, Endian.little);

    // Generate Audio Samples
    final Random rng = Random();
    final double targetEndFreq = endFrequency ?? frequency;

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double progress = i / numSamples;
      final double currentFreq = frequency + (targetEndFreq - frequency) * progress;

      // Envelope: smooth attack & decay
      final double envelope = (1.0 - progress) * min(1.0, progress * 10);

      double sampleVal;
      if (isNoise) {
        sampleVal = (rng.nextDouble() * 2.0 - 1.0) * envelope;
      } else {
        sampleVal = sin(2 * pi * currentFreq * t) * envelope;
      }

      final int sample16 = (sampleVal * 32767).clamp(-32768, 32767).toInt();
      byteData.setInt16(44 + i * 2, sample16, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }
}
