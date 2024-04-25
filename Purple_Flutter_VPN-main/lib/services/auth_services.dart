import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ndvpn/core/models/login_model.dart';
import 'package:ndvpn/core/models/user_data.dart';
import 'package:ndvpn/core/utils/constant.dart';

class AuthService {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<LoginResponse?> signInWithGoogle(BuildContext context) async {
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User user = authResult.user!;

      assert(!user.isAnonymous);

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      await googleSignIn.signOut();

      String firstName = '';
      String lastName = '';
      if (currentUser.displayName!.split(' ').isNotEmpty) {
        firstName = currentUser.displayName!;
      }
      if (currentUser.displayName!.split(' ').length >= 2) {
        lastName = currentUser.displayName!;
      }

      UserData tempUserData = UserData()
        ..contactNumber = currentUser.phoneNumber
        ..email = currentUser.email
        ..firstName = firstName
        ..lastName = lastName
        ..profileImage = currentUser.photoURL
        ..socialImage = currentUser.photoURL
        ..loginType = AppConstants.LOGIN_TYPE_GOOGLE
        ..uid = user.uid
        ..username = (currentUser.email!.replaceAll('.', '')).toLowerCase();
      return LoginResponse(
          userData: tempUserData,
          isUserExist: false,
          status: true,
          message: 'success');
    } else {
      throw AppConstants.USER_NOT_CREATED;
    }
  }
}
