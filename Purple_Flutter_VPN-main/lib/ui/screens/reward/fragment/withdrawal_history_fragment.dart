import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/api_req/get_req_with_userid.dart';
import 'package:ndvpn/core/models/user_redeem.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
part '../mixin/withdrawal_history_mixin.dart';

class WithdrawalHistoryFragment extends StatefulWidget {
  const WithdrawalHistoryFragment({super.key});

  @override
  State<WithdrawalHistoryFragment> createState() =>
      WithdrawalHistoryFragmentState();
}

class WithdrawalHistoryFragmentState extends State<WithdrawalHistoryFragment>
    with _WithdrawalHistoryMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: noData
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                              child: Icon(
                            Icons.not_listed_location,
                            size: 80,
                            color: Colors.blue,
                          )),
                          const SizedBox(height: 16),
                          const Text(
                            'empty_withdrawal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ).tr(),
                          const SizedBox(height: 8),
                          const Text(
                            'empty_withdrawal_msg',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ).tr(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                UserRedeem userRedeem = userRedeemLists[index];
                String status = userRedeem.status;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    child: ClipOval(
                      child: Image.asset(
                        "${AssetsPath.iconpath}logo_android.png",
                        fit: BoxFit.cover,
                        height: 125,
                        width: 125,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "User Point ${userRedeem.userPoints}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        status == "0"
                            ? "Pending"
                            : status == "1"
                                ? "Approve"
                                : "Reject",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.all(12),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            userRedeem.redeemPrice,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 14),
                          ),
                          Text(
                            userRedeem.requestDate,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xfff20056)),
                          ),
                        ],
                      ),
                      const Text('Points'),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemCount: userRedeemLists.length),
    );
  }
}
