import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model/vpn_status.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

///Stages of vpn connections
enum VPNStage {
  prepare,
  authenticating,
  connecting,
  authentication,
  connected,
  disconnected,
  disconnecting,
  denied,
  error,
// ignore: constant_identifier_names
  wait_connection,
// ignore: constant_identifier_names
  vpn_generate_config,
// ignore: constant_identifier_names
  get_config,
// ignore: constant_identifier_names
  tcp_connect,
// ignore: constant_identifier_names
  udp_connect,
// ignore: constant_identifier_names
  assign_ip,
  resolve,
  exiting,
  unknown
}

class OpenVPN {
  ///Channel's names of _vpnStageSnapshot
  static const String _eventChannelVpnStage =
      "top.oneconnect.oneconnect_flutter/vpnstage";

  ///Channel's names of _channelControl
  static const String _methodChannelVpnControl =
      "top.oneconnect.oneconnect_flutter/vpncontrol";

  ///Method channel to invoke methods from native side
  static const MethodChannel _channelControl =
      MethodChannel(_methodChannelVpnControl);

  ///Snapshot of stream that produced by native side
  static Stream<String> _vpnStageSnapshot() =>
      const EventChannel(_eventChannelVpnStage).receiveBroadcastStream().cast();

  ///Timer to get vpnstatus as a loop
  ///
  ///I know it was bad practice, but this is the only way to avoid android status duration having long delay
  Timer? _vpnStatusTimer;

  ///To indicate the engine already initialize
  bool initialized = false;

  String apiKey = "";

  ///Use tempDateTime to countdown, especially on android that has delays
  DateTime? _tempDateTime;

  /// is a listener to see vpn status detail
  final Function(VpnStatus? data)? onVpnStatusChanged;

  /// is a listener to see what stage the connection was
  final Function(VPNStage stage, String rawStage)? onVpnStageChanged;

  /// OpenVPN's Constructions, don't forget to implement the listeners
  /// onVpnStatusChanged is a listener to see vpn status detail
  /// onVpnStageChanged is a listener to see what stage the connection was
  OpenVPN({this.onVpnStatusChanged, this.onVpnStageChanged});

  ///This function should be called before any usage of OpenVPN
  ///All params required for iOS, make sure you read the plugin's documentation
  ///
  ///
  ///providerBundleIdentfier is for your Network Extension identifier
  ///
  ///localizedDescription is for description to show in user's settings
  ///
  ///
  ///Will return latest VPNStage

  Future<void> initializeOneConnect(BuildContext context, String apiKey) async {
    this.apiKey = apiKey;

    //Navigator.push(context, MaterialPageRoute(builder: (context) => OneConnectPopup()));
    Timer(const Duration(seconds: 8), () {
      fetchPopupData(context);
    });
  }

  Future<void> initialize({
    String? providerBundleIdentifier,
    String? localizedDescription,
    String? groupIdentifier,
    Function(VpnStatus status)? lastStatus,
    Function(VPNStage status)? lastStage,
  }) async {
    if (Platform.isIOS) {
      assert(
          groupIdentifier != null &&
              providerBundleIdentifier != null &&
              localizedDescription != null,
          "These values are required for ios.");
    }
    onVpnStatusChanged?.call(VpnStatus.empty());
    initialized = true;
    _initializeListener();
    return _channelControl.invokeMethod("initialize", {
      "groupIdentifier": groupIdentifier,
      "providerBundleIdentifier": providerBundleIdentifier,
      "localizedDescription": localizedDescription,
    }).then((value) {
      status().then((value) => lastStatus?.call(value));
      stage().then((value) => lastStage?.call(value));
    });
  }

  ///Connect to VPN
  ///
  ///config : Your openvpn configuration script, you can find it inside your .ovpn file
  ///
  ///name : name that will show in user's notification
  ///
  ///certIsRequired : default is false, if your config file has cert, set it to true
  ///
  ///username & password : set your username and password if your config file has auth-user-pass
  ///
  ///bypassPackages : exclude some apps to access/use the VPN Connection, it was List<String> of applications package's name (Android Only)
  Future connect(String config, String name,
      {String? username,
      String? password,
      List<String>? bypassPackages,
      bool certIsRequired = false}) {
    if (!initialized) throw ("OpenVPN need to be initialized");
    if (!certIsRequired) config += "client-cert-not-required";
    _tempDateTime = DateTime.now();

    username = decrypt(username!);
    password = decrypt(password!);

    try {
      return _channelControl.invokeMethod("connect", {
        "config": config,
        "name": name,
        "username": username,
        "password": password,
        "bypass_packages": bypassPackages ?? []
      });
    } on PlatformException catch (e) {
      throw ArgumentError(e.message);
    }
  }

  static String decrypt(String encryptedStr) {
    String sb = encryptedStr;
    String str = '';

    for (int i = 0; i < sb.length; i++) {
      if ((i + 1) % 2 == 0) {
        str = "$str${sb[i]}";
      }
    }

    return str.toString().split('').reversed.join();
  }

  ///Disconnect from VPN
  void disconnect() {
    _tempDateTime = null;
    _channelControl.invokeMethod("disconnect");
    if (_vpnStatusTimer?.isActive ?? false) {
      _vpnStatusTimer?.cancel();
      _vpnStatusTimer = null;
    }
  }

  ///Check if connected to vpn
  Future<bool> isConnected() async =>
      stage().then((value) => value == VPNStage.connected);

  ///Get latest connection stage
  Future<VPNStage> stage() async {
    String? stage = await _channelControl.invokeMethod("stage");
    return _strToStage(stage ?? "disconnected");
  }

  ///Get latest connection status
  Future<VpnStatus> status() {
    //Have to check if user already connected to get real data
    return stage().then((value) async {
      var status = VpnStatus.empty();
      if (value == VPNStage.connected) {
        status = await _channelControl.invokeMethod("status").then((value) {
          if (value == null) return VpnStatus.empty();

          if (Platform.isIOS) {
            var splitted = value.split("_");
            var connectedOn = DateTime.tryParse(splitted[0]);
            if (connectedOn == null) return VpnStatus.empty();
            return VpnStatus(
              connectedOn: connectedOn,
              duration: _duration(DateTime.now().difference(connectedOn).abs()),
              packetsIn: splitted[1],
              packetsOut: splitted[2],
              byteIn: splitted[3],
              byteOut: splitted[4],
            );
          } else if (Platform.isAndroid) {
            var data = jsonDecode(value);
            var connectedOn =
                DateTime.tryParse(data["connected_on"].toString()) ??
                    _tempDateTime;
            String byteIn =
                data["byte_in"] != null ? data["byte_in"].toString() : "0";
            String byteOut =
                data["byte_out"] != null ? data["byte_out"].toString() : "0";
            if (byteIn.trim().isEmpty) byteIn = "0";
            if (byteOut.trim().isEmpty) byteOut = "0";
            return VpnStatus(
              connectedOn: connectedOn,
              duration:
                  _duration(DateTime.now().difference(connectedOn!).abs()),
              byteIn: byteIn,
              byteOut: byteOut,
              packetsIn: byteIn,
              packetsOut: byteOut,
            );
          } else {
            throw Exception("Openvpn not supported on this platform");
          }
        });
      }
      return status;
    });
  }

  ///Request android permission (Return true if already granted)
  Future<bool> requestPermissionAndroid() async {
    return _channelControl
        .invokeMethod("request_permission")
        .then((value) => value ?? false);
  }

  ///Sometimes config script has too many Remotes, it cause ANR in several devices,
  ///This happened because the plugin check every remote and somehow affected the UI to freeze
  ///
  ///Use this function if you wanted to force user to use 1 remote by randomize the remotes provided
  static Future<String?> filteredConfig(String? config) async {
    List<String> remotes = [];
    List<String> output = [];
    if (config == null) return null;
    var raw = config.split("\n");

    for (var item in raw) {
      if (item.trim().toLowerCase().startsWith("remote ")) {
        if (!output.contains("REMOTE_HERE")) {
          output.add("REMOTE_HERE");
        }
        remotes.add(item);
      } else {
        output.add(item);
      }
    }
    String fastestServer = remotes[Random().nextInt(remotes.length - 1)];
    int indexRemote = output.indexWhere((element) => element == "REMOTE_HERE");
    output.removeWhere((element) => element == "REMOTE_HERE");
    output.insert(indexRemote, fastestServer);
    return output.join("\n");
  }

  ///Convert duration that produced by native side as Connection Time
  String _duration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  ///Private function to convert String to VPNStage
  static VPNStage _strToStage(String? stage) {
    if (stage == null ||
        stage.trim().isEmpty ||
        stage.trim() == "idle" ||
        stage.trim() == "invalid") {
      return VPNStage.disconnected;
    }
    var indexStage = VPNStage.values.indexWhere((element) => element
        .toString()
        .trim()
        .toLowerCase()
        .contains(stage.toString().trim().toLowerCase()));
    if (indexStage >= 0) return VPNStage.values[indexStage];
    return VPNStage.unknown;
  }

  ///Initialize listener, called when you start connection and stoped while
  void _initializeListener() {
    _vpnStageSnapshot().listen((event) {
      var vpnStage = _strToStage(event);
      onVpnStageChanged?.call(vpnStage, event);
      if (vpnStage != VPNStage.disconnected) {
        if (Platform.isAndroid) {
          _createTimer();
        } else if (Platform.isIOS && vpnStage == VPNStage.connected) {
          _createTimer();
        }
      } else {
        _vpnStatusTimer?.cancel();
      }
    });
  }

  ///Create timer to invoke status
  void _createTimer() {
    if (_vpnStatusTimer != null) {
      _vpnStatusTimer!.cancel();
      _vpnStatusTimer = null;
    }
    _vpnStatusTimer ??=
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      onVpnStatusChanged?.call(await status());
    });
  }

  Future<List<VpnServer>> fetchOneConnect(OneConnect serverType) async {

    String packageName = (await PackageInfo.fromPlatform()).packageName;

    final url = Uri.parse('https://flutter.oneconnect.top/view/front/controller.php');
    final Map<String, String> formFields = {
      'package_name': packageName,
      'api_key': apiKey,
      'action': 'fetchUserServers',
      'type': (serverType == OneConnect.pro) ? "pro" : "free",
    };

    try {
      final response = await http.post(
        url,
        body: formFields, // Send the parameters as form fields
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => VpnServer.fromJson(data)).toList();
      } else {
        print('CHECKTEST Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('CHECKTEST Exception: $e');
      return [];
    }
  }

  String message = "";
  String title = "";
  String link = "";
  String image = "";
  String logo = "";
  String ctaText = "";
  int showStar = 0;

  Future<void> _showCustomPopup(BuildContext context) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
              child: GestureDetector(
                onTap: () { _launchURL(link); },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ad',
                          style: TextStyle(
                            color: Color(0xFF808080),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'X',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Replace the text with an image loaded from a URL
                    SizedBox(
                      width: double.infinity,
                      child: Visibility(
                        visible: image.isNotEmpty,
                        child: Image.network(
                          "https://flutter.oneconnect.top/uploads/$image",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Visibility(
                          visible: logo.isNotEmpty,
                          child: Image.network(
                            "https://flutter.oneconnect.top/uploads/$logo",
                            width: 57,
                            height: 57,
                            fit: BoxFit.cover,
                          ),
                        ) ,
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: title.isNotEmpty,
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    color: Color(0xFF111111),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: message.isNotEmpty,
                                child: Text(
                                  _stripHtmlTags(message),
                                  style: const TextStyle(
                                    color: Color(0xFF808080),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: showStar != 0,
                                child: Row(
                                  children: List.generate(5, (index) {
                                    return const Icon(
                                      Icons.star,
                                      color: Color(0xFFFDCA0E),
                                      size: 20,
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Visibility(
                        visible: ctaText.isNotEmpty && link.isNotEmpty,
                        child: ElevatedButton(
                          onPressed: () {
                            _launchURL(link);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            textStyle: MaterialStateProperty.all<TextStyle>(
                              const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0), // Add vertical padding
                            child: Text(ctaText),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ),
        );
      },
    );
  }

  Future<void> fetchPopupData(BuildContext context) async {

    String packageName = (await PackageInfo.fromPlatform()).packageName;

    try {
      final response = await http.post(
        Uri.parse('https://flutter.oneconnect.top/view/front/controller.php'),
        body: {
          'action': 'popUpSettings',
          'package_name': packageName,
          'api_key': apiKey
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        message = data['message'];
        title = data['title'];
        link = data['link'];
        image = data['image'];
        logo = data['logo'];
        ctaText = data['cta_text'];
        final int active = int.parse(data['active']);
        final int frequency = int.parse(data['frequency']);
        final int noPopup = int.parse(data['popup']);
        showStar = int.parse(data['show_star']);

        bool popupStatus = await showPopup(frequency);

        //print("CHECKACTIVE $noPopup");

        if (active == 1 && popupStatus && noPopup == 0) {
          _showCustomPopup(context);
        }
      } else {
        print('Error fetching popup data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> showPopup(int frequency) async {
    final prefs = await SharedPreferences.getInstance();

    final DateTime now = DateTime.now();
    final String formattedDate = '${now.day}-${now.month}-${now.year}';

    final String savedDate = prefs.getString('CURRENT_DATE') ?? '';

    if (savedDate != formattedDate) {
      await prefs.setString('CURRENT_DATE', formattedDate);
      await prefs.setInt('COUNTER', 0);
      return true;
    } else {
      int count = prefs.getInt('COUNTER') ?? -1;
      count++;

      await prefs.setInt('COUNTER', count);
      return count < frequency;
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _stripHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}

class VpnServer extends OneConnectModel {
  String id;
  String serverName;
  String server;
  String flagUrl;
  String ovpnConfiguration;
  String vpnUserName;
  String vpnPassword;
  String isFree;

  VpnServer(
      {required this.id,
        required this.serverName,
        required this.server,
        required this.flagUrl,
        required this.ovpnConfiguration,
        required this.vpnUserName,
        required this.vpnPassword,
        required this.isFree});

  factory VpnServer.fromJson(Map<String, dynamic> json) {
    return VpnServer(
      id: json['id'] ?? "",
      serverName: json['serverName'] ?? "",
      server: json['server'] ?? "",
      flagUrl: json['flag_url'] ?? "",
      ovpnConfiguration: json['ovpnConfiguration'] ?? "",
      vpnUserName: json['vpnUserName'],
      vpnPassword: json['vpnPassword'],
      isFree: json['isFree'] ?? "1",
    );
  }

  static String decrypt(String encryptedStr) {
    String sb = encryptedStr;
    String str = '';

    for (int i = 0; i < sb.length; i++) {
      if ((i + 1) % 2 == 0) {
        str = "$str${sb[i]}";
      }
    }

    return str.toString().split('').reversed.join();
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "serverName": serverName,
    "server": server,
    "flag_url": flagUrl,
    "ovpnConfiguration": ovpnConfiguration,
    "vpnUserName": vpnUserName,
    "vpnPassword": vpnPassword,
    "isFree": isFree,
  };
}

abstract class OneConnectModel {
  Map<String, dynamic> toJson();

  @override
  String toString() => toJson().toString();
}

enum OneConnect {
  pro,
  free,
}
