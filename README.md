# OneConnect Flutter
Use OneConnect in your flutter project to get OneConnect VPN servers and connect to vpn
<br>
<br>

## Prerequisites
*Install OneConnect library by putting this code in Pubsec.yaml*
``` 
oneconnect_flutter: ^1.0.0
```

*Import OneConnect library in you Dart file*
```
import 'package:oneconnect_flutter/openvpn_flutter.dart';
```
<br>

## Fetch Servers
* Create instance of OpenVPN
```
OpenVPN openVPN = OpenVPN();
```
* Initialize OneConnect
```
var oneConnectKey = "YOUR_ONECONNECT_API_KEY";
openVPN.initializeOneConnect(context, oneConnectKey); //Put BuildContext and API key
```

* Save servers to list
  *VpnServer class contains the server id, name, flag, ovpn configuration, username, password and server type (free or pro)*
```
List<VpnServer> vpnServerList = [];

vpnServerList.addAll(await AppConstants.openVPN.fetchOneConnect(OneConnect.free)); //Free
vpnServerList.addAll(await AppConstants.openVPN.fetchOneConnect(OneConnect.pro)); //Pro

//Logging first server from vpnServerList for visualization
debugPrint("${vpnServerList[0].id}"); //Server id
debugPrint("${vpnServerList[0].serverName}"); //Server name as show in OneConnect account
debugPrint("${vpnServerList[0].flagUrl}"); //Country flag image url of server
debugPrint("${vpnServerList[0].ovpnConfiguration}"); //Configuration exclusive to OpenVPN
debugPrint("${vpnServerList[0].vpnUserName}"); //VPN username
debugPrint("${vpnServerList[0].vpnPassword}"); //VPN passwqord
debugPrint("${vpnServerList[0].isFree}"); //Equals to 1 of server is free
```
<br>

## Connecting to VPN
* Declare variables<br>
*Select a server from the server list you have fetched earlier then save that to 'vpnConfig'*

```
VPNStage? vpnStage;
VpnStatus? vpnStatus;
VpnServer? vpnConfig; //Initialize variable later using a server from vpnServerList

//OpenVPN engine
late OpenVPN engine;

//Check if VPN is connected
bool get isConnected => vpnStage == VPNStage.connected;
```

* Initialize VPN engine
```
    engine = OpenVPN(
        onVpnStageChanged: onVpnStageChanged,
        onVpnStatusChanged: onVpnStatusChanged)
      ..initialize(
        lastStatus: onVpnStatusChanged,
        lastStage: (stage) => onVpnStageChanged(stage, stage.name),
        groupIdentifier: groupIdentifier,
        localizedDescription: localizationDescription,
        providerBundleIdentifier: providerBundleIdentifier,
      );
  
```

* Required methods
```
//VPN status changed
void onVpnStatusChanged(VpnStatus? status) {
	vpnStatus = status;
}

//VPN stage changed
void onVpnStageChanged(VPNStage stage, String rawStage) {
	vpnStage = stage;
	if (stage == VPNStage.error) {
	  Future.delayed(const Duration(seconds: 3)).then((value) {
	    vpnStage = VPNStage.disconnected;
	  });
	}	
}
```

* Connect VPN using OneConnect<br>
*For the sake of demonstration, we will use the first server (position 0) in vpnServerList and save that to 'vpnConfig'. Modify the code based on how to select servers in your project*
```
void connect() async {

    vpnConfig = vpnServerList[0];

	const bool certificateVerify = true; //Turn it on if you use certificate
	String? config;

	try {
	  config = await OpenVPN.filteredConfig(vpnConfig?.ovpnConfiguration);
	} catch (e) {
	  config = vpnConfig?.ovpnConfiguration;
	}

	if (config == null) return;

	engine.connect(
	  config,
	  vpnConfig!.serverName,
	  certIsRequired: certificateVerify,
	  username: vpnConfig!.vpnUserName,
	  password: vpnConfig!.vpnPassword,
	);
}
```

* Disconnect VPN
```
engine.disconnect();
```
