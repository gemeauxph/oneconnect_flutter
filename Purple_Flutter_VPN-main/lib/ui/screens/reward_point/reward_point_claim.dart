import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/api_req/get_req_with_userid.dart';
import 'package:ndvpn/core/models/payment_list.dart';
import 'package:ndvpn/core/models/api_req/payment_req.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';

part 'mixin/reward_point_mixin.dart';

final class RewardPointClaim extends StatefulWidget {
  final String userPoints;
  const RewardPointClaim({super.key, required this.userPoints});

  @override
  State<RewardPointClaim> createState() => RewardPointClaimState();
}

class RewardPointClaimState extends State<RewardPointClaim>
    with _RewardPointMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("payment_detail").tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Center(
                child: const Text(
                  "claim_desc",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xff6C6C6C),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ).tr(),
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xff0D1543),
                    border: Border.all(
                        color: Theme.of(context).hintColor.withOpacity(.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: dropdownvalue,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).hintColor.withOpacity(.4),
                        ),
                        elevation: 2,
                        underline: Container(),
                        hint: SizedBox(
                          width: MediaQuery.of(context).size.width -
                              MediaQuery.of(context).size.width / 4,
                        ),
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor.withOpacity(.4)),
                        items: items.map((PaymentList item) {
                          return DropdownMenuItem(
                            value: item.id,
                            child: Text(item.modeTitle),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownvalue = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                )),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  maxLines: 4,
                  minLines: 4,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'payment_detail'.tr(),
                    contentPadding: const EdgeInsets.all(10),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).hintColor.withOpacity(.2))),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    hintStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).hintColor.withOpacity(.4)),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: ElevatedButton(
                onPressed: () => form(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff20056),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  shape: const StadiumBorder(),
                ),
                child: Text('SUBMIT',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w400)),
              ),
            )
          ],
        )),
      ),
    );
  }
}
