import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/api_req/get_req_with_userid.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'package:ndvpn/ui/screens/reward/fragment/reward_current_fragment.dart';
import 'package:ndvpn/ui/screens/reward/fragment/withdrawal_history_fragment.dart';
import 'package:ndvpn/ui/screens/reward_point/reward_point_claim.dart';
part 'mixin/reward_mixin.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => RewardScreenState();
}

class RewardScreenState extends State<RewardScreen>
    with _RewardScreenMixin, TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("reward").tr(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 15),
              child: Text(
                'total_point_msg',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ).tr(namedArgs: {"total": totalPoint})),
          Text(
            money,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 5, vertical: 5),
            child: ElevatedButton(
              onPressed: () async => await rewardPointClaim(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff69D54B),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                shape: const StadiumBorder(),
              ),
              child: Text('reward_point_claim',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.background,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600))
                  .tr(),
            ),
          ),
          Expanded(
              child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    body: NestedScrollView(
                        headerSliverBuilder: (context, innnerBoxisScrolled) => [
                              SliverAppBar(
                                backgroundColor: Colors.transparent,
                                floating: true,
                                pinned: true,
                                automaticallyImplyLeading: false,
                                forceElevated: innnerBoxisScrolled,
                                bottom: PreferredSize(
                                    preferredSize: const Size.fromHeight(30),
                                    child: _rewardTab()),
                              )
                            ],
                        body: const ExtendedTabBarView(children: [
                          RewardCurrentFragment(),
                          WithdrawalHistoryFragment()
                        ])),
                  )))
        ],
      ),
    );
  }

  Widget _rewardTab() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.3),
          borderRadius: BorderRadius.circular(20)),
      child: TabBar(
          splashBorderRadius: BorderRadius.circular(20),
          indicatorColor: Colors.white,
          indicator: BoxDecoration(
              color: Colors.grey.shade100.withOpacity(.4),
              borderRadius: BorderRadius.circular(20)),
          tabs: [
            Tab(text: 'current_point'.tr()),
            Tab(text: 'withdrawal_history'.tr()),
          ]),
    );
  }
}
