import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/api_req/user_reference_code.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'package:ndvpn/ui/screens/main_screen.dart';
import 'package:ndvpn/ui/screens/register_screen/register_screen.dart';
part 'mixin/enter_reference_code_mixin.dart';

class EnterReferenceCodeScreen extends StatefulWidget {
  const EnterReferenceCodeScreen({super.key});

  @override
  State<EnterReferenceCodeScreen> createState() =>
      EnterReferenceCodeScreenState();
}

class EnterReferenceCodeScreenState extends State<EnterReferenceCodeScreen>
    with _EnterReferenceCodeMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "reference_code",
        ).tr(),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SingleChildScrollView(
            child: Column(
          children: [
            Card(
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
                                  child: Image.asset(
                                      'assets/images/reference_code_enter_img.png',
                                      filterQuality: FilterQuality.medium)))),
                      const SizedBox(height: 20),
                      Text('enter_redemption_code'.tr(),
                          style: const TextStyle(
                              fontSize: 22,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Center(
                          child: Text(
                            "enter_ref_code_des".tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              RegisterTextFormFieldWidget(
                                hintText: 'Enter Code',
                                prefixIcon: Icons.qr_code,
                                controller: _codeController,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode
                                ],
                                textCapitalization: TextCapitalization.none,
                                textInputAction: TextInputAction.next,
                                validator: isCodeValid,
                              ),
                            ].map((e) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: e.build(context),
                              );
                            }).toList(),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () => redeemProcess,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffFF4081),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 32),
                                  shape: const StadiumBorder(),
                                ),
                                child: Text('redeem'.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1))
                                    .tr(),
                              ))),
                      Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () {
                                  replaceScreen(context, const MainScreen());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffDDDDDD),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 32),
                                  shape: const StadiumBorder(),
                                ),
                                child: Text('back'.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: const Color(0xff272727),
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 1,
                                        )).tr(),
                              ))),
                    ],
                  )),
            ),
          ],
        ))
      ]),
    );
  }
}
