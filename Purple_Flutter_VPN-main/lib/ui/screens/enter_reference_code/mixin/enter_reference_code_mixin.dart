part of '../enter_reference_code_screen.dart';

mixin _EnterReferenceCodeMixin on State<EnterReferenceCodeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  String code = '';

  String? isCodeValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter code';
    } else if ((value?.length ?? 0) < 3) {
      return 'Name must be at least 3 characters long';
    } else {
      return null;
    }
  }

  bool validate() {
    _formKey.currentState?.save();
    if (_formKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  void redeemProcess() async {
    code = _codeController.text;
    _codeController.clear();
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        redeem();
      }
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  Future<void> redeem() async {
    UserReferenceCode req = UserReferenceCode(
        methodName: 'apply_user_refrence_code', code: _codeController.text);
    String methodBody = jsonEncode(req.toJson());
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    customProgressDialog.show();
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      ).then((value) {
        customProgressDialog.dismiss();
        return value;
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.containsKey("status")) {
          String status = jsonData["status"];
          String message = jsonData["message"];

          if (status == "-2") {
            replaceScreen(context, const LoginScreen());
            showToast(message);
          } else {
            showToast(message);
          }
        } else {
          Map<String, dynamic> data = jsonData[AppConstants.tag];
          String success = "${data['success']}";
          String msg = data['msg'];
          if (success == "1") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                duration: const Duration(seconds: 2),
              ),
            );
            replaceScreen(context, const MainScreen());
          } else {
            showToast(msg);
          }
          setState(() {});
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }
}
