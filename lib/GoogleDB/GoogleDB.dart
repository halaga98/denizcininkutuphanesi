import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = Platform.isIOS
      ? GoogleSignIn(
          serverClientId:
              "819772713097-qe9phel30qvd5q095q0coc0261avc7dv.apps.googleusercontent.com",
        )
      : GoogleSignIn(
          serverClientId:
              "819772713097-qe9phel30qvd5q095q0coc0261avc7dv.apps.googleusercontent.com",
        );

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  //
}
