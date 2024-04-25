import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndvpn/core/models/api_req/get_req_with_userid.dart';
import 'package:ndvpn/core/models/reward_point.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
part '../mixin/reward_current_mixin.dart';

class RewardCurrentFragment extends StatefulWidget {
  const RewardCurrentFragment({super.key});

  @override
  State<RewardCurrentFragment> createState() => RewardCurrentFragmentState();
}

class RewardCurrentFragmentState extends State<RewardCurrentFragment>
    with _RewardCurrentMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: noData
          ? Center(
              child: Column(
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
                            'empty_point',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ).tr(),
                          const SizedBox(height: 8),
                          const Text(
                            'empty_point_msg',
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
                RewardPoint rewardPoint = rewardPointLists[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: rewardPoint.statusThumbnail,
                        placeholder: (context, url) => Image.asset(
                          "${AssetsPath.iconpath}logo_android.png",
                          fit: BoxFit.cover,
                          height: 125,
                          width: 125,
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          "${AssetsPath.iconpath}logo_android.png",
                          fit: BoxFit.cover,
                          height: 125,
                          width: 125,
                        ),
                        imageBuilder: (context, imageProvider) => Container(
                          height: 125,
                          width: 125,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        height: 125,
                        width: 125,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rewardPoint.title == " "
                            ? rewardPoint.title
                            : rewardPoint.activityType,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          rewardPoint.points,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
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
                            "${rewardPoint.date} - ${rewardPoint.time}",
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 14),
                          ),
                          Text(
                            rewardPoint.activityType,
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
              itemCount: rewardPointLists.length),
    );
  }
}
