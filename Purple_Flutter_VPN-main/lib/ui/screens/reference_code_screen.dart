import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ndvpn/core/https/servers_http.dart';
import 'package:ndvpn/ui/components/error_widget.dart';
import 'package:shimmer/shimmer.dart';

class ReferenceCodeScreen extends StatefulWidget {
  const ReferenceCodeScreen({super.key});

  @override
  State<ReferenceCodeScreen> createState() => ReferenceCodeScreenState();
}

class ReferenceCodeScreenState extends State<ReferenceCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'reference_code'.tr(),
          style: const TextStyle(
              fontSize: 20, letterSpacing: 1, fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder(
          future: ServersHttp(context).referenceCode(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("CHECKREF 1");
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: _referenceCodeWidget(userCode: 'Reference Code'),
              );
            } else if (snapshot.hasError) {
              return ErrorViewWidget(onRetry: () {
                setState(() {});
              });
            } else {
              print("CHECKREF 2 ${snapshot.data}");
              return _referenceCodeWidget(
                  userCode: snapshot.data ?? 'Reference Code');
            }
          }),
    );
  }

  Widget _referenceCodeWidget({required String userCode}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: const Text(
            'reference_title',
            style: TextStyle(
                color: Color(0xff6C6C6C),
                fontSize: 22,
                letterSpacing: 1,
                fontWeight: FontWeight.w600),
          ).tr(),
        ),
        SafeArea(
          child: Stack(
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 9,
                  child: const FractionallySizedBox(
                    heightFactor: 1.0,
                    widthFactor: 1.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/code_bg.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Column(
                    children: [
                      Text(userCode,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff424242))),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: userCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Copied successfully"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('copy',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xfff20056)))
                            .tr(),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Center(
            child: const Text(
              "reference_desc",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff6C6C6C),
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ).tr(),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.width / 2,
            width: MediaQuery.of(context).size.width / 2,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/reference_code_img.jpg"),
                  fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }
}
