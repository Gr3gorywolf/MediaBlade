import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

class AuthHelper {
  static Future<GoogleSignInAuthentication?> signInWithGoogle(
      {avoidRequest = false}) async {
    final googleSignIn =
        GoogleSignIn.standard(scopes: [DriveApi.driveFileScope]);
    late GoogleSignInAccount? googleAccount = null;
    var currentUser = googleSignIn.currentUser;
    if (currentUser == null && avoidRequest) {
      googleAccount = await googleSignIn.signInSilently();
    } else if (currentUser == null) {
      googleAccount = await googleSignIn.signIn();
    } else {
      googleAccount = currentUser;
    }
    if (googleAccount == null) {
      return null;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleAccount.authentication;

    return googleAuth;
  }
}
