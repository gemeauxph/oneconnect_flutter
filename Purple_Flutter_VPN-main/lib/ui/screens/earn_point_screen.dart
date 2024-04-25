import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndvpn/core/https/servers_http.dart';
import 'package:ndvpn/core/models/api_res/earn_point.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/components/empty_widget.dart';
import 'package:ndvpn/ui/components/error_widget.dart';
import 'package:ndvpn/ui/components/shimmer_list_loading.dart';

class EarnPointScreen extends StatefulWidget {
  const EarnPointScreen({super.key});

  @override
  State<EarnPointScreen> createState() => EarnPointScreenState();
}

class EarnPointScreenState extends State<EarnPointScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("earn_point").tr(),
      ),
      body: FutureBuilder(
          future: ServersHttp(context).rewardPoint(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ShimmerListLoadingEffect(
                count: 5,
              );
            } else if (snapshot.hasError) {
              return ErrorViewWidget(onRetry: () {
                setState(() {});
              });
            } else {
              List<EarnPoint> earnPointLists = snapshot.data ?? [];
              if (earnPointLists.isEmpty) {
                return const EmptyWidget(
                    emptyTitle: 'empty_point', emptyMessage: 'empty_point_msg');
              } else {
                return ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      EarnPoint rewardPoint = earnPointLists[index];
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
                              rewardPoint.title,
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
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemCount: earnPointLists.length);
              }
            }
          }),
    );
  }
}
