// ignore_for_file: deprecated_member_use, package_api_docs, public_member_api_docs
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:io';
import 'dart:async';

import 'package:cart/helper/toast.dart';

String STA_DEFAULT_SSID = "STA_SSID";
const String STA_DEFAULT_PASSWORD = "STA_PASSWORD";
const NetworkSecurity STA_DEFAULT_SECURITY = NetworkSecurity.NONE;

const String AP_DEFAULT_SSID = "AP_SSID";
const String AP_DEFAULT_PASSWORD = "AP_PASSWORD";

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  String? _sPreviousAPSSID = "";
  String? _sPreviousPreSharedKey = "";

  List<WifiNetwork?>? _htResultNetwork;
  final Map<String, bool> _htIsNetworkRegistered = {};

  bool _isEnabled = false;
  bool _isConnected = false;
  bool _isWiFiAPEnabled = false;
  bool _isWiFiAPSSIDHidden = false;
  bool _isWifiAPSupported = true;
  bool _isWifiEnableOpenSettings = false;
  bool _isWifiDisableOpenSettings = false;

  final TextStyle textStyle = const TextStyle(color: Colors.white);

  late Socket socket;

  String log = "";

  @override
  initState() {
    WiFiForIoTPlugin.isEnabled().then((val) {
      _isEnabled = val;
    });

    WiFiForIoTPlugin.isConnected().then((val) {
      _isConnected = val;
    });

    WiFiForIoTPlugin.isWiFiAPEnabled().then((val) {
      _isWiFiAPEnabled = val;
    }).catchError((val) {
      _isWifiAPSupported = false;
    });

    WiFiForIoTPlugin.forceWifiUsage(true);
    // autoScanWIFI();
    super.initState();
  }

  // 自动扫描
  autoScanWIFI() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      _htResultNetwork = await loadWifiList();
      setState(() {});
    });
  }

  storeAndConnect(String psSSID, String psKey) async {
    await storeAPInfos();
    await WiFiForIoTPlugin.setWiFiAPSSID(psSSID);
    await WiFiForIoTPlugin.setWiFiAPPreSharedKey(psKey);
  }

  // 建立socket连接
  startSocketConnect() async {
    ToastUtils.showToast('开始连接');
    try {
      socket = await Socket.connect('192.168.4.1', 7788);
      socket.writeln('Hello, server!');
      // 接收来自服务器的消息
      socket.listen((List<int> event) {
        final message = String.fromCharCodes(event);
        setState(() {
          log = '接收到服务端消息： $message';
        });
      }, onDone: () {
        setState(() {
          log = '连接中断';
        });
        socket.close();
      }, onError: (error) {
        setState(() {
          log = '连接异常';
        });
        socket.close();
      });

      ToastUtils.showToast('连接服务端成功');

      Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        socket.writeln('Ping from client at ${DateTime.now()}');
      });
    } catch (e) {
      ToastUtils.showToast('连接服务端失败： $e', length: 'long');
    }
  }

  storeAPInfos() async {
    String? sAPSSID;
    String? sPreSharedKey;

    try {
      sAPSSID = await WiFiForIoTPlugin.getWiFiAPSSID();
    } on PlatformException {
      sAPSSID = "";
    }

    try {
      sPreSharedKey = await WiFiForIoTPlugin.getWiFiAPPreSharedKey();
    } on PlatformException {
      sPreSharedKey = "";
    }

    setState(() {
      _sPreviousAPSSID = sAPSSID;
      _sPreviousPreSharedKey = sPreSharedKey;
    });
  }

  restoreAPInfos() async {
    WiFiForIoTPlugin.setWiFiAPSSID(_sPreviousAPSSID!);
    WiFiForIoTPlugin.setWiFiAPPreSharedKey(_sPreviousPreSharedKey!);
  }

  // [sAPSSID, sPreSharedKey]
  Future<List<String>> getWiFiAPInfos() async {
    String? sAPSSID;
    String? sPreSharedKey;

    try {
      sAPSSID = await WiFiForIoTPlugin.getWiFiAPSSID();
    } on Exception {
      sAPSSID = "";
    }

    try {
      sPreSharedKey = await WiFiForIoTPlugin.getWiFiAPPreSharedKey();
    } on Exception {
      sPreSharedKey = "";
    }

    return [sAPSSID!, sPreSharedKey!];
  }

  Future<WIFI_AP_STATE?> getWiFiAPState() async {
    int? iWiFiState;

    WIFI_AP_STATE? wifiAPState;

    try {
      iWiFiState = await WiFiForIoTPlugin.getWiFiAPState();
    } on Exception {
      iWiFiState = WIFI_AP_STATE.WIFI_AP_STATE_FAILED.index;
    }

    if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_DISABLING.index) {
      wifiAPState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLING;
    } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_DISABLED.index) {
      wifiAPState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLED;
    } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_ENABLING.index) {
      wifiAPState = WIFI_AP_STATE.WIFI_AP_STATE_ENABLING;
    } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_ENABLED.index) {
      wifiAPState = WIFI_AP_STATE.WIFI_AP_STATE_ENABLED;
    } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_FAILED.index) {
      wifiAPState = WIFI_AP_STATE.WIFI_AP_STATE_FAILED;
    }

    return wifiAPState!;
  }

  Future<List<APClient>> getClientList(
      bool onlyReachables, int reachableTimeout) async {
    List<APClient> htResultClient;

    try {
      htResultClient = await WiFiForIoTPlugin.getClientList(
          onlyReachables, reachableTimeout);
    } on PlatformException {
      htResultClient = <APClient>[];
    }

    return htResultClient;
  }

  Future<List<WifiNetwork>> loadWifiList() async {
    List<WifiNetwork> htResultNetwork;
    try {
      htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      htResultNetwork = <WifiNetwork>[];
    }

    return htResultNetwork;
  }

  isRegisteredWifiNetwork(String ssid) async {
    bool bIsRegistered;

    try {
      bIsRegistered = await WiFiForIoTPlugin.isRegisteredWifiNetwork(ssid);
    } on PlatformException {
      bIsRegistered = false;
    }

    setState(() {
      _htIsNetworkRegistered[ssid] = bIsRegistered;
    });
  }

  void showClientList() async {
    /// Refresh the list and show in console
    getClientList(false, 300).then((val) => val.forEach((oClient) {
          print("************************");
          print("Client :");
          print("ipAddr = '${oClient.ipAddr}'");
          print("hwAddr = '${oClient.hwAddr}'");
          print("device = '${oClient.device}'");
          print("isReachable = '${oClient.isReachable}'");
          print("************************");
        }));
  }

  Widget getWidgets() {
    WiFiForIoTPlugin.isConnected().then((val) {
      setState(() {
        _isConnected = val;
      });
    });

    // disable scanning for ios as not supported
    if (_isConnected || Platform.isIOS) {
      _htResultNetwork = null;
    }

    if (_htResultNetwork != null && _htResultNetwork!.isNotEmpty) {
      final List<ListTile> htNetworks = <ListTile>[];

      for (var oNetwork in _htResultNetwork!) {
        final PopupCommand oCmdConnect =
            PopupCommand("Connect", oNetwork!.ssid!);
        final PopupCommand oCmdRemove = PopupCommand("Remove", oNetwork.ssid!);

        final List<PopupMenuItem<PopupCommand>> htPopupMenuItems = [];

        htPopupMenuItems.add(
          PopupMenuItem<PopupCommand>(
            value: oCmdConnect,
            child: const Text('连接'),
          ),
        );

        setState(() {
          isRegisteredWifiNetwork(oNetwork.ssid!);
          if (_htIsNetworkRegistered.containsKey(oNetwork.ssid) &&
              _htIsNetworkRegistered[oNetwork.ssid]!) {
            htPopupMenuItems.add(
              PopupMenuItem<PopupCommand>(
                value: oCmdRemove,
                child: const Text('删除'),
              ),
            );
          }

          htNetworks.add(
            ListTile(
              title: Text(
                  "Item ${oNetwork.ssid!}${(_htIsNetworkRegistered.containsKey(oNetwork.ssid) && _htIsNetworkRegistered[oNetwork.ssid]!) ? " *" : ""}"),
              trailing: PopupMenuButton<PopupCommand>(
                padding: EdgeInsets.zero,
                onSelected: (PopupCommand poCommand) {
                  switch (poCommand.command) {
                    case "Connect":
                      WiFiForIoTPlugin.connect(oNetwork.ssid!,
                          // password: STA_DEFAULT_PASSWORD,
                          joinOnce: false,
                          security: STA_DEFAULT_SECURITY);
                      break;
                    case "Remove":
                      WiFiForIoTPlugin.removeWifiNetwork(poCommand.argument);
                      break;
                    default:
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => htPopupMenuItems,
              ),
            ),
          );
        });
      }

      return ListView(
        padding: kMaterialListPadding,
        children: htNetworks,
      );
    } else {
      return SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: Platform.isIOS
                ? getButtonWidgetsForiOS()
                : getButtonWidgetsForAndroid(),
          ),
        ),
      );
    }
  }

  List<Widget> getButtonWidgetsForAndroid() {
    final List<Widget> htPrimaryWidgets = <Widget>[];

    WiFiForIoTPlugin.isEnabled().then((val) {
      setState(() {
        _isEnabled = val;
      });
    });

    if (_isEnabled) {
      htPrimaryWidgets.addAll([
        const SizedBox(height: 10),
        const Text("Wifi 启用的"),
        MaterialButton(
          color: Colors.blue,
          child: Text("禁用", style: textStyle),
          onPressed: () {
            WiFiForIoTPlugin.setEnabled(false,
                shouldOpenSettings: _isWifiDisableOpenSettings);
          },
        ),
      ]);

      WiFiForIoTPlugin.isConnected().then((val) {
        setState(() {
          _isConnected = val;
        });
      });

      if (_isConnected) {
        htPrimaryWidgets.addAll(<Widget>[
          const Text("已连接"),
          FutureBuilder(
              future: WiFiForIoTPlugin.getSSID(),
              initialData: "加载中..",
              builder: (BuildContext context, AsyncSnapshot<String?> ssid) {
                return Text("SSID: ${ssid.data}");
              }),
          FutureBuilder(
              future: WiFiForIoTPlugin.getBSSID(),
              initialData: "加载中..",
              builder: (BuildContext context, AsyncSnapshot<String?> bssid) {
                return Text("BSSID: ${bssid.data}");
              }),
          FutureBuilder(
              future: WiFiForIoTPlugin.getCurrentSignalStrength(),
              initialData: 0,
              builder: (BuildContext context, AsyncSnapshot<int?> signal) {
                return Text("信号: ${signal.data}");
              }),
          FutureBuilder(
              future: WiFiForIoTPlugin.getFrequency(),
              initialData: 0,
              builder: (BuildContext context, AsyncSnapshot<int?> freq) {
                return Text("频率 : ${freq.data}");
              }),
          FutureBuilder(
              future: WiFiForIoTPlugin.getIP(),
              initialData: "加载中..",
              builder: (BuildContext context, AsyncSnapshot<String?> ip) {
                return Text("IP : ${ip.data}");
              }),
          MaterialButton(
            color: Colors.blue,
            child: Text("断开", style: textStyle),
            onPressed: () {
              WiFiForIoTPlugin.disconnect();
            },
          ),
          // 建立socket连接 startSocketConnect
          MaterialButton(
            color: Colors.blue,
            child: Text("连接服务", style: textStyle),
            onPressed: () {
              startSocketConnect();
            },
          ),
          CheckboxListTile(
              title: const Text("禁用WiFi设置"),
              subtitle: const Text("Available only on android API level >= 29"),
              value: _isWifiDisableOpenSettings,
              onChanged: (bool? setting) {
                if (setting != null) {
                  setState(() {
                    _isWifiDisableOpenSettings = setting;
                  });
                }
              })
        ]);
      } else {
        htPrimaryWidgets.addAll(<Widget>[
          const Text("WIFI已断开"),
          MaterialButton(
            color: Colors.blue,
            child: Text("扫描", style: textStyle),
            onPressed: () async {
              _htResultNetwork = await loadWifiList();
              setState(() {});
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                color: Colors.blue,
                child: Text("使用 WiFi", style: textStyle),
                onPressed: () {
                  // 和ESP32连接socket前必须先设置forceWifiUsage(true)
                  WiFiForIoTPlugin.forceWifiUsage(true);
                },
              ),
              const SizedBox(width: 50),
              MaterialButton(
                color: Colors.blue,
                child: Text("使用 3G/4G", style: textStyle),
                onPressed: () {
                  WiFiForIoTPlugin.forceWifiUsage(false);
                },
              ),
            ],
          ),
          CheckboxListTile(
              title: const Text("在设置中禁用WiFi"),
              subtitle: const Text("Available only on android API level >= 29"),
              value: _isWifiDisableOpenSettings,
              onChanged: (bool? setting) {
                if (setting != null) {
                  setState(() {
                    _isWifiDisableOpenSettings = setting;
                  });
                }
              })
        ]);
      }
    } else {
      htPrimaryWidgets.addAll(<Widget>[
        const SizedBox(height: 10),
        const Text("Wifi 已禁用"),
        MaterialButton(
          color: Colors.blue,
          child: Text("启用1", style: textStyle),
          onPressed: () {
            setState(() {
              WiFiForIoTPlugin.setEnabled(true,
                  shouldOpenSettings: _isWifiEnableOpenSettings);
            });
          },
        ),
        CheckboxListTile(
            title: const Text("启用WIFI设置"),
            subtitle: const Text("Available only on android API level >= 29"),
            value: _isWifiEnableOpenSettings,
            onChanged: (bool? setting) {
              if (setting != null) {
                setState(() {
                  _isWifiEnableOpenSettings = setting;
                });
              }
            })
      ]);
    }

    htPrimaryWidgets.add(const Divider(
      height: 32.0,
    ));

    if (_isWifiAPSupported) {
      htPrimaryWidgets.addAll(<Widget>[
        const Text("WiFi AP 状态"),
        FutureBuilder(
            future: getWiFiAPState(),
            initialData: WIFI_AP_STATE.WIFI_AP_STATE_DISABLED,
            builder: (BuildContext context,
                AsyncSnapshot<WIFI_AP_STATE?> wifiState) {
              final List<Widget> widgets = [];

              if (wifiState.data == WIFI_AP_STATE.WIFI_AP_STATE_ENABLED) {
                widgets.add(MaterialButton(
                  color: Colors.blue,
                  child: Text("获取客户端列表", style: textStyle),
                  onPressed: () {
                    showClientList();
                  },
                ));
              }

              widgets.add(Text(wifiState.data.toString()));

              return Column(children: widgets);
            }),
      ]);

      WiFiForIoTPlugin.isWiFiAPEnabled()
          .then((val) => setState(() {
                _isWiFiAPEnabled = val;
              }))
          .catchError((val) {
        _isWiFiAPEnabled = false;
      });

      if (_isWiFiAPEnabled) {
        htPrimaryWidgets.addAll(<Widget>[
          const Text("Wifi AP 启用"),
          MaterialButton(
            color: Colors.blue,
            child: Text("禁用", style: textStyle),
            onPressed: () {
              WiFiForIoTPlugin.setWiFiAPEnabled(false);
            },
          ),
        ]);
      } else {
        htPrimaryWidgets.addAll(<Widget>[
          const Text("Wifi AP 禁用"),
          MaterialButton(
            color: Colors.blue,
            child: Text("启用2", style: textStyle),
            onPressed: () {
              WiFiForIoTPlugin.setWiFiAPEnabled(true);
            },
          ),
        ]);
      }

      WiFiForIoTPlugin.isWiFiAPSSIDHidden()
          .then((val) => setState(() {
                _isWiFiAPSSIDHidden = val;
              }))
          .catchError((val) => _isWiFiAPSSIDHidden = false);
      if (_isWiFiAPSSIDHidden) {
        htPrimaryWidgets.add(const Text("SSID 隐藏"));
        !_isWiFiAPEnabled
            ? MaterialButton(
                color: Colors.blue,
                child: Text("显示", style: textStyle),
                onPressed: () {
                  WiFiForIoTPlugin.setWiFiAPSSIDHidden(false);
                },
              )
            : const SizedBox(width: 0, height: 0);
      } else {
        htPrimaryWidgets.add(const Text("SSID is 可见"));
        !_isWiFiAPEnabled
            ? MaterialButton(
                color: Colors.blue,
                child: Text("隐藏", style: textStyle),
                onPressed: () {
                  WiFiForIoTPlugin.setWiFiAPSSIDHidden(true);
                },
              )
            : const SizedBox(width: 0, height: 0);
      }

      FutureBuilder(
          future: getWiFiAPInfos(),
          initialData: const <String>[],
          builder: (BuildContext context, AsyncSnapshot<List<String>> info) {
            htPrimaryWidgets.addAll(<Widget>[
              Text("SSID : ${info.data![0]}"),
              Text("KEY  : ${info.data![1]}"),
              MaterialButton(
                color: Colors.blue,
                child: Text(
                    "Set AP info ($AP_DEFAULT_SSID/$AP_DEFAULT_PASSWORD)",
                    style: textStyle),
                onPressed: () {
                  storeAndConnect(AP_DEFAULT_SSID, AP_DEFAULT_PASSWORD);
                },
              ),
              Text("AP SSID stored : $_sPreviousAPSSID"),
              Text("KEY stored : $_sPreviousPreSharedKey"),
              MaterialButton(
                color: Colors.blue,
                child: Text("保存 AP 信息", style: textStyle),
                onPressed: () {
                  storeAPInfos();
                },
              ),
              MaterialButton(
                color: Colors.blue,
                child: Text("恢复AP信息", style: textStyle),
                onPressed: () {
                  restoreAPInfos();
                },
              ),
            ]);

            return Text("SSID : ${info.data![0]}");
          });
    } else {
      htPrimaryWidgets.add(const Center(
          child: Text("Wifi AP probably not supported by your device")));
    }

    htPrimaryWidgets.add(Text(
      log,
      style: const TextStyle(color: Colors.green, fontSize: 24),
    ));

    return htPrimaryWidgets;
  }

  List<Widget> getButtonWidgetsForiOS() {
    final List<Widget> htPrimaryWidgets = <Widget>[];

    WiFiForIoTPlugin.isEnabled().then((val) => setState(() {
          _isEnabled = val;
        }));

    if (_isEnabled) {
      htPrimaryWidgets.add(const Text("Wifi Enabled"));
      WiFiForIoTPlugin.isConnected().then((val) => setState(() {
            _isConnected = val;
          }));

      String? sSSID;

      if (_isConnected) {
        htPrimaryWidgets.addAll(<Widget>[
          const Text("已连接"),
          FutureBuilder(
              future: WiFiForIoTPlugin.getSSID(),
              initialData: "Loading..",
              builder: (BuildContext context, AsyncSnapshot<String?> ssid) {
                sSSID = ssid.data;

                return Text("SSID: ${ssid.data}");
              }),
        ]);

        if (sSSID == STA_DEFAULT_SSID) {
          htPrimaryWidgets.addAll(<Widget>[
            MaterialButton(
              color: Colors.blue,
              child: Text("断开连接", style: textStyle),
              onPressed: () {
                WiFiForIoTPlugin.disconnect();
              },
            ),
          ]);
        } else {
          htPrimaryWidgets.addAll(<Widget>[
            MaterialButton(
              color: Colors.blue,
              child: Text("Connect to '$AP_DEFAULT_SSID'", style: textStyle),
              onPressed: () {
                WiFiForIoTPlugin.connect(STA_DEFAULT_SSID,
                    password: STA_DEFAULT_PASSWORD,
                    joinOnce: true,
                    security: NetworkSecurity.WPA);
              },
            ),
          ]);
        }
      } else {
        htPrimaryWidgets.addAll(<Widget>[
          const Text("Disconnected"),
          MaterialButton(
            color: Colors.blue,
            child: Text("Connect to '$AP_DEFAULT_SSID'", style: textStyle),
            onPressed: () {
              WiFiForIoTPlugin.connect(STA_DEFAULT_SSID,
                  password: STA_DEFAULT_PASSWORD,
                  joinOnce: true,
                  security: NetworkSecurity.WPA);
            },
          ),
        ]);
      }
    } else {
      htPrimaryWidgets.addAll(<Widget>[
        const Text("Wifi Disabled?"),
        MaterialButton(
          color: Colors.blue,
          child: Text("Connect to '$AP_DEFAULT_SSID'", style: textStyle),
          onPressed: () {
            WiFiForIoTPlugin.connect(STA_DEFAULT_SSID,
                password: STA_DEFAULT_PASSWORD,
                joinOnce: true,
                security: NetworkSecurity.WPA);
          },
        ),
      ]);
    }

    return htPrimaryWidgets;
  }

  @override
  Widget build(BuildContext poContext) {
    return Scaffold(
      appBar: AppBar(
        title: Platform.isIOS
            ? const Text('WifiFlutter Example iOS')
            : const Text('WifiFlutter Example Android'),
        actions: _isConnected
            ? <Widget>[
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case "disconnect":
                        WiFiForIoTPlugin.disconnect();
                        break;
                      case "remove":
                        WiFiForIoTPlugin.getSSID().then(
                            (val) => WiFiForIoTPlugin.removeWifiNetwork(val!));
                        break;
                      default:
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<String>>[
                    const PopupMenuItem<String>(
                      value: "disconnect",
                      child: Text('Disconnect'),
                    ),
                    const PopupMenuItem<String>(
                      value: "remove",
                      child: Text('Remove'),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: getWidgets(),
    );
  }
}

class PopupCommand {
  String command;
  String argument;

  PopupCommand(this.command, this.argument);
}
