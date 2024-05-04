
## Prerequisites
*Install OneConnect library by putting this code in Pubsec.yaml*
``` 
oneconnect_flutter: ^1.0.0
```

*Import OneConnect library in you Dart file*
```
import 'package:oneconnect_flutter/openvpn_flutter.dart';
```

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

* Save serves to list
```
List<VpnServer> vpnServerList = [];

vpnServerList.addAll(await AppConstants.openVPN.fetchOneConnect(OneConnect.free)); //Free
vpnServerList.addAll(await AppConstants.openVPN.fetchOneConnect(OneConnect.pro)); //Pro
```

**Connect to VPN**
///Declare VPN variables
VPNStage? vpnStage;
VpnStatus? vpnStatus;

///OpenVPN engine
late OpenVPN engine;

///Check if VPN is connected
bool get isConnected => vpnStage == VPNStage.connected;

///Initialize VPN engine and load last server
void initialize(BuildContext context) {
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
  }

///VPN status changed
void onVpnStatusChanged(VpnStatus? status) {
	vpnStatus = status;
}

///VPN stage changed
void onVpnStageChanged(VPNStage stage, String rawStage) {
	vpnStage = stage;
	if (stage == VPNStage.error) {
	  Future.delayed(const Duration(seconds: 3)).then((value) {
	    vpnStage = VPNStage.disconnected;
	  });
	}	
}

///Connect to VPN server
void connect() async {

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

///Disconnect VPN
void disconnect() {
	engine.disconnect();
}
