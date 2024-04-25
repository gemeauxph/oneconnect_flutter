import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndvpn/core/https/servers_http.dart';
import 'package:ndvpn/core/models/api_res/about_data.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/components/custom_card.dart';
import 'package:ndvpn/ui/components/custom_circle_avatar.dart';
import 'package:ndvpn/ui/components/custom_webview.dart';
import 'package:ndvpn/ui/components/empty_widget.dart';
import 'package:ndvpn/ui/components/error_widget.dart';
import 'package:ndvpn/ui/components/shimmer_list_loading.dart';
import 'dart:core';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> {
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("about").tr(),
        ),
        body: FutureBuilder(
            future: ServersHttp(context).getAboutData(),
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
                AboutData? aboutData = snapshot.data;
                if (aboutData == null) {
                  return const EmptyWidget(
                      emptyTitle: 'empty_point',
                      emptyMessage: 'empty_point_msg');
                } else {
                  String text = formatWebText(text: aboutData.appFaq);
                  return ListView(children: [
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CustomCard(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: ListTile(
                                      leading: CustomCircleAvatar(
                                          imageUrl: aboutData.appLogo),
                                      title: Text(aboutData.appName),
                                    ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: CustomCard(
                                    child: ListTile(
                                  leading: const Icon(
                                    Icons.info_outline_rounded,
                                  ),
                                  title: const Text('Version').tr(),
                                  subtitle: Text(aboutData.appVersion),
                                )),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CustomCard(
                                      child: ListTile(
                                    leading: const Icon(Icons.business),
                                    title: const Text('Company').tr(),
                                    subtitle: Text(aboutData.appAuthor),
                                  ))),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CustomCard(
                                      child: ListTile(
                                          leading: const Icon(Icons.email),
                                          title: const Text('Email').tr(),
                                          subtitle: Text(aboutData.appEmail),
                                          onTap: () => launchEmail(
                                              appEmail: aboutData.appEmail)))),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CustomCard(
                                      child: ListTile(
                                          leading: const Icon(Icons.language),
                                          title: const Text('Website').tr(),
                                          subtitle: Text(aboutData.appWebsite),
                                          onTap: () => launchWebsite(
                                              url: aboutData.appWebsite)))),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CustomCard(
                                      child: ListTile(
                                          leading: const Icon(Icons.phone),
                                          title: const Text(
                                            'Contact',
                                          ).tr(),
                                          subtitle: Text(aboutData.appContact),
                                          onTap: () => makePhoneCall(
                                              appContact:
                                                  aboutData.appContact)))),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CustomCard(
                                      child: ListTile(
                                          title: const Text('About').tr(),
                                          subtitle: text == ''
                                              ? Container()
                                              : SizedBox(
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  child: CustomWebView(
                                                      initialHtml: text),
                                                )))),
                            ]))
                  ]);
                }
              }
            }));
  }
}
