part of '../register_screen.dart';

mixin _RegisterScreenMixin on State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referenceCodeController =
      TextEditingController();
  String deviceid = Preferences.getDeviceId();
  late CustomProgressDialog customProgressDialog;
  String status = '';
  String name = '';
  String email = '';
  String password = '';
  String phoneNo = '';
  String reference = '';
  String otp = '';

  @override
  void initState() {
    super.initState();
    customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      status = await ServersHttp(context).checkOtp();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _referenceCodeController.dispose();

    super.dispose();
  }

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void setPassVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void setConfirmPassVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
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

  String? isPasswordValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your password';
    } else if ((value?.length ?? 0) < 3) {
      return 'Password must be at least 3 characters long';
    } else {
      return null;
    }
  }

  String? isConfirmPasswordValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your password';
    } else if ((value?.length ?? 0) < 3) {
      return 'Password must be at least 3 characters long';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      return 'Password does not match';
    } else {
      return null;
    }
  }

  String? isPhoneValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your phone number';
    } else if ((value?.length ?? 0) < 10) {
      return 'Phone number must be at least 10 characters long';
    } else {
      return null;
    }
  }

  bool _checkEmail(String email) {
    String pattern = r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<void> register() async {
    name = _nameController.text;
    email = _emailController.text;
    password = _passwordController.text;
    phoneNo = _phoneController.text;
    reference = _referenceCodeController.text;
    if (name == '' || name.isEmpty) {
      validate();
    } else if (!_checkEmail(email) || email.isEmpty) {
      validate();
    } else if (password == '' || password.isEmpty) {
      validate();
    } else if (phoneNo == '' || phoneNo.isEmpty) {
      validate();
    } else if (reference == '' || reference.isEmpty) {
      validate();
    } else {
      bool isConnected = await networkInfo.isConnected;
      if (isConnected) {
        customProgressDialog =
            CustomProgressDialog(context, dismissable: false, onDismiss: () {});
        customProgressDialog.show();
        if (status == "true") {
          otp = generateOTP().toString();
          BlocProvider.of<RegisterBloc>(context)
              .add(VerificationCall(email: email, otp: otp));
        } else {
          BlocProvider.of<RegisterBloc>(context).add(RegistationCall(
              deviceid: deviceid,
              name: name,
              email: email,
              passwrod: password,
              phoneNo: phoneNo,
              reference: reference));
        }
      } else {
        showToast("no_internet_msg".tr());
      }
    }
  }

  int generateOTP() {
    Random random = Random();
    return random.nextInt(9000) + 1000;
  }
}
