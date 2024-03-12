import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:template_webview/GoogleDB/GoogleDB.dart';
import 'package:template_webview/loading_utils.dart';

import 'Constant.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(MyApp());
  await Future.delayed(Duration(seconds: 2));

  FlutterNativeSplash.remove();
}

MaterialColor mainAppColor = const MaterialColor(
  0xFF89cfbe,
  <int, Color>{
    50: Colors.transparent,
    100: Colors.transparent,
    200: Colors.transparent,
    300: Colors.transparent,
    400: Colors.transparent,
    500: Colors.transparent,
    600: Colors.transparent,
    700: Colors.transparent,
    800: Colors.transparent,
    900: Colors.transparent,
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Denizcinin Kütüphanesi',
      theme: ThemeData(
          primarySwatch: mainAppColor,
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              //<-- SEE HERE
              // Status bar color
              statusBarColor: Color(0xff100e23),
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light,
            ),
          )),
      debugShowCheckedModeBanner: false,
      home: NewWidget(),
    );
  }
}

class NewWidget extends StatefulWidget {
  const NewWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  bool _confirmExit = false;
  bool _snackbarClosed = true;
  final Completer<InAppWebViewController> _inAppWebViewController =
      Completer<InAppWebViewController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _platformVersion = await InAppWebViewController.getDefaultUserAgent();

      //await FkUserAgent.init();
      //  initPlatformState();
    });
  }

  String _platformVersion =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36 OPR/84.0.4316.21';

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = FkUserAgent.userAgent!;
      print(platformVersion);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  String jwt = "";
  bool inside = false;
  bool isLoading = false;
  Future<void> goLogin() async {
    await (await _inAppWebViewController.future).loadUrl(
        urlRequest: URLRequest(
            url: WebUri(
      "https://denizcininkutuphanesi.com/sign-in/a?jwt=$jwt",
    )));
    setState(() {
      jwt = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (jwt.isNotEmpty) goLogin();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          elevation: 0,
          toolbarHeight: 0,
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (await (await _inAppWebViewController.future).canGoBack()) {
            await (await _inAppWebViewController.future).goBack();
            return Future.value(false);
          }
          if (_confirmExit && !_snackbarClosed) {
            // Kullanıcı bir kez "Evet" dedi ve SnackBar kapandı, uygulamayı kapat.
            SystemNavigator.pop();
            return true;
          } else if (!_confirmExit) {
            // Kullanıcı bir kez geri tuşuna bastı, doğrulama mesajını göster.
            _showSnackBar(context);
          }
          // Bu geri tuş olayını engelle.
          return false;
        },
        child: Padding(
          padding: MediaQuery.of(context).padding,
          child: Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Expanded(
                  child: InAppWebView(
                    androidOnPermissionRequest:
                        (InAppWebViewController controller, String origin,
                            List<String> resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                          mediaPlaybackRequiresUserGesture: true,
                          useShouldOverrideUrlLoading: true,
                          userAgent: _platformVersion),
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                        thirdPartyCookiesEnabled: true,
                      ),
                      ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: true,
                      ),
                    ),
                    initialUrlRequest: URLRequest(
                      url:
                          WebUri("https://denizcininkutuphanesi.com/dashboard"),
                    ),
                    onWebViewCreated: (controller) {
                      if (!_inAppWebViewController.isCompleted) {
                        _inAppWebViewController.complete(controller);
                      }
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      var uri = navigationAction.request.url;
                      var url = uri.toString();
                      print("here : " + url);
                      // Örnek bir URL kontrolü
                      if (inside) return NavigationActionPolicy.CANCEL;
                      if (url.contains('accounts')) {
                        setState(() {
                          inside = true;
                          isLoading = true;
                        });
                        try {
                          LoadingUtils(context).startLoading();

                          final data = await GoogleSignInApi.login();
                          final data2 = await data?.authentication;
                          if (data2 != null && data2.idToken != null) {
                            setState(() {
                              jwt = data2.idToken!;

                              isLoading = false; // End loading state
                              inside = false;
                            });

                            return NavigationActionPolicy.CANCEL;
                          }
                        } catch (error) {
                          // Handle any errors during login
                          print("Login error: $error");
                        } finally {
                          setState(() {
                            LoadingUtils(context).stopLoading();

                            inside = false;
                          });
                        }
                        return NavigationActionPolicy.CANCEL;
                      }

                      // Diğer URL'ler için varsayılan davranış
                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStart:
                        (InAppWebViewController controller, Uri? url) async {
                      print(url);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          content: Text('Çıkmak için bir daha geri tuşuna basınız.'),
          duration: Duration(seconds: 3),
        ))
        .closed
        .then((reason) {
      // SnackBar kapandığında, _snackbarClosed değerini güncelle.
      setState(() {
        _snackbarClosed = true;
        _confirmExit = false;
      });
    });

    // SnackBar gösterildiğinde, _confirmExit değerini güncelle.
    setState(() {
      _confirmExit = true;
      _snackbarClosed = false;
    });
  }
}
