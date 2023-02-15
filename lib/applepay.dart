import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart';
import 'package:mad_pay/mad_pay.dart';
// import 'package:pay/pay.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ApplePayWebview extends StatefulWidget {
  const ApplePayWebview({Key? key}) : super(key: key);

  @override
  State<ApplePayWebview> createState() => _ApplePayWebviewState();
}

class _ApplePayWebviewState extends State<ApplePayWebview> {
  WebViewController? controller;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    getPaymentDetails();
  }

  // static const _paymentItems = [
  //   PaymentItem(
  //     label: 'Total',
  //     amount: '99.99',
  //     status: PaymentItemStatus.final_price,
  //   ),
  // ];

  getPaymentDetails() async {
    String url111 =
        'https://www.natsworld.org/API/DonateNowAPI/StripePaymentIntent?payment_method_types=card&amount=120&currency=USD';

    var response11111 = await get(Uri.parse(url111));
    print('Apple Pay : ' + response11111.body);
    setState(() {});
  }

  final MadPay pay = MadPay();

  final items = [
    ApplePayCartSummaryItem.immediate(
      label: 'Product Test',
      amount: '0.01',
    )
  ];

  final AppleParameters appleParameters = AppleParameters(
    merchantIdentifier: 'merchant.com.nats.applepay',
    billingContact: Contact(
      emailAddress: 'test@test.com',
      postalAddress: PostalAddress(
        street: 's',
        city: 'c',
        state: 'st',
        postalCode: '123321',
        country: 'ct',
      ),
      name: PersonNameComponents(
        familyName: 'qwe',
        middleName: 'ewq',
        namePrefix: 'a',
        nameSuffix: 'h',
        nickname: 'test',
        phoneticRepresentation: PersonNameComponents(
          middleName: 'ewq2',
          givenName: 'rty2',
          namePrefix: 'a2',
          nameSuffix: 'h2',
          nickname: 'test2',
        ),
      ),
    ),
    shippingContact: Contact(
      emailAddress: 'test@test.com',
    ),
    merchantCapabilities: <MerchantCapabilities>[
      MerchantCapabilities.threeds,
      MerchantCapabilities.credit,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ApplePay"),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl:
                "http://app.natssambaralu.com/api-donation.html?type=IOS",
            onWebViewCreated: (WebViewController webViewController) {
              controller = webViewController;
              // _loadHtmlFromAssets();
              //print("onWebViewCreated");
            },
            javascriptMode: JavascriptMode.unrestricted,
            /* javascriptChannels: <JavascriptChannel>[
                                _toasterJavascriptChannel(context),
                              ].toSet(),
                              onPageFinished: (url) {
                                setState(() {
                                  isLoading = false;
                                });
                              },*/
            javascriptChannels:
                <JavascriptChannel>[_toasterJavascriptChannel(context)].toSet(),
            onPageFinished: (String url) {
              // ...
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'myText',
        onMessageReceived: (JavascriptMessage message) async {
          // Fluttertoast.showToast(msg: 'hi toast--${message.message}');
          // Navigator.push(context, MaterialPageRoute(builder: (context)=>ApplePayScreen()));
          // setState(() {
          //   print('hello world');
          // });
          // try {
          //   final PaymentResponse? req = await pay.processingPayment(
          //     PaymentRequest(
          //       apple: appleParameters,
          //       currencyCode: 'USD',
          //       countryCode: 'US',
          //       paymentItems: items,
          //       paymentNetworks: <PaymentNetwork>[
          //         PaymentNetwork.visa,
          //         PaymentNetwork.mastercard,
          //       ],
          //       google:
          //           GoogleParameters(gatewayMerchantId: '', gatewayName: ''),
          //     ),
          //   );
          //   setState(() {
          //     print('Try to pay:\n${req?.token}');
          //     // getPaymentDetails(15.24, "USD");
          //   });
          // } catch (e) {
          //   setState(() {
          //     print('Errror: \n$e');
          //   });
          // }

          Future<void> _handlePayPress({
            required List<ApplePayCartSummaryItem> summaryItems,
            required List<ApplePayShippingMethod> shippingMethods,
          }) async {
            try {
              // 1. fetch Intent Client Secret from backend
              final response = await fetchPaymentIntentClientSecret();
              final clientSecret = response['clientSecret'];

              // 2. Confirm apple pay payment
              await Stripe.instance.confirmPlatformPayPaymentIntent(
                clientSecret: clientSecret,
                confirmParams: PlatformPayConfirmParams.applePay(
                  applePay: ApplePayParams(
                    cartItems: items,
                    requiredShippingAddressFields: [
                      ApplePayContactFieldsType.name,
                      ApplePayContactFieldsType.postalAddress,
                      ApplePayContactFieldsType.emailAddress,
                      ApplePayContactFieldsType.phoneNumber,
                    ],
                    shippingMethods: shippingMethods,
                    merchantCountryCode: 'Es',
                    currencyCode: 'EUR',
                  ),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Apple Pay payment succesfully completed')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
              rethrow;
            }
          }


          /*Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );*/
        });
  }
  Future<Map<String, dynamic>> fetchPaymentIntentClientSecret() async {
    // final url = Uri.parse('$kApiUrl/create-payment-intent');
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
    return json.decode("");
  }
}
