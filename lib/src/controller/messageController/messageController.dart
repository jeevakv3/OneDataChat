import '../../../allpackages.dart';

class MessageController extends GetxController {
  List<UserModel> userData = [];
  var isLoading = false.obs;

  @override
  void onInit() {
    getMessageList();
    super.onInit();
  }

  Future<void> getMessageList() async {
    try {
      load(true, 'messageList');
      User? user = FirebaseAuth.instance.currentUser;
      final data = await FirebaseFirestore.instance.collection('user').get();
      userData = data.docs
          .where((element) => element.id != user!.uid)
          .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>))
          .toList();
      load(false, 'messageList');
    } catch (e) {
      load(false, 'messageList');
      print('Message List Error $e');
    }
  }

  Future<void> logout() async {
    load(true, 'messageList');
    await FirebaseAuth.instance.signOut();
    load(false, 'messageList');
    Get.offAll(SignIn());
  }

  void load(isLoading, type) {
    this.isLoading.value = isLoading;
    update([type]);
  }
}
