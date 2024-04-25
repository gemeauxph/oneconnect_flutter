import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/assets.dart';
import 'package:ndvpn/core/https/servers_http.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/resources/environment.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'package:ndvpn/ui/screens/register_screen/bloc/register_bloc.dart';
import 'package:ndvpn/ui/screens/verify_screen/verification_screen.dart';
part 'mixin/register_screen_mixin.dart';
part 'widgets/textformfield_widget.dart';

final class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with _RegisterScreenMixin {
  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterInitial) {
          // customProgressDialog.show();
        }
        if (state is VerificationSuccess) {
          customProgressDialog.dismiss();
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _phoneController.clear();
          _referenceCodeController.clear();
          Preferences.setVerification(isVerification: true);
          Preferences.setName(name: name);
          Preferences.setEmail(email: email);
          Preferences.setPassword(password: password);
          Preferences.setPhone(phoneNO: phoneNo);
          Preferences.setReference(reference: reference);
          Preferences.setOtp(verificationCode: otp);
          startScreen(
              context,
              VerificationScreen(
                name: name,
                email: email,
                password: password,
                phoneNO: phoneNo,
                reference: reference,
              ));
        }
        if (state is RegisterFail) {
          customProgressDialog.dismiss();
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _phoneController.clear();
          _referenceCodeController.clear();
          showToast(state.message);
        }
        if (state is RegisterSuccess) {
          customProgressDialog.dismiss();
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _phoneController.clear();
          _referenceCodeController.clear();
          replaceScreen(context, const LoginScreen());
        }
      },
      child: Scaffold(
          body: SingleChildScrollView(
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Create new account',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w500))),
              const SizedBox(height: 12),
              Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      RegisterTextFormFieldWidget(
                        hintText: 'Name Surname',
                        prefixIcon: Icons.person,
                        controller: _nameController,
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
                        controller: _emailController,
                        autofillHints: const [AutofillHints.email],
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.next,
                        validator: isEmailValid,
                      ),
                      RegisterTextFormFieldWidget(
                        hintText: 'Password',
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
                      RegisterTextFormFieldWidget(
                        hintText: 'Confirm Password',
                        prefixIcon: Icons.remove_red_eye_rounded,
                        controller: _confirmPasswordController,
                        obscure: true,
                        textCapitalization: TextCapitalization.none,
                        autofillHints: const [
                          AutofillHints.password,
                          AutofillHints.newPassword
                        ],
                        textInputAction: TextInputAction.next,
                        validator: isConfirmPasswordValid,
                      ),
                      RegisterTextFormFieldWidget(
                        hintText: 'Phone Number',
                        prefixIcon: Icons.phone,
                        controller: _phoneController,
                        textCapitalization: TextCapitalization.none,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        autofillHints: const [AutofillHints.telephoneNumber],
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: isPhoneValid,
                      ),
                      RegisterTextFormFieldWidget(
                        hintText: 'Reference Code',
                        prefixIcon: Icons.card_giftcard_rounded,
                        controller: _referenceCodeController,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.none,
                      ),
                    ].map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: e.build(context),
                      );
                    }).toList(),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GestureDetector(
                  onTap: () {
                    Preferences.setVerification(isVerification: false);
                    replaceScreen(context, const LoginScreen());
                  },
                  child: Center(
                    child: Text.rich(TextSpan(
                      text: 'Already have an account? ',
                      style: Theme.of(context).textTheme.labelLarge,
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async => await register(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  shape: const StadiumBorder(),
                ),
                child: Text('SUBMIT',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
