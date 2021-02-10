import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User {
  User({this.uid});
  final String uid;
}

class Auth {
  Future<User> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;
      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final authResult = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          ),
        );
        return User(uid: authResult.user.uid);
      } else
        throw PlatformException(
          code: "Error_Missing Auth Token",
          message: "Missing Auth Token",
        );
    } else {
      throw PlatformException(
        code: "Error_Aborted_by_User",
        message: "Sign In Aborted",
      );
    }
  }

  Future<User> signInWithFacebook() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['public_profile']);
    if (result.accessToken != null) {
      final authResult = await FirebaseAuth.instance.signInWithCredential(
        FacebookAuthProvider.credential(
          result.accessToken.token,
        ),
      );
      return User(uid: authResult.user.uid);
    } else
      throw PlatformException(
        code: "Error_Missing Auth Token",
        message: "Missing Auth Token",
      );
  }
}

final Auth auth = Auth();
