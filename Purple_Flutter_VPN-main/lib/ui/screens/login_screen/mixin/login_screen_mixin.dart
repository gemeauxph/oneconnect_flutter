part of '../login_screen.dart';

mixin _LoginScreenMixin on State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final bool isCheck = true;
  String prefemail = 'pref_email';
  String prefname = 'pref_name';
  String prefpassword = 'pref_password';
  String prefcheck = 'pref_check';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? isEmailValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your email';
    } else if (!_checkEmail(value ?? '')) {
      return 'Please enter a valid email';
    } else {
      return null;
    }
  }

  String? isPasswordValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your password';
    } else if ((value?.length ?? 0) < 3) {
      return 'Password must be at least 3 characters long';
    } else {
      return null;
    }
  }

  bool _checkEmail(String email) {
    String pattern = r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<void> login() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (!_checkEmail(_emailController.text) ||
          _emailController.text.isEmpty) {
        _formKey.currentState!.validate();
      } else if (_passwordController.text.isEmpty) {
        _formKey.currentState!.validate();
      } else {
        loginFun(_emailController.text, _passwordController.text, isCheck);
      }
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  void loginFun(String email, String password, bool isCheck) async {
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    customProgressDialog.show();
    UserLoginReq req = UserLoginReq(
        methodName: 'user_login', email: email, password: password);
    String requestBody = jsonEncode(req.toJson());
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(requestBody))},
      ).then((value) {
        customProgressDialog.dismiss();
        return value;
      }).onError((error, stackTrace) {
        customProgressDialog.dismiss();
        throw 'UnExpected Error $error';
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('status')) {
          String message = jsonResponse['message'];
          showToast(message);
        } else {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String msg = data['msg'];
          String success = "${data['success']}";
          print(data.toString());
          if (success == '1') {
            String userid = data['user_id'];
            String name = data['name'];
            String email = data['email'];
            String stripeJson = data['stripe'];

            if (stripeJson != '') {
              Map<String, dynamic> stripeObject = jsonDecode(stripeJson);
              Config.stripeJson = data["stripe"];

              if (stripeObject["status"] == "active") {
                Config.stripeRenewDate = stripeObject["current_period_end"].toString();
                Config.vipSubscription = true;
                Config.allSubscription = true;
                Config.stripeStatus = "active";
              }
            }
            Preferences.setName(name: name);
            Preferences.setEmail(email: email);
            if (isCheck) {
              Preferences.setPassword(password: password);
              Preferences.setCheck(isCheck: isCheck);
            }
            Preferences.setLogin(isLogin: true);
            Preferences.setProfileId(profileId: userid);
            Preferences.setLoginType(loginType: 'normal');
            Preferences.setProfileId(profileId: userid);
            if (Config.loginBack) {
            } else {
              final noAds = (data['no_ads'] == 0) ? data['no_ads'] : int.parse(data['no_ads']);
              final premiumServers = (data['premium_servers'] == 0) ? data['premium_servers'] : int.parse(data['premium_servers']);
              final isPremium = data['is_premium'];
              final perks = data['perks'];
              final exp = data['exp'];

              Config.noAds = noAds == "1";
              Config.premiumServersAccess = premiumServers == "1";
              Config.isPremium = isPremium == "1";
              Config.perks = perks;
              Config.expiration = exp;
            }
            IAPProvider.read(context).updateProStatus();
            replaceScreen(context, const MainScreen());
          } else {
            showToast(msg);
          }
        }
      }
    } catch (e) {
      print("Failed try again $e");
      customProgressDialog.dismiss();
      showToast('error'.tr());
    }
  }
}
