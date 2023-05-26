import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(AudioRecorderApp());
}

class AudioRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AudioRecorder(),
    );
  }
}

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
  }

  Future<void> _initAudioRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
  }

  Future<void> _startRecording() async {
    try {
      PermissionStatus status = await Permission.microphone.request();
      if (status.isGranted) {
        // Permission granted, start recording
        if (_audioRecorder!.isStopped) {
          String tempDir = (await getTemporaryDirectory()).path;
          String filePath = '$tempDir/audio.m4a';

          await _initAudioRecorder(); // Initialize the audio recorder

          await _audioRecorder!.startRecorder(
            toFile: filePath,
            codec: Codec.aacMP4,
          );

          setState(() {
            _isRecording = true;
            _audioFilePath = filePath;
          });
        }
      } else {
        // Permission denied
        if (status.isPermanentlyDenied) {
          // Open app settings to enable the permission manually
          openAppSettings();
        } else {
          print('Microphone permission denied');
        }
      }
    } catch (e) {
      print('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_audioRecorder!.isRecording) {
        await _audioRecorder!.stopRecorder();
        setState(() {
          _isRecording = false;
        });
      }
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  Future<void> _saveAndSendRecording() async {
    if (_audioFilePath == null) {
      print('No recording available to save and send.');
      return;
    }

    File audioFile = File(_audioFilePath!);
    if (!audioFile.existsSync()) {
      print('Recording file does not exist.');
      return;
    }

    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        // Save the audio file to a desired location
        // For example, you can copy it to app-specific directory:
        Directory appDir = await getApplicationDocumentsDirectory();
        String savedFilePath = '${appDir.path}/audio_recording.m4a';
        await audioFile.copy(savedFilePath);

        // Send the audio file via HTTP POST request
        var request = http.MultipartRequest('POST',
            Uri.parse('http://localhost/mic_audio/mic_audio/recordings/'));
        request.files
            .add(await http.MultipartFile.fromPath('audio', savedFilePath));

        var response = await request.send();
        if (response.statusCode == 200) {
          print('Audio sent successfully');
        } else {
          print('Failed to send audio. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Failed to save and send recording: $e');
      }
    } else {
      // Permission denied
      if (status.isPermanentlyDenied) {
        // Open app settings to enable the permission manually
        openAppSettings();
      } else {
        print('Storage permission denied');
      }
    }
  }

  @override
  void dispose() {
    _audioRecorder?.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: Text('Stop Recording'),
            ),
            ElevatedButton(
              onPressed: _saveAndSendRecording,
              child: Text('Save and Send Recording'),
            ),
          ],
        ),
      ),
    );
  }
}

/*import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(AudioRecorderApp());
}

class AudioRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AudioRecorder(),
    );
  }
}

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
  }

  Future<void> _initAudioRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    // Initialize the recorder without opening an audio session
    await _audioRecorder!.openRecorder(); //openAudioSession()
  }

  Future<void> _startRecording() async {
    try {
      PermissionStatus status = await Permission.microphone.request();
      if (status.isGranted) {
        // Permission granted, start recording
        if (_audioRecorder!.isStopped) {
          String tempDir = (await getTemporaryDirectory()).path;
          String filePath = '$tempDir/audio.m4a';

          await _audioRecorder!.startRecorder(
            toFile: filePath,
            codec: Codec.aacMP4,
          );

          setState(() {
            _isRecording = true;
            _audioFilePath = filePath;
          });
        }
      } else {
        // Permission denied
        if (status.isPermanentlyDenied) {
          // Open app settings to enable the permission manually
          openAppSettings();
        } else {
          print('Microphone permission denied');
        }
      }
    } catch (e) {
      print('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_audioRecorder!.isRecording) {
        await _audioRecorder!.stopRecorder();
        setState(() {
          _isRecording = false;
        });
      }
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  Future<void> _saveAndSendRecording() async {
    if (_audioFilePath == null) {
      print('No recording available to save and send.');
      return;
    }

    File audioFile = File(_audioFilePath!);
    if (!audioFile.existsSync()) {
      print('Recording file does not exist.');
      return;
    }

    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        // Save the audio file to a desired location
        // For example, you can copy it to app-specific directory:
        Directory appDir = await getApplicationDocumentsDirectory();
        String savedFilePath = '${appDir.path}/audio_recording.m4a';
        await audioFile.copy(savedFilePath);

        // Send the audio file via HTTP POST request
        var request = http.MultipartRequest(
            'POST', Uri.parse('http://192.168.29.98/5000'));
        request.files
            .add(await http.MultipartFile.fromPath('audio', savedFilePath));

        var response = await request.send();
        if (response.statusCode == 200) {
          print('Audio sent successfully');
        } else {
          print('Failed to send audio. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Failed to save and send recording: $e');
      }
    } else {
      // Permission denied
      if (status.isPermanentlyDenied) {
        // Open app settings to enable the permission manually
        openAppSettings();
      } else {
        print('Storage permission denied');
      }
    }
  }

  @override
  void dispose() {
    //_audioRecorder?.closeRecorder(); //closeAudioSession()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: Text('Stop Recording'),
            ),
            ElevatedButton(
              onPressed: _saveAndSendRecording,
              child: Text('Save and Send Recording'),
            ),
          ],
        ),
      ),
    );
  }
}*/

/*import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(AudioRecorderApp());
}

class AudioRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AudioRecorder(),
    );
  }
}

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
  }

  Future<void> _initAudioRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.startRecorder();
  }

  Future<void> _startRecording() async {
    try {
      PermissionStatus status = await Permission.microphone.request();
      if (status.isGranted) {
        // Permission granted, start recording
        if (_audioRecorder!.isStopped) {
          String tempDir = (await getTemporaryDirectory()).path;
          String filePath = '$tempDir/audio.m4a';

          await _audioRecorder!.startRecorder(
            toFile: filePath,
            codec: Codec.aacMP4,
          );

          setState(() {
            _isRecording = true;
            _audioFilePath = filePath;
          });
        }
      } else {
        // Permission denied
        if (status.isPermanentlyDenied) {
          // Open app settings to enable the permission manually
          openAppSettings();
        } else {
          print('Microphone permission denied');
        }
      }
    } catch (e) {
      print('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_audioRecorder!.isRecording) {
        await _audioRecorder!.stopRecorder();
        setState(() {
          _isRecording = false;
        });
      }
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  Future<void> _saveAndSendRecording() async {
    if (_audioFilePath == null) {
      print('No recording available to save and send.');
      return;
    }

    File audioFile = File(_audioFilePath!);
    if (!audioFile.existsSync()) {
      print('Recording file does not exist.');
      return;
    }

    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        // Save the audio file to a desired location
        // For example, you can copy it to app-specific directory:
        Directory appDir = await getApplicationDocumentsDirectory();
        String savedFilePath = '${appDir.path}/audio_recording.m4a';
        await audioFile.copy(savedFilePath);

        // Send the audio file via HTTP POST request
        var request =
            http.MultipartRequest('POST', Uri.parse('http://192.168.1.5/5000'));
        request.files
            .add(await http.MultipartFile.fromPath('audio', savedFilePath));

        var response = await request.send();
        if (response.statusCode == 200) {
          print('Audio sent successfully');
        } else {
          print('Failed to send audio. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Failed to save and send recording: $e');
      }
    } else {
      // Permission denied
      if (status.isPermanentlyDenied) {
        // Open app settings to enable the permission manually
        openAppSettings();
      } else {
        print('Storage permission denied');
      }
    }
  }

  @override
  void dispose() {
    _audioRecorder?.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: Text('Stop Recording'),
            ),
            ElevatedButton(
              onPressed: _saveAndSendRecording,
              child: Text('Save and Send Recording'),
            ),
          ],
        ),
      ),
    );
  }
}*/

/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Audio Recorder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterSoundPlayer? _audioPlayer;
  FlutterSoundRecorder? _audioRecorder;
  late String _recordingPath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = FlutterSoundPlayer();
    _audioRecorder = FlutterSoundRecorder();
  }

  void _startRecording() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    _recordingPath =
        '${appDocDir.path}/recorded_audio.wav'; // Replace with the actual path where you want to save the audio file

    await _audioRecorder!.startRecorder(toFile: _recordingPath);
  }

  void _stopRecording() async {
    await _audioRecorder!.stopRecorder();
    List<int> audioData = await File(_recordingPath).readAsBytes();

    // Send audio data to the server
    await uploadAudio(audioData);
  }

  Future<void> uploadAudio(List<int> audioData) async {
    var url = 'http://127.0.0.1:5500/mic_audio/';
    var response = await http.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'audio/wav',
      },
      body: audioData,
    );

    if (response.statusCode == 200) {
      // Audio uploaded successfully
      print('Audio uploaded successfully');
    } else {
      // Error uploading audio
      print('Error uploading audio');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text('Stop Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
*/