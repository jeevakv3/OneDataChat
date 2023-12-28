import '../../allpackages.dart';

class ChatModel {
  final String idFrom;
  final String idTo;
  final String content;
  String imageUrl;
  String videoUrl;
  final int timestamp;
  final int left;

  ChatModel(
      {required this.idFrom,
      required this.idTo,
      required this.content,
      required this.timestamp,
      required this.left,
      required this.imageUrl,
      required this.videoUrl});

  Map<String, dynamic> toMap() {
    return {
      'idFrom': idFrom,
      'IdTo': idTo,
      'content': content,
      'timestamp': timestamp,
      'left': left,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
        idFrom: map['idFrom'],
        idTo: map['IdTo'],
        content: map['content'],
        timestamp: map['timestamp'],
        left: map['left'],
        imageUrl: map['imageUrl'],
        videoUrl: map['videoUrl']);
  }
}
