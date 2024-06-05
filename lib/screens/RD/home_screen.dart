import 'dart:io';
import 'dart:isolate';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 相机控制器
  CameraController? _cameraController;
  // 相机初始化锚点
  Future<void>? _initializeControllerFuture;
  // 滚动录制计时器
  Timer? _timer;
  // 是否在录制中
  bool _isRecording = false;
  // 是否触发监测信号
  final bool _signal = false;
  // 录制前是否完成准备
  bool _isPrepared = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _startTimer();
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  //
  void _startTimer() {
    _startRecording();
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      print('Timer stop!');
      _stopRecording();

      if (_signal == true) {
        // 有监测信号，中断计时器
        _timer?.cancel();
      } else {
        // 没有监测信号，停止录制
        _stopRecording();
      }
    });
  }

  // 模拟接收监测信号
  void _receiveSignal() {
    print('Receive signal!');
    // _timer?.cancel();
    // _stopRecording();
  }

  // 锁定或释放相机曝光和聚焦(实际业务中，由启动和关闭录制按钮切换模型)（不同机型表现不一样，红米手机可以）
  Future<void> prepareForRecording() async {
    if (_isPrepared == false) {
      if (_cameraController!.value.focusMode != FocusMode.locked) {
        await _cameraController!.setFocusMode(FocusMode.locked);
      }
      if (_cameraController!.value.exposureMode != ExposureMode.locked) {
        await _cameraController!.setExposureMode(ExposureMode.locked);
      }
      setState(() {
        _isPrepared = true;
      });
    } else {
      // await _cameraController!.setFocusMode(FocusMode.auto);
      // await _cameraController!.setExposureMode(ExposureMode.auto);
      // setState(() {
      //   _isPrepared = false;
      // });
    }
  }

  // 开始录制
  Future<void> _startRecording() async {
    if (_isRecording) return;
    await _cameraController!.setFocusMode(FocusMode.locked);
    await _cameraController!.setExposureMode(ExposureMode.locked);
    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print(e);
    }

    _cameraController!.startImageStream((image) => {});
  }

  // 结束录制
  Future<void> _stopRecording() async {
    try {
      final video = await _cameraController!.stopVideoRecording();
      final path = video.path;
      startSavingVideo(path);
      setState(() {
        _isRecording = false;
      });
      _startRecording();
    } catch (e) {
      print(e);
    }
  }

  //
  void saveVideo(String videoPath) async {
    // final directory = await getTemporaryDirectory(); // 获取缓存目录
    // final directory = await getExternalStorageDirectory(); // 获取缓存目录
    // final cacheDirectoryPath = directory?.path;
    // final fileName = videoPath.split('/').last; // 从原始路径中获取文件名
    // final newPath = '$cacheDirectoryPath/$fileName';
    // await File(videoPath).copy(newPath);

    GallerySaver.saveVideo(videoPath).then((path) {
      setState(() {
        print('video saved!');
      });
    });
  }

  void saveVideoInBackground(List<dynamic> params) {
    String filePath = params[0];
    SendPort sendPort = params[1];

    GallerySaver.saveVideo(filePath).then((path) {
      bool success = true; // 假设文件保存成功
      sendPort.send(success);
    });
  }

  void startSavingVideo(String filePath) async {
    // 创建一个ReceivePort以接收来自Isolate的消息
    var receivePort = ReceivePort();

    // 创建一个Isolate并将ReceivePort的sendPort传给新的Isolate
    // so that it can send data back to the main thread.
    Isolate isolate = await Isolate.spawn(
      saveVideoInBackground,
      [filePath, receivePort.sendPort],
    );

    // 监听来自新Isolate的消息
    receivePort.listen((data) {
      // 获取保存结果
      bool success = data;
      receivePort.close();
      isolate.kill(priority: Isolate.immediate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Example'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_cameraController!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.videocam),
        onPressed: () {
          if (_cameraController != null) {
            _cameraController!.value.isRecordingVideo
                ? _stopRecording()
                : _startRecording();
          }
        },
      ),
    );
  }
}
