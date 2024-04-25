import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/api_req/get_req_with_userid.dart';
import 'package:ndvpn/core/models/user_info.dart';
import 'package:ndvpn/core/models/api_req/user_profile_update.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/gallery_permission.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'package:ndvpn/ui/screens/register_screen/register_screen.dart';
import 'package:permission_handler/permission_handler.dart';
part 'mixin/edit_profile_mixin.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen>
    with _EditProfileMixin {
  final ImagePicker picker = ImagePicker();
  bool isnetworkimage = false;
  File? image;
  bool isValidate = false;
  String profileImage = "";
  String name = Preferences.getName();
  String email = Preferences.getEmail();
  String phone = Preferences.getPhoneNo();
  String userImage = Preferences.getUserImage();

  @override
  void initState() {
    callData();
    super.initState();
  }

  callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        getProfile();
      }
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  void getProfile() async {
    ReqWithUserId req = ReqWithUserId(methodName: "user_profile");
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
          if (success == "1") {
            nameController.text = data["name"];
            emailController.text = data["email"];
            phoneController.text = data["phone"];
            youtubeController.text = data["user_youtube"];
            instraController.text = data["user_instagram"];
            String userimage = data["user_image"];
            if (userimage != "") {
              isnetworkimage = true;
              profileImage = userimage;
            } else {
              isnetworkimage = false;
              profileImage = "";
            }
            setState(() {});
          }
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    var themehandler = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 26),
          onPressed: () {
            Navigator.pop(
                context,
                UserInfomation(
                    name: nameController.text, email: emailController.text));
          },
        ),
        title: Column(
          children: [
            const Text("edit_profile",
                    style: TextStyle(
                        fontSize: 22,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600))
                .tr()
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Card(
          color: Theme.of(context).cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Stack(
                    children: [
                      if (isnetworkimage)
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              // color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                              ),
                              child: CachedNetworkImage(
                                imageUrl: profileImage,
                                placeholder: (context, url) => Image.asset(
                                  "${AssetsPath.imagepath}user2.jpg",
                                  fit: BoxFit.cover,
                                  height: 130,
                                  width: 130,
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "${AssetsPath.imagepath}user2.jpg",
                                  fit: BoxFit.cover,
                                  height: 130,
                                  width: 130,
                                ),
                                height: 130,
                                width: 130,
                              ),
                            ),
                          ),
                        ),
                      if (!isnetworkimage && image == null)
                        Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              // color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                              ),
                              child: Image.asset(
                                "${AssetsPath.imagepath}user2.jpg",
                                fit: BoxFit.cover,
                                height: 130,
                                width: 130,
                              ),
                            ),
                          ),
                        ),
                      if (!isnetworkimage && image != null)
                        Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              // color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                              ),
                              child: Image.file(
                                image ?? File(""),
                                fit: BoxFit.cover,
                                height: 130,
                                width: 130,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                          bottom: 2,
                          right: 4,
                          child: Visibility(
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Wrap(children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('camera').tr(),
                                      onTap: () {
                                        Navigator.pop(context);
                                        pickImage(ImageSource.camera);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_album),
                                      title: const Text('gallery').tr(),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        if (Platform.isAndroid) {
                                          PermissionStatus permissionStatus =
                                              await GalleryPermission()
                                                  .galleryPermission(context);
                                          if (permissionStatus ==
                                              PermissionStatus.granted) {
                                            chooseImageFromGallery();
                                          }
                                        } else if (Platform.isIOS) {
                                          pickImage(ImageSource.gallery);
                                        }
                                      },
                                    ),
                                  ]),
                                );
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: themehandler.primaryColor,
                                ),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 18,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 45,
                ),
                Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        RegisterTextFormFieldWidget(
                          hintText: 'Enter Name',
                          prefixIcon: Icons.person,
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [
                            AutofillHints.name,
                            AutofillHints.givenName,
                            AutofillHints.familyName,
                            AutofillHints.middleName,
                            AutofillHints.nameSuffix,
                            AutofillHints.namePrefix
                          ],
                          textInputAction: TextInputAction.next,
                          validator: isNameValid,
                        ),
                        RegisterTextFormFieldWidget(
                          hintText: 'E-mail',
                          prefixIcon: Icons.email,
                          controller: emailController,
                          autofillHints: const [AutofillHints.email],
                          textCapitalization: TextCapitalization.none,
                          textInputAction: TextInputAction.next,
                          validator: isEmailValid,
                        ),
                        RegisterTextFormFieldWidget(
                          hintText: 'Password',
                          prefixIcon: Icons.remove_red_eye_rounded,
                          controller: passwordController,
                          obscure: true,
                          textCapitalization: TextCapitalization.none,
                          autofillHints: const [
                            AutofillHints.password,
                            AutofillHints.newPassword
                          ],
                          textInputAction: TextInputAction.next,
                          validator: isPasswordValid,
                        ),
                        RegisterTextFormFieldWidget(
                          hintText: 'Confirm Password',
                          prefixIcon: Icons.remove_red_eye_rounded,
                          controller: confirmController,
                          obscure: true,
                          textCapitalization: TextCapitalization.none,
                          autofillHints: const [
                            AutofillHints.password,
                            AutofillHints.newPassword
                          ],
                          textInputAction: TextInputAction.next,
                          validator: isPasswordValid,
                        ),
                        RegisterTextFormFieldWidget(
                          hintText: 'Phone Number',
                          prefixIcon: Icons.phone,
                          controller: phoneController,
                          textCapitalization: TextCapitalization.none,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          autofillHints: const [AutofillHints.telephoneNumber],
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        RegisterTextFormFieldWidget(
                          hintText: 'Youtube',
                          prefixIcon: Icons.link,
                          controller: youtubeController,
                          autofillHints: const [AutofillHints.url],
                          textCapitalization: TextCapitalization.none,
                          textInputAction: TextInputAction.next,
                        ),
                        RegisterTextFormFieldWidget(
                          hintText: 'Instagram',
                          prefixIcon: Icons.link,
                          controller: instraController,
                          autofillHints: const [AutofillHints.url],
                          textCapitalization: TextCapitalization.none,
                          textInputAction: TextInputAction.next,
                        ),
                      ].map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: e.build(context),
                        );
                      }).toList(),
                    )),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      if (nameController.text.trim().isEmpty) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      } else if (Preferences.getLoginType() == "normal" &&
                          (emailController.text.trim().isEmpty)) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      } else if (passwordController.text !=
                              passwordController.text ||
                          passwordController.text.trim().isEmpty ||
                          confirmController.text.trim().isEmpty) {
                        showToast("not_match_password".tr());
                      } else if (phoneController.text.trim().isEmpty) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      } else {
                        profileUpdateFun();
                      }
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        } else if (Preferences.getLoginType() == "normal" &&
                            (emailController.text.trim().isEmpty)) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        } else if (passwordController.text !=
                                passwordController.text ||
                            passwordController.text.trim().isEmpty ||
                            confirmController.text.trim().isEmpty) {
                          showToast("not_match_password".tr());
                        } else if (phoneController.text.trim().isEmpty) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        } else {
                          profileUpdateFun();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        'save',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                      ).tr(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);

    File? imageTempoary = File(image!.path);
    imageTempoary = await _cropImage(imageFile: imageTempoary);

    setState(() {
      if (imageTempoary != null) {
        this.image = imageTempoary;
        isnetworkimage = false;
      }
    });
  }

  void profileUpdateFun() async {
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    customProgressDialog.show();
    var headers = <String, String>{'Content-Type': 'application/json'};
    UserProfileUpdate updateReq = UserProfileUpdate(
        methodName: 'user_profile_update',
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        phone: phoneController.text,
        userYoutube: youtubeController.text,
        userInstagram: instraController.text);
    String methodBody = jsonEncode(updateReq.toJson());
    try {
      if (image != null) {
        var request =
            http.MultipartRequest('POST', Uri.parse(AppConstants.baseURL));
        request.headers.addAll(headers);
        request.fields['data'] = base64Encode(utf8.encode(methodBody));
        var file = await http.MultipartFile.fromPath('user_image', image!.path);
        request.files.add(file);

        var response = await request.send().then((value) {
          customProgressDialog.dismiss();
          return value;
        });
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(await response.stream.bytesToString());

          if (jsonResponse.containsKey(AppConstants.status)) {
            int status = jsonResponse['status'];
            String message = jsonResponse['message'];
            if (status == -2) {
              showToast(message);
            } else {
              showToast(message);
            }
          } else {
            Map<String, dynamic> data = jsonResponse[AppConstants.tag];
            String msg = data['msg'];
            showToast(msg);
          }
        }
      } else {
        http.Response response = await http.post(
          Uri.parse(AppConstants.baseURL),
          body: {'data': base64Encode(utf8.encode(methodBody))},
        ).then((value) {
          customProgressDialog.dismiss();
          return value;
        });
        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          if (jsonResponse.containsKey(AppConstants.status)) {
            int status = jsonResponse['status'];
            String message = jsonResponse['message'];
            if (status == -2) {
              showToast(message);
            } else {
              showToast(message);
            }
          } else {
            Map<String, dynamic> data = jsonResponse[AppConstants.tag];
            String msg = data['msg'];
            showToast(msg);
          }
        }
      }
    } catch (e) {
      showToast('error'.tr());
    }
  }

  Future<void> chooseImageFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        image = file;
        File? imageTempoary = image;

        imageTempoary = await _cropImage(imageFile: imageTempoary ?? File(""));

        setState(() {
          if (imageTempoary != null) {
            image = imageTempoary;
            isnetworkimage = false;
          }
        });
      } else {
        return;
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 50);

    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }
}
