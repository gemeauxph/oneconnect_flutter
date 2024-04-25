import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/resources/environment.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/main_screen.dart';

void showRedeemDialog(
    {required String title,
    required String perks,
    required String exp,
    required String btn,
    required bool isFinish,
    required BuildContext context}) async {
  return NAlertDialog(
    blur: 10,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Icon(Icons.card_giftcard),
        Text(
          title,
          style: const TextStyle(
              color: Color(0xff0D1543),
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ).tr()
      ],
    ),
    content: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('perks').tr(),
            const SizedBox(
              width: 10,
            ),
            Text(
              perks,
              style: const TextStyle(
                  color: Color(0xff0D1543),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('valid_until').tr(),
            const SizedBox(
              width: 10,
            ),
            Text(
              exp,
              style: const TextStyle(
                  color: Color(0xff0D1543),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            )
          ],
        )
      ],
    ),
    actions: [
      SizedBox(
        height: 50,
        child: TextButton(
          onPressed: () {
            closeScreen(context);
            if (isFinish) {
              replaceScreen(context, const MainScreen());
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xff0D1543),
            backgroundColor: const Color(0xff0D1543).withOpacity(0.1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(btn),
        ),
      ),
    ],
  ).show(context);
}

void showUpdateDialog(
    {required String desc,
    required String url,
    required String status,
    required BuildContext context}) async {
  return NAlertDialog(
    blur: 10,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
            radius: 20,
            child: ClipRRect(
                child: Image.asset(
              "${AssetsPath.iconpath}logo_android.png",
              fit: BoxFit.cover,
              height: 125,
              width: 125,
            ))),
        const SizedBox(
          width: 10,
        ),
        Text(
          appName,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        )
      ],
    ),
    content: Text(desc),
    actions: [
      TextButton(
        child: const Text("Yes"),
        onPressed: () {
          launchWebsite(url: url);
          Navigator.pop(context);
        },
      ),
      Visibility(
          visible: status == "true",
          child: TextButton(
            child: const Text("No"),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
    ],
  ).show(context);
}
