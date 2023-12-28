import '../../../allpackages.dart';

class MediaFileSend extends StatefulWidget {
  File imageOrVideo;
  bool isVideo;
  String userId;
  MediaFileSend(
      {required this.imageOrVideo,
      required this.isVideo,
      required this.userId});

  @override
  State<MediaFileSend> createState() => _MediaFileSendState();
}

class _MediaFileSendState extends State<MediaFileSend> {
  late VideoPlayerController videoPlayerController;
  late Future<void> initilizeVideoPlayerFuture;

  String imageUrl = '';
  String videoDownLoad = '';

  final controller = Get.put(ChatController());

  TextEditingController contentController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network('');
    initilizeVideoPlayerFuture = videoPlayerController.initialize();
    pickImageVideo();
  }

  void pickImageVideo() async {
    isLoading = true;
    if (widget.imageOrVideo != null && widget.isVideo == false) {
      var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('$timestamp.jpg');
      final taskSnapshot = await storageRef.putFile(widget.imageOrVideo);
      imageUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
      });
      print('image Url---$imageUrl');
    } else {
      isLoading = true;
      var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      const maxSize = 7 * 1024 * 1024;
      if (widget.imageOrVideo.lengthSync() > maxSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ColorConstant.redColor,
            content: const Text('Video size exceeds the limit (7MB).'),
          ),
        );
        return;
      }
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('video').child('$timestamp.mp4');
      await storageRef.putFile(widget.imageOrVideo);
      videoDownLoad = await storageRef.getDownloadURL();
      if (videoDownLoad != '') {
        videoPlayerController = VideoPlayerController.network(videoDownLoad);
        initilizeVideoPlayerFuture = videoPlayerController.initialize();
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.isVideo && isLoading == false) {
      videoPlayerController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.purple,
        centerTitle: true,
        title: CommonText(
          title: 'Send To',
          color: ColorConstant.whiteColor,
          fontSize: 20,
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          widget.isVideo == true
              ? isLoading == false
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          if (videoPlayerController.value.isPlaying) {
                            videoPlayerController.pause();
                          } else {
                            videoPlayerController.play();
                          }
                        });
                      },
                      child: Center(
                        child: FutureBuilder(
                            future: initilizeVideoPlayerFuture,
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: AspectRatio(
                                    aspectRatio: 0.75,
                                    child: VideoPlayer(videoPlayerController),
                                  ),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    )
              : isLoading
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Expanded(
                      child: Image.network(imageUrl),
                    ),
          isLoading
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        color: ColorConstant.whiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type message',
                                hintStyle:
                                    TextStyle(color: ColorConstant.greyColor)),
                          )),
                          IconButton(
                              onPressed: () async {
                                controller.sendMessage(contentController.text,
                                    widget.userId, imageUrl, videoDownLoad);
                                Get.back();
                              },
                              icon: Icon(
                                Icons.send,
                                color: ColorConstant.purple,
                              ))
                        ],
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
