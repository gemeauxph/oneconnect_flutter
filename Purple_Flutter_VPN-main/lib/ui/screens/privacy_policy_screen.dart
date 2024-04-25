import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndvpn/core/https/servers_http.dart';
import 'package:ndvpn/ui/components/custom_webview.dart';
import 'package:ndvpn/ui/components/empty_widget.dart';
import 'package:ndvpn/ui/components/error_widget.dart';
import 'package:ndvpn/ui/components/shimmer_list_loading.dart';
import 'dart:core';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => PrivacyPolicyScreenState();
}

class PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("privacy_policy").tr(),
        ),
        body: FutureBuilder(
            future: ServersHttp(context).getPrivacyPolicy(),
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
                String text = snapshot.data ?? '';
                if (text.isEmpty) {
                  return const EmptyWidget(
                      emptyTitle: 'empty_point',
                      emptyMessage: 'empty_point_msg');
                } else {
                  return CustomWebView(initialHtml: text);
                }
              }
            }));
  }
}
