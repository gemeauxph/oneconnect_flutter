import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/assets.dart';
import 'package:ndvpn/core/models/api_req/user_login_req.dart';
import 'package:ndvpn/core/providers/globals/iap_provider.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/resources/environment.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/forgot_password_screen/forgot_password_screen.dart';
import 'package:ndvpn/ui/screens/login_screen/widgets/google_signin_button.dart';
import 'package:ndvpn/ui/screens/main_screen.dart';
import 'package:ndvpn/ui/screens/register_screen/register_screen.dart';
part 'mixin/login_screen_mixin.dart';

final class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with _LoginScreenMixin {
  String deviceid = Preferences.getDeviceId();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: kMinInteractiveDimension),
              child: Center(
                  child: Column(
                children: [
                  FractionallySizedBox(
                      widthFactor: .35,
                      alignment: Alignment.center,
                      child: PhysicalModel(
                          color: Colors.white,
                          elevation: 5,
                          borderRadius: BorderRadius.circular(12),
                          shadowColor: secondaryShade,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(Assets.logo_png,
                                  filterQuality: FilterQuality.medium)))),
                  const SizedBox(height: 12),
                  Text(appName,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              )),
            ),
            Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    RegisterTextFormFieldWidget(
                      hintText: 'email'.tr(),
                      prefixIcon: Icons.email,
                      controller: _emailController,
                      autofillHints: const [AutofillHints.email],
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                      validator: isEmailValid,
                    ),
                    RegisterTextFormFieldWidget(
                      hintText: 'password'.tr(),
                      prefixIcon: Icons.remove_red_eye_rounded,
                      controller: _passwordController,
                      obscure: true,
                      textCapitalization: TextCapitalization.none,
                      autofillHints: const [
                        AutofillHints.password,
                        AutofillHints.newPassword
                      ],
                      textInputAction: TextInputAction.next,
                      validator: isPasswordValid,
                    ),
                  ].map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: e.build(context),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async => await login(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 42),
                    shape: const StadiumBorder(),
                  ),
                  child: Text('button_text_login',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w400))
                      .tr(),
                ),
                ElevatedButton(
                  onPressed: () async =>
                      replaceScreen(context, const MainScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 42),
                    shape: const StadiumBorder(),
                  ),
                  child: Text('button_text_skip',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w400))
                      .tr(),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                  onTap: () {
                    startScreen(context, const ForgotPasswordScreen());
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "forgot_password_question".tr(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  )),
            ),
            const SizedBox(height: 22),
            Visibility(
                visible: Config.appleOn != "1",
                child: const GoogleSignInButton()),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: GestureDetector(
                    onTap: () {
                      startScreen(context, const RegisterScreen());
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "dont_have_an_account".tr(),
                        style: Theme.of(context).textTheme.labelLarge,
                        children: [
                          TextSpan(
                            text: ' Register',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
