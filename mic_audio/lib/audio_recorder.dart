import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorder {
  FlutterSoundRecorder? _audioRecorder;
  late String _recordingPath;

  Future<void> startRecording() async {
    _audioRecorder = FlutterSoundRecorder();

    Directory appDocDir = await getApplicationDocumentsDirectory();
    _recordingPath = '${appDocDir.path}/recorded_audio.wav';

    if (!File(_recordingPath).existsSync()) {
      File(_recordingPath).createSync(recursive: true);
    }

    await _audioRecorder!.startRecorder(toFile: _recordingPath);
  }

  Future<String> stopRecording() async {
    await _audioRecorder!.stopRecorder();
    List<int> audioData = await File(_recordingPath).readAsBytes();
    return _recordingPath;
  }
}
