import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/assets.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'package:ndvpn/ui/screens/register_screen/register_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
part 'mixin/verification_mixin.dart';

class VerificationScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? password;
  final String? phoneNO;
  final String? reference;
  const VerificationScreen(
      {super.key,
      this.name,
      this.email,
      this.password,
      this.phoneNO,
      this.reference});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with _VerificationMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundDark,
        appBar: AppBar(
          title: const Text(
            "verification",
          ).tr(),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 4, 39, 91),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              height: MediaQuery.of(context).size.height / 6,
            ),
            SingleChildScrollView(
              child: SafeArea(
                  minimum: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: kMinInteractiveDimension),
                        child: Center(
                            child: Column(
                          children: [
                            Text('enter_ver_code',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w600))
                                .tr(),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 10,
                            ),
                            Image.asset(
                              Assets.otp_png,
                              filterQuality: FilterQuality.medium,
                              height: 120,
                              width: 120,
                            ),
                            const SizedBox(height: 12),
                            Text('enter_code'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent)),
                            const SizedBox(
                              height: 5,
                            ),
                            Text('already_send_otp',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey))
                                .tr(),
                            Padding(
                                padding: const EdgeInsets.only(top: 25),
                                child: SizedBox(
                                  width: 250,
                                  child: PinCodeTextField(
                                    length: 4,
                                    appContext: context,
                                    keyboardType: TextInputType.phone,
                                    controller: optController,
                                    pinTheme: PinTheme(
                                      fieldHeight: 55,
                                      fieldWidth: 55,
                                      activeColor: Colors.blue,
                                      selectedColor: Colors.greenAccent,
                                      inactiveColor: const Color(0xffC8CED8),
                                      activeFillColor: Colors.black,
                                      inactiveFillColor:
                                          const Color(0xFFEA80FC),
                                      selectedFillColor: Colors.deepPurple,
                                      shape: PinCodeFieldShape.box,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enableActiveFill: true,
                                    cursorColor: Colors.blue,
                                    onCompleted: (v) async {},
                                    onChanged: (value) {},
                                  ),
                                )),
                            // Text(Preferences.getOtp()),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 230, 211, 0),
                                        minimumSize: const Size(100, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      onPressed: vertification,
                                      child: const Text('VERIFY')),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        minimumSize: const Size(200, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        Preferences.setVerification(
                                            isVerification: false);
                                        startScreen(
                                            context, const RegisterScreen());
                                      },
                                      child: const Text('re_register').tr())
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: GestureDetector(
                                onTap: () {
                                  resendVerification();
                                },
                                child: Center(
                                  child: Text.rich(TextSpan(
                                    text: 'resend_your_otp'.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                            fontSize: 17, color: Colors.grey),
                                    children: [
                                      TextSpan(
                                        text: 'click_here'.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                color: secondaryShade,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }
}
