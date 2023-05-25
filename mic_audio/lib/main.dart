import 'dart:io';
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
