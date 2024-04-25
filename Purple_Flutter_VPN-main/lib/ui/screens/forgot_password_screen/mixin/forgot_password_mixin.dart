part of '../forgot_password_screen.dart';

mixin _ForgotPasswordMixin on State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  late CustomProgressDialog customProgressDialog;
  String email = '';

  @override
  void dispose() {
    _emailController.dispose();
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

  Future<void> submitButton() async {
    email = _emailController.text;
    if (!_checkEmail(email) || email.isEmpty) {
      isEmailValid(email);
    } else {
      BlocProvider.of<ForgetPasswordBloc>(context)
          .add(ForgetPasswordCall(email: email));
    }
  }

  void forgetPassword(String sentEmail) async {
    customProgressDialog.show();
    String methodBody = jsonEncode({
      'sign': AppConstants.sign,
      'salt': AppConstants.randomSalt.toString(),
      'package_name': AppConstants.packageName,
      'method_name': 'forgot_pass',
      'email': sentEmail
    });
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      ).then((value) {
        customProgressDialog.dismiss();
        return value;
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('status')) {
          String message = jsonResponse['message'];
          showToast(message);
        } else {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String msg = data['msg'];
          showToast(msg);
        }
      } else {
        showToast('error'.tr());
      }
    } catch (e) {
      showToast('error'.tr());
    }
  }
}
