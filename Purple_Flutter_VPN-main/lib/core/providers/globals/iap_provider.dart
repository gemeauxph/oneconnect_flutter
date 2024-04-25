import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ndvpn/core/models/subscription_plan.dart';
import 'package:ndvpn/core/models/payment_gateway.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../models/api_req/get_req_with_userid.dart';
import '../../resources/environment.dart';
import '../flutter_inapp_purchase.dart';
import '../modules.dart';

class IAPProvider with ChangeNotifier {
  late StreamSubscription<PurchasedItem?> _subscription;

  FlutterInappPurchase get _engine => FlutterInappPurchase.instance;

  final List<IAPItem> _productItems = [];
  List<IAPItem> get productItems => _productItems;

  final List<PaymentItem> _paymentItems = [];
  List<PaymentItem> get paymentItems => _paymentItems;

  final List<PaymentGateway> _gatewayItems = [];
  List<PaymentGateway> get gatewayItems => _gatewayItems;

  final List<SubscriptionPlan> _subscriptionItems = [];
  List<SubscriptionPlan> get subscriptionItems => _subscriptionItems;

  SubscriptionPlan? _subscriptionItem;
  SubscriptionPlan? get subscriptionItem => _subscriptionItem;
  set subscriptionPlan(SubscriptionPlan item) {
    _subscriptionItem = item;
    notifyListeners();
  }

  bool _isPro = false;
  bool get isPro => _isPro;

  bool _inGracePeriod = false;
  bool get inGracePeriod => _inGracePeriod;

  Map<String, dynamic>? paymentIntentData;

  String stripeSecretKey = '';
  String stripePublicKey = '';
  String stripeCurrency = '';
  String stripeSubscriptionId = '';

  String revenueCatGoogleKey = '';
  String revenueCatAmazonKey = '';
  String revenueCatAppleKey = '';

  bool buildingForAmazon = false;

  late PurchasesConfiguration configuration;

  late String paymentProfile;

  ///Initialize IAP and handler all purchase functions
  Future initialize() {
    _loadPurchaseItems();
    _verifyPreviousPurchase();

    return _engine.initialize().then((value) async {
      _subscription = FlutterInappPurchase.purchaseUpdated
          .listen((item) => item != null ? _verifyPurchase(item) : null);
      // await _loadPurchaseItems();
      // await _verifyPreviousPurchase();
    });
  }

  Future<void> _initPlatformState() async {
    await Purchases.setDebugLogsEnabled(true);
    debugPrint("CHECKKEYS $revenueCatGoogleKey");

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(revenueCatGoogleKey);
       if (buildingForAmazon) {
        configuration = AmazonConfiguration(revenueCatAmazonKey);
       }
     } else if (Platform.isIOS) {
       configuration = PurchasesConfiguration(revenueCatAppleKey);
    } else {
      configuration = PurchasesConfiguration(revenueCatGoogleKey); //Default
    }
    await Purchases.configure(configuration);

    _checkRevenueCatSub();
  }

  Future<void> _checkRevenueCatSub() async {
    debugPrint("CHECKSUB _checkRevenueCatSub");
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      if (customerInfo == null) {
        return;
      }

      if (customerInfo.entitlements.all["pro"]!.isActive) {
        debugPrint("CHECKSUB now pro");
        Config.vipSubscription = true;
        Config.allSubscription = true;
        Config.stripeStatus = "active";
        updateProStatus();
      }
    } on PlatformException catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  Future<void> _checkStripeSub() async {
    await Preferences.init();

    try {
      ReqWithUserId req = ReqWithUserId(methodName: "get_stripe_subscription");
      String methodBody = jsonEncode(req.toJson());

      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      ).then((value) {
        return value;
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

        print("CHECKSUB ${response.body}");

        final data = jsonMap[AppConstants.tag];
        String success = "${data['success']}";

        if (success == '1') {
          String stripeJson = data["stripe"];

          if (stripeJson != "") {
            Map<String, dynamic> stripeObject = jsonDecode(stripeJson);
            Config.stripeJson = data["stripe"];

            if (stripeObject["status"] == "active") {
              Config.stripeRenewDate =
                  stripeObject["current_period_end"].toString();
              Config.vipSubscription = true;
              Config.allSubscription = true;
              Config.stripeStatus = "active";
              updateProStatus();
            }
          }
        }
      }
    } on PlatformException catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  Future<void> _fetchOneConnect() async {
    final url = Uri.parse('${trueendpoint}oneConnect');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        AppConstants.isOneConnect = (jsonMap['one_connect'].toString() == '1');
        AppConstants.oneConnectKey = jsonMap['one_connect_key'];
        AppConstants.oneConnectKey2 = jsonMap['one_connect_key_2'];
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception: $e');
    }
  }

  // Future _fetchStripeSecretKey() async {
  //   try {
  //     http.Response response = await http.get(
  //       Uri.parse('${AppConstants.apiUrl}?stripe_secret_key'),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> data = json.decode(response.body);
  //       stripeSecretKey = data['stripe_secret_key'];
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }
  //
  // Future _fetchStripePublicKey() async {
  //   print("CHECKKEY START");
  //   try {
  //     http.Response response = await http.get(
  //       Uri.parse('${AppConstants.apiUrl}?stripe_public_key'),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> data = json.decode(response.body);
  //       stripePublicKey = data['stripe_public_key'];
  //       print("CHECKKEY $stripePublicKey");
  //       Preferences.setPublicStripeKey(stripeKey: stripePublicKey);
  //     }
  //   } catch (e) {
  //     print("CHECKKEY ERROR");
  //     print("Error: $e");
  //   }
  // }

  Future _fetchSubscription() async {
    try {
      http.Response response = await http.get(
        Uri.parse('${AppConstants.apiUrl}?get_subscription'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        Map<String, dynamic> set = data['set'];
        dynamic subObject = set['sub'];
        dynamic pmObject = set['pm'];

        if (subObject is Map<String, dynamic>) {
          subObject = [subObject];
        }

        if (pmObject is Map<String, dynamic>) {
          pmObject = [pmObject];
        }

        List object = subObject;
        Map<String, dynamic> itemMap = object.first;

        _subscriptionItems.clear();
        for (String key in itemMap.keys) {
          SubscriptionPlan plan = SubscriptionPlan.fromJson(itemMap[key]);
          PaymentItem paymentItem = PaymentItem(
              amount: plan.price,
              label: plan.name,
              status: PaymentItemStatus.final_price);
          _subscriptionItems.add(plan);
          _paymentItems.add(paymentItem);
          subscriptionIdentifier[plan.productId] = {
            "name": plan.name,
            "price": plan.price,
            "currency": plan.currency,
            "status": plan.status,
          };
        }

        List object2 = pmObject;
        Map<String, dynamic> itemMap2 = object2.first;

        for (String key in itemMap2.keys) {
          PaymentGateway paymentMethod = PaymentGateway.fromJson(itemMap2[key]);
          _gatewayItems.add(paymentMethod);

          if(paymentMethod.name == "Stripe") {
            stripeSecretKey = paymentMethod.privateKey;
            stripePublicKey = paymentMethod.publicKey;
            stripeCurrency= paymentMethod.currency;
            Preferences.setPublicStripeKey(stripeKey: stripePublicKey);

            Stripe.publishableKey = stripePublicKey;
            Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
            Stripe.urlScheme = 'flutterstripe';
            await Stripe.instance.applySettings();

            debugPrint("CHECKKEYS $stripeSecretKey");
          } else if (paymentMethod.name == "Revenuecat") {
            //The keys are not actually public keys or private keys, but just a holder for the 3 keys needed for revenuecat
            revenueCatGoogleKey = paymentMethod.publicKey;
            revenueCatAmazonKey = paymentMethod.otherKey;
            revenueCatAppleKey = paymentMethod.privateKey;
          }
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    _initPlatformState();
  }

  Future<void> revenueCatPay() async {
    try {
      if (subscriptionItem != null) {
        await Purchases.setDebugLogsEnabled(true);
        await Purchases.configure(configuration);

        // Fetch offerings from RevenueCat
        Offerings offerings;

        try {
          offerings = await Purchases.getOfferings();
          if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
            debugPrint("CHECKREVENUE ${offerings.all}");
            try {
              offerings = await Purchases.getOfferings();
              if (offerings.current != null) {
                // Extract the products from the current offering
                List<Package> packages = offerings.current!.availablePackages;
                debugPrint("CHECKREVENUE size: ${packages.length}");
                var id = 0;
                for (var entry in packages.asMap().entries) {
                  debugPrint("CHECKREVENUE ${entry.value.identifier}");
                  Package package = entry.value;
                  if (package.identifier == subscriptionItem?.revenueCatId) {
                    id = entry.key;
                  }
                }

                try {
                  CustomerInfo customerInfo = await Purchases.purchasePackage(packages[id]);
                  if (customerInfo.entitlements.all["pro"]!.isActive) {
                    debugPrint("CHECKREVENUE you are pro");
                    savePayment("Revenuecat");
                  }
                } on PlatformException catch (e) {
                  var errorCode = PurchasesErrorHelper.getErrorCode(e);
                  if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
                    debugPrint("Error: $e");
                  }
                }

              } else {
                // Handle the case where there is no current offering
                debugPrint('No current offering available');
              }
            } catch (e) {
              debugPrint('Error fetching offerings: $e');
            }
          }
        } on PlatformException catch (e) {
          // optional error handling
        }
      } else {
        showToast('choose_one_item'.tr());
      }
    } catch (e, s) {
      debugPrint("After payment intent Error: ${e.toString()}");
      debugPrint("After payment intent s Error: ${s.toString()}");
    }
  }

  //For GPAY stripe
  Future<String> fetchPaymentIntentClientSecret() async {

    if (subscriptionItem != null) {

      Map<String, String> headers = {
        "Content-Type": "application/x-www-form-urlencoded",
      };

      Map<String, String> body = {
        "name": Preferences.getName(),
        "email": Preferences.getEmail(),
        "product_id": _subscriptionItem!.stripeProductId,
        "product_name": _subscriptionItem!.name,
      };

      try {
        var response = await http.post(
          Uri.parse("${AppConstants.url}includes/stripe_api.php"),
          headers: headers,
          body: body,
        );

        if (response.statusCode == 200) {
          print("CHECKRESPONSE ${response.body}");

          final jsonMap = json.decode(response.body);

          stripeSubscriptionId = jsonMap['subscriptionId'];

          return jsonMap['paymentIntent'];
        } else {
          print("CHECKRESPONSE error ${response.body}");
          return "";
        }
      } catch (error) {
        print("CHECKRESPONSE $error");
        return "";
      }
    }

    return "";

    // final url = Uri.parse('https://api.stripe.com/v1/create-payment-intent');
    // final response = await http.post(
    //   url,
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    //   body: json.encode({
    //     'email': 'example@gmail.com',
    //     'currency': 'usd',
    //     'items': ['id-1'],
    //     'request_three_d_secure': 'any',
    //   }),
    // );
    // return json.decode(response.body);
  }

  String createPaymentProfile() {
    return '''
    {
      "provider": "google_pay",
      "data": {
        "environment": "TEST",
        "apiVersion": 2,
        "apiVersionMinor": 0,
        "allowedPaymentMethods": [
          {
            "type": "CARD",
            "tokenizationSpecification": {
              "type": "PAYMENT_GATEWAY",
              "parameters": {
                "gateway": "stripe",
                "stripe:version": "2020-08-27",
                "stripe:publishableKey": "$stripePublicKey"
              }
            },
            "parameters": {
              "allowedCardNetworks": ["VISA", "MASTERCARD"],
              "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
              "billingAddressRequired": true,
              "billingAddressParameters": {
                "format": "FULL",
                "phoneNumberRequired": true
              }
            }
          }
        ],
        "merchantInfo": {
          "merchantId": "01234567890123456789",
          "merchantName": "Example Merchant Name"
        },
        "transactionInfo": {
          "countryCode": "US",
          "currencyCode": "USD"
        }
      }
    }
    ''';
  }

  void savePayment(String type) async {

    Config.vipSubscription = true;
    Config.allSubscription = true;
    Config.stripeStatus = "active";
    updateProStatus();
    updateProStatus();

    try {
      final uri = Uri.parse(AppConstants.apiUrl);
      await Preferences.init();
      var queryParameters = {
        'payment_method': type,
        'product_id': _subscriptionItem!.productId,
        'user_id': "91",
        'method_name': 'savePayment',
      };

      print("CHECKGPAY $queryParameters");

      if (type == "Stripe" || type == "GPAY (Stripe)") {
        queryParameters['stripe_subscription_id'] = stripeSubscriptionId;
      }

      final response = await http.get(uri.replace(queryParameters: queryParameters));

      if (response.statusCode == 200) {
        print("SAVEPAYMENT 200 = ${response.body}");
        // customProgressDialog.dismiss();
      } else {
        print("SAVEPAYMENT error");
        // customProgressDialog.dismiss();
      }
    } catch (error) {
      print("SAVEPAYMENT $error");
      // customProgressDialog.dismiss();
    }
  }

  calculate(String amount) {
    final a = (double.parse(amount).toInt()) * 100;
    return a.toString();
  }

  // void onGooglePayResult(paymentResult) {
  //   debugPrint(paymentResult.toString());
  // }

  void onApplePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }

  ///Load purchased item, in this case subscription
  Future _loadPurchaseItems() async {
    await _fetchOneConnect();
    await _fetchSubscription();
    await _checkStripeSub();
    // await _fetchStripeSecretKey();
    // await _fetchStripePublicKey();
    return _engine
        .getSubscriptions(subscriptionIdentifier.keys.toList())
        .then((value) {
      if (value.isNotEmpty) {
        productItems.addAll(value);
      }
    });
  }

  ///Verify previous purchase, so you'll know if subscription still occurs
  Future _verifyPreviousPurchase() async {
    return _engine.getAvailablePurchases().then((value) async {
      for (var item in value ?? []) {
        await _verifyPurchase(item);
      }
    });
  }

  ///Verify the purchase that made
  Future<bool> _verifyPurchase(PurchasedItem item) async {
    if (Platform.isAndroid) {
      if (item.purchaseStateAndroid == PurchaseState.purchased) {
        if (item.productId != null) {
          _isPro =
              _productItems.map((e) => e.productId).contains(item.productId);
        }
      }
    } else {
      if (item.transactionStateIOS == TransactionState.purchased ||
          item.transactionStateIOS == TransactionState.restored) {
        if (item.productId != null) {
          _isPro = await _engine.checkSubscribed(
            sku: item.productId!,
            duration: subscriptionIdentifier[item.productId!]?["duration"] ??
                Duration.zero,
            grace: subscriptionIdentifier[item.productId!]?["grace_period"] ??
                Duration.zero,
          );
        }
      }
    }

    if (item.transactionDate != null) {
      var different = DateTime.now().difference(item.transactionDate!);
      var subbscriptionDuration =
          subscriptionIdentifier[item.productId!]?["duration"] ?? Duration.zero;
      var graceDuration = subscriptionIdentifier[item.productId!]
              ?["grace_period"] ??
          Duration.zero;
      if (different.inDays > subbscriptionDuration.inDays &&
          different.inDays <
              (subbscriptionDuration.inDays + graceDuration.inDays)) {
        _inGracePeriod = true;
      }
    }
    notifyListeners();
    return _isPro;
  }

  ///Purchasing items
  Future purchase(IAPItem item) {
    return _engine.requestPurchase(item.productId!);
  }

  // Future purchase(IAPItem item) {
  //   return _engine.requestPurchase(item.productId!,
  //       offerTokenAndroid: item.subscriptionOffersAndroid?.first.offerToken);
  // }

  Future<bool> restorePurchase() {
    return _engine.getAvailablePurchases().then((value) async {
      if (value?.isNotEmpty ?? false) {
        for (var element in value!) {
          await _verifyPurchase(element);
        }
        return true;
      }
      return false;
    });
  }

  void updateProStatus() {
    _isPro = (Config.vipSubscription && Config.allSubscription) ||
        Config.noAds ||
        Config.isPremium;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Map<String, dynamic>? paymentIntent;

  Future<void> stripeMakePayment() async {

    if (subscriptionItem != null) {

      Map<String, String> headers = {
        "Content-Type": "application/x-www-form-urlencoded",
      };

      Map<String, String> body = {
        "name": Preferences.getName(),
        "email": Preferences.getEmail(),
        "product_id": _subscriptionItem!.stripeProductId,
        "product_name": _subscriptionItem!.name,
      };

      try {
        var response = await http.post(
          Uri.parse("${AppConstants.url}includes/stripe_api.php"),
          headers: headers,
          body: body,
        );

        if (response.statusCode == 200) {
          print("CHECKRESPONSE ${response.body}");

          final jsonMap = json.decode(response.body);

          stripeSubscriptionId = jsonMap['subscriptionId'];

          await Stripe.instance
              .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  billingDetails: BillingDetails(
                      name: Preferences.getName(),
                      email:  Preferences.getEmail(),
                      phone:  Preferences.getPhoneNo(),
                      address: Address(
                          city: 'YOUR CITY',
                          country: 'India',
                          line1: 'YOUR ADDRESS 1',
                          line2: 'YOUR ADDRESS 2',
                          postalCode: '123456',
                          state: 'YOUR STATE')),
                  paymentIntentClientSecret: jsonMap['paymentIntent'], //Gotten from payment intent
                  style: ThemeMode.dark,
                  merchantDisplayName: 'VPN'))
              .then((value) {});

          //STEP 3: Display Payment sheet
          displayPaymentSheet();
        } else {
          print("CHECKRESPONSE error ${response.body}");
        }
      } catch (error) {
        print("CHECKRESPONSE $error");
      }
    }
  }

  displayPaymentSheet() async {
    try {
      // 3. display the payment sheet.
      await Stripe.instance.presentPaymentSheet();

      debugPrint('STRIPE Payment succesfully completed');
      showToast('payment_success'.tr());
      savePayment("Stripe");
    } on Exception catch (e) {
      if (e is StripeException) {
        debugPrint('STRIPE Error from Stripe: ${e.error.localizedMessage}');
      } else {
        debugPrint('STRIPE Unforeseen error: ${e}');
      }
    }
  }

//create Payment
  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculate(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

//calculate Amount
  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }


  static IAPProvider read(BuildContext context) => context.read();
  static IAPProvider watch(BuildContext context) => context.read();
}
