part of '../reward_point_claim.dart';

mixin _RewardPointMixin on State<RewardPointClaim> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  List<PaymentList> items = [
    PaymentList(id: "007", modeTitle: "Select contact type")
  ];
  String dropdownvalue = '007';

  @override
  void initState() {
    super.initState();
    callData();
  }

  void callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        getContact();
      }
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  Future<void> getContact() async {
    ReqWithUserId req = ReqWithUserId(methodName: 'get_payment_mode');
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
          final data = jsonData[AppConstants.tag];
          for (var i = 0; i < data.length; i++) {
            final object = data[i];
            final id = object['id'];
            final modeTitle = object['mode_title'];
            items.add(PaymentList(id: id, modeTitle: modeTitle));
          }
          setState(() {});
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }

  Future<void> form() async {
    PaymentReq req = PaymentReq(
        methodName: 'user_redeem_request',
        userPoints: widget.userPoints,
        paymentMode: dropdownvalue,
        detail: _descriptionController.text);
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
          final data = jsonData[AppConstants.tag];
          for (var i = 0; i < data.length; i++) {
            final object = data[i];
            final msg = object['msg'];
            final success = object['success'];

            if (success == "1") {}
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
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

  String? isNameValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your name';
    } else if ((value?.length ?? 0) < 3) {
      return 'Name must be at least 3 characters long';
    } else {
      return null;
    }
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

  bool _checkEmail(String email) {
    String pattern = r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
}
