import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WebRTC 前置摄像头示例'),
        ),
        body: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  late bool isLoaded = false;

  // 录制
  MediaRecorder? _mediaRecorder;

  @override
  void initState() {
    super.initState();

    initRenderers();
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _localStream?.dispose();
    super.dispose();
  }

  initRenderers() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    await _localRenderer.initialize();
    _getUserMedia();

    setState(() {
      isLoaded = true;
    });
  }

  _getUserMedia() async {
    List<MediaDeviceInfo> cameras =
        await navigator.mediaDevices.enumerateDevices();

    MediaDeviceInfo backCamera =
        cameras.firstWhere((device) => device.label.contains('back'));
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user', // 使用前置摄像头
        // 'facingMode': 'environment', // 使用后置摄像头
      },
      'optional': [
        {'sourceId': backCamera.deviceId} // 使用后置摄像头的ID
      ]
    };

    try {
      MediaStream stream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      setState(() {
        _localStream = stream;
      });
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }
  }

  // 开始录制
  void start() async {
    if (_mediaRecorder != null) return;
    try {
      _mediaRecorder = MediaRecorder();
      final dir = await getExternalStorageDirectory();
      await _mediaRecorder?.start(
        '${dir!.path}/recording.mp4',
        audioChannel: RecorderAudioChannel.INPUT,
        videoTrack: _localStream!.getVideoTracks().first,
      );
    } catch (e) {
      _mediaRecorder?.stop();
      _mediaRecorder = null;
      print('录制异常');
      print(e);
    }
  }

  // 停止录制
  void stop() async {
    try {
      if (_mediaRecorder == null) return;
      await _mediaRecorder?.stop();
      _mediaRecorder = null;
    } catch (e) {
      print('stop error');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black54),
      child: Column(
        children: [
          Expanded(
            child: isLoaded
                ? RTCVideoView(_localRenderer, mirror: true)
                : const Center(child: CircularProgressIndicator()),
          ),
          ElevatedButton(
            onPressed: () {
              // _getUserMedia();
            },
            child: const Text('切换摄像头'),
          ),
          ElevatedButton(
            onPressed: () {
              start();
            },
            child: const Text('开始录制'),
          ),
          ElevatedButton(
            onPressed: () {
              stop();
            },
            child: const Text('结束录制'),
          ),
        ],
      ),
    );
  }
}
