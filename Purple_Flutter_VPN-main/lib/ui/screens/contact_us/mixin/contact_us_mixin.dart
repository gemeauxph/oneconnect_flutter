part of '../contact_us_screen.dart';

mixin _ContactUsMixin on State<ContactUsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<ContactList> items = [
    ContactList(id: "007", subject: "Select contact type")
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
    ReqWithUserId req = ReqWithUserId(methodName: 'get_contact');
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
          _nameController.text = jsonData["name"];
          _emailController.text = jsonData["email"];
          final data = jsonData[AppConstants.tag];
          for (var i = 0; i < data.length; i++) {
            final object = data[i];
            final id = object['id'];
            final subject = object['subject'];

            items.add(ContactList(id: id, subject: subject));
          }
          setState(() {});
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }

  Future<void> login() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      String name = _nameController.text;
      String email = _emailController.text;
      String desc = _descriptionController.text;
      if (dropdownvalue == "007") {
        showToast("select_cat_msg".tr());
      } else if (name == '' || name.isEmpty) {
        validate();
      } else if (!_checkEmail(email) || email.isEmpty) {
        validate();
      } else if (desc == '' || desc.isEmpty) {
        validate();
      } else {
        form();
      }
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  Future<void> form() async {
    ContactUSMsgReq req = ContactUSMsgReq(
        methodName: 'user_contact_us',
        sendEmail: _emailController.text,
        sendName: _nameController.text,
        sendMessage: _descriptionController.text,
        contactSubject: dropdownvalue);
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
          String msg = data['msg'];
          String success = "${data['success']}";
          print(data.toString());
          if (success == '1') {
            _descriptionController.clear();
            dropdownvalue = "007";
            showToast(msg);
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
