import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/https/servers_http.dart';
import 'package:ndvpn/core/models/purchase_history.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/components/custom_card.dart';
import 'package:ndvpn/ui/components/empty_widget.dart';
import 'package:ndvpn/ui/components/error_widget.dart';
import 'package:ndvpn/ui/components/shimmer_list_loading.dart';
import 'package:ndvpn/ui/screens/edit_profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = Preferences.getName();
  String email = Preferences.getEmail();
  String phone = Preferences.getPhoneNo();
  String userImage = Preferences.getUserImage();
  String accountType = "Free";
  String tvRenewDate = "";

  @override
  void initState() {
    setRenewDate();
    callData();
    super.initState();
  }

  callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        ServersHttp(context).getProfile().then((value) {
          accountType = value;
          if (accountType == "Premium") {
            setRenewDate();
          }
          setState(() {});
        });
      }
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  void setRenewDate() {
    if (Config.stripeRenewDate.isEmpty) {
      return;
    }
    int unixSeconds = int.parse(Config.stripeRenewDate);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
    var formatter = DateFormat('yyyy-MM-dd', 'en_US');
    tvRenewDate = formatter.format(date);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('profile').tr(),
        ),
        body: Column(
          children: [
            Card(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            startScreen(context, const EditProfileScreen())
                                .then((value) {
                              name = value.name;
                              email = value.email;
                              setState(() {});
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      border: Border.all(
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: userImage == ''
                                            ? Image.asset(
                                                "${AssetsPath.imagepath}user2.jpg",
                                                fit: BoxFit.cover,
                                                height: 120,
                                                width: 120,
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: userImage,
                                                placeholder: (context, url) =>
                                                    Image.asset(
                                                  "${AssetsPath.imagepath}user2.jpg",
                                                  fit: BoxFit.cover,
                                                  height: 120,
                                                  width: 120,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  "${AssetsPath.imagepath}user2.jpg",
                                                  fit: BoxFit.cover,
                                                  height: 120,
                                                  width: 120,
                                                ),
                                                height: 120,
                                                width: 120,
                                              ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      top: 5,
                                      right: -3,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryColor,
                                          border:
                                              Border.all(color: Colors.white),
                                        ),
                                        child: const Icon(Icons.edit,
                                            color: Colors.white, size: 12),
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 5),
                            Text(email,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('account_type',
                                style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w400))
                            .tr(),
                        Text(
                            Config.vipSubscription &&
                                    Config.allSubscription
                                ? 'Premium'
                                : 'Free',
                            style: const TextStyle(
                                fontSize: 16,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                    Visibility(
                        visible: tvRenewDate.isNotEmpty,
                        child: const SizedBox(
                          height: 15,
                        )),
                    Visibility(
                        visible: tvRenewDate.isNotEmpty,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('renew_on',
                                    style: TextStyle(
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w400))
                                .tr(),
                             Text((Config.stripeRenewDate != "") ? formatUnixTimestamp(int.parse(Config.stripeRenewDate)) : "",
                                style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600))
                          ],
                        )),
                    Visibility(
                        visible: Config.allSubscription &&
                            Config.premiumServersAccess,
                        child: const SizedBox(
                          height: 20,
                        )),
                    Visibility(
                        visible: Config.allSubscription &&
                            Config.premiumServersAccess,
                        child: InkWell(
                          onTap: () => _cancelClick(),
                          child: Container(
                            width: double.infinity,
                            height: 45,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text('cancel_subscription',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: const Color(0xffDDDDDD),
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                      )).tr(),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('purchase_history',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600))
                      .tr()
                ],
              ),
            ),
            FutureBuilder(
                future: ServersHttp(context).fetchPurchaseHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ShimmerListLoadingEffect(
                      count: 3,
                    );
                  } else if (snapshot.hasError) {
                    return ErrorViewWidget(onRetry: () {
                      setState(() {});
                    });
                  } else {
                    List<PurchaseHistory> earnPointLists = snapshot.data ?? [];
                    if (earnPointLists.isEmpty) {
                      return Card(
                          color: Theme.of(context).cardColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: const EdgeInsets.all(8.0),
                          child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: EmptyWidget(
                                  emptyTitle: 'no_purchase',
                                  emptyMessage: 'no_purchase_msg')));
                    } else {
                      return Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              PurchaseHistory rewardPoint =
                                  earnPointLists[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: CustomCard(
                                  child: ListTile(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            rewardPoint.type,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12),
                                            child: Text(
                                              rewardPoint.amount,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                      subtitle: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          rewardPoint.createDate,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: const EdgeInsets.only(
                                          left: 5, right: 5)),
                                ),
                              );
                            },
                            shrinkWrap: true,
                            itemCount: earnPointLists.length),
                      ));
                    }
                  }
                })
          ],
        ));
  }

  void _cancelClick() async {
    return NAlertDialog(
      blur: 10,
      title: const Text("confirm_cancellation").tr(),
      content: const Text("confirm_cancellation_msg").tr(),
      actions: [
        TextButton(
          child: const Text("Yes"),
          onPressed: () {
            ServersHttp(context).cancelStripeSubscription().then((value) {
              if (value == "success") {
                tvRenewDate = "";
                setState(() {});
              }
            });
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text("No"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ).show(context);
  }

  String formatUnixTimestamp(int unixTimestamp) {
    // Convert to DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

    // Format the DateTime as yyyy/mm/dd
    String formattedDate = DateFormat('yyyy/MM/dd').format(dateTime);

    return formattedDate;
  }


}
