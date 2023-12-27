import '../../../allpackages.dart';

class SignInController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  var isLoading = false.obs;

  Future<User?> handleSignIn() async {
    try {
      load(true, 'signIn');
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      print('token ---- ${credential.token}');
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      if (user != null) {
        await storeUserDetails(
            user.uid, user.displayName!, user.photoURL!, user.email!);
        Get.off(const Message());
      }

      print("User signed in: ${user!.displayName}");
      load(false, 'signIn');

      return user;
    } catch (error) {
      load(false, 'signIn');
      print("Error during Google Sign In: $error");
      return null;
    }
  }

  Future<void> storeUserDetails(
      String docId, String name, String profile, String email) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(docId).set({
        'displayName': name,
        'email': email,
        'profile': profile,
        'uid': docId
      });
    } catch (e) {
      print('store User Details Error $e');
    }
  }

  void load(isLoading, type) {
    this.isLoading.value = isLoading;
    update([type]);
  }
}
