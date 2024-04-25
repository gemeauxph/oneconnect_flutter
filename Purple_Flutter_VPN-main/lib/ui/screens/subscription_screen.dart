import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/payment_gateway.dart';
import 'package:ndvpn/core/models/subscription_plan.dart';
import 'package:ndvpn/core/providers/globals/iap_provider.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/resources/environment.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/components/custom_card.dart';
import 'package:ndvpn/ui/components/custom_divider.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/providers/modules.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late IAPProvider myWidget;
  @override
  void initState() {
    myWidget = Provider.of<IAPProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: primaryGradient.colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
      ),
      child: Scaffold(
        // backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("subscription").tr(),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          actions: const [CloseButton()],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Image.asset('assets/images/background_world.png',
            //     fit: BoxFit.fitHeight, color: primaryColor),
            Consumer<IAPProvider>(
              builder: (context, value, child) {
                return Center(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Unlock Premium Servers',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'With No Ads',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              width: 240.0,
                              child: const Text(
                                'By the Premium Plan and Get Ride of Fastest Servers in the world.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...value.subscriptionItems
                          .map((e) => _subsItem(value, e)),
                      ...value.productItems.map((e) => _subsButton(value, e)),
                      if (Platform.isIOS) ...[
                        const ColumnDivider(space: 20),
                        _restoreButton(value)
                      ],
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () => value.subscriptionItem == null
                                ? null
                                : _showPaymentDialog(
                                    context: context, controller: value),
                            child: ElevatedButton(
                              onPressed: () => _showPaymentDialog(
                                  context: context, controller: value),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: value.subscriptionItem != null
                                    ? const Color(0xffff2e93)
                                    : Colors.grey,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: const StadiumBorder(),
                              ),
                              child: Text(
                                'BECOME PREMIUM NOW',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ).tr(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Text.rich(TextSpan(
                          text:
                              'Recurring Billing , Cancel Any Time on Google Play Store',
                          style: Theme.of(context).textTheme.bodySmall,
                        )),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _subsItem(IAPProvider provider, SubscriptionPlan e) {
    return CupertinoButton(
      padding: const EdgeInsets.only(bottom: 10),
      onPressed: () {
        provider.subscriptionPlan = e;
      },
      child: SizedBox(
        height: 60,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: const Color(0xFF2A3875),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  e.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '\$${e.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Radio(
                  value: e,
                  groupValue: provider.subscriptionItem,
                  onChanged: (value) {
                    // Update the selected subscription item
                    provider.subscriptionPlan = e;
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  activeColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _subsButton(IAPProvider provider, IAPItem e) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        provider.purchase(e).then((value) => provider.savePayment(""));
      },
      child: SizedBox(
        height: 100,
        child: CustomCard(
          margin: const EdgeInsets.symmetric(vertical: 5),
          showOnOverflow: false,
          child: Stack(
            children: [
              if (subscriptionIdentifier[e.productId]!["featured"])
                const Positioned(
                  right: 0,
                  child: Banner(
                    message: "featured",
                    location: BannerLocation.topEnd,
                    color: primaryColor,
                  ),
                ),
              Center(
                child: ListTile(
                  title: Text(subscriptionIdentifier[e.productId]!["name"]),
                  subtitle: Text(e.description ?? ""),
                  trailing: Text(e.localizedPrice ?? ""),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _restoreButton(IAPProvider provider) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        provider
            .restorePurchase()
            .showCustomProgressDialog(context)
            .then((value) {
          if (!(value ?? false)) {
            NAlertDialog(
              title: Text("no_restore_title".tr()),
              content: Text("no_restore_description".tr()),
              actions: [
                TextButton(
                    onPressed: () => closeScreen(context),
                    child: Text("understand".tr()))
              ],
            ).show(context);
          }
        });
      },
      child: Text("restore_purchase".tr()),
    );
  }

  _showPaymentDialog(
      {required BuildContext context, required IAPProvider controller}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Select Payment Method",
                  style: TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(
                  color: Color(0xFFEAEAEA),
                  height: 1,
                ),
                const SizedBox(height: 15),
                Visibility(
                  visible: (fetchGateway("Stripe", controller) != null) ? fetchGateway("Stripe", controller)?.status == "1" : false,
                  child: Card(
                    child: ListTile(
                      leading: Image.asset(
                        'assets/icons/stripe_logo.png',
                      ),
                      title: const Text("Stripe"),
                      trailing: const Icon(Icons.arrow_forward_ios_outlined),
                      onTap: () async {
                        if (Preferences.isLogin()) {
                          await controller.stripeMakePayment();
                          Navigator.pop(context);
                        } else {
                          showToast("no_login_msg".tr());
                        }
                      },
                    ),
                  ),

                ),
                const SizedBox(height: 8),
                Visibility(
                  visible: (fetchGateway("Revenuecat", controller) != null) ? fetchGateway("Revenuecat", controller)?.status == "1" : false,
                  child: Card(
                    child: ListTile(
                      leading: Image.asset(
                        'assets/icons/revenuecat_logo.png',
                      ),
                      title: const Text("RevenueCat"),
                      trailing: const Icon(Icons.arrow_forward_ios_outlined),
                      onTap: () async {
                        await controller.revenueCatPay();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Visibility(
                  visible: (fetchGateway("Google Play", controller) != null) ? fetchGateway("Google Play", controller)?.status == "1" : false,
                  child: _gAndApplePay(controller: controller),
                ),
              ],
            ),
          );
        });
  }

  _gAndApplePay({required IAPProvider controller}) {
    return Expanded(
      child: Column(
        children: [
          _gpayPayment(controller: controller),
          _applePayPayment(controller: controller),
        ],
      ),
    );
  }

  _applePayPayment({required IAPProvider controller}) {

    return ApplePayButton(
      height: 12.00 * 3.6,
      paymentConfiguration: PaymentConfiguration.fromJsonString(
        myWidget.createPaymentProfile(),
      ),
      paymentItems: controller.paymentItems,
      style: ApplePayButtonStyle.black,
      type: ApplePayButtonType.plain,
      margin: const EdgeInsets.only(top: 15.0),
      onPaymentResult: controller.onApplePayResult,
      loadingIndicator: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  _gpayPayment({required IAPProvider controller}) {

    return GooglePayButton(
      paymentConfiguration: PaymentConfiguration.fromJsonString(
        myWidget.createPaymentProfile(),
      ),
      paymentItems: controller.paymentItems,
      margin: const EdgeInsets.only(top: 15),
      onPaymentResult: onGooglePayResult,
      loadingIndicator: const Center(
        child: CircularProgressIndicator(),
      ),
      onPressed: () async {},
      childOnError: const Text('Google Pay is not available in this device'),
      onError: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('There was an error while trying to perform the payment'),
          ),
        );
      },
    );
  }

  PaymentGateway? fetchGateway(String gateway, IAPProvider controller) {
    try {
      return controller.gatewayItems.firstWhere((controller) => controller.name == gateway);
    } catch (e) {
      return null; //not found
    }
  }

  //Using GPAY to pay on Stripe
  Future<void> onGooglePayResult(paymentResult) async {
    Navigator.pop(context);
    if (Preferences.isLogin()) {
      try {
        debugPrint(paymentResult.toString());
        // 2. fetch Intent Client Secret from backend
        final clientSecret = await myWidget.fetchPaymentIntentClientSecret();
        print("CHECKGPAY $clientSecret");
        final token =
        paymentResult['paymentMethodData']['tokenizationData']['token'];
        final tokenJson = Map.castFrom(json.decode(token));
        debugPrint(tokenJson.toString());

        final params = stripe.PaymentMethodParams.cardFromToken(
          paymentMethodData: stripe.PaymentMethodDataCardFromToken(
            token: tokenJson['id'],
          ),
        );

        // 3. Confirm Google pay payment method
        await stripe.Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: params,
        );
        print("CHECKGPAY success");
        myWidget.savePayment("GPAY (Stripe)");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Google Pay payment succesfully completed')),
        );
      } catch (e) {
        print("CHECKGPAY error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      showToast("no_login_msg".tr());
    }
  }
}
