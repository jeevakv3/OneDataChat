import 'package:onedatachat/src/model/chatModel.dart';

import '../../../allpackages.dart';

class ChatController extends GetxController {
  RxList<ChatModel> chatData = <ChatModel>[].obs;
  Query<ChatModel>? chatRef;
  Future<void> sendMessage(
      String content, String userId, String imageUrl, String videoUrl) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String gropId = userId;
      await FirebaseFirestore.instance.collection('message').add({
        'idFrom': user!.uid,
        'IdTo': userId,
        'content': content,
        'imageUrl': imageUrl != null ? imageUrl : '',
        'videoUrl': videoUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'left': 0,
      });
      // await FirebaseFirestore.instance.runTransaction((transaction) async {
      //   transaction.set(documentReference, {
      //
      //   });
      // });

      //.set({

      // });
    } catch (e) {
      print('Store Chat Content Details Error $e');
    }
  }

  Future<void> getMessageData(String userId) async {
    User? user = FirebaseAuth.instance.currentUser;
    String gropId = userId;
    FirebaseFirestore.instance
        .collection('message')
        .where('idFrom', isEqualTo: user!.uid)
        .where('IdTo', isEqualTo: userId)
        .orderBy('timestamp')
        .withConverter<ChatModel>(
          fromFirestore: (snapshots, _) => ChatModel.fromMap(snapshots.data()!),
          toFirestore: (movie, _) => movie.toMap(),
        );
  }
}
