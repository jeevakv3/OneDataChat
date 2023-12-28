import '../../../allpackages.dart';
import '../../model/chatModel.dart';

class ChatScreen extends StatefulWidget {
  UserModel userData;
  ChatScreen({required this.userData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = Get.put(ChatController());
  late VideoPlayerController videoPlayerController;
  late Future<void> initilizeVideoPlayerFuture;

  File? imageuser;
  File? videoFile;
  String imageUrl = '';
  String videoDownLoad = '';

  TextEditingController chatController = TextEditingController();

  Future<void> imagePick() async {
    final picker = ImagePicker();
    XFile? result = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxHeight: 400,
      maxWidth: 400,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorConstant.redColor,
        content: const Text('Please wait few seconds Image is Loading'),
      ),
    );
    imageuser = File(result!.path);
    if (imageuser != null) {
      Get.to(MediaFileSend(
        imageOrVideo: imageuser!,
        isVideo: false,
        userId: widget.userData.uid,
      ));
    }
    setState(() {});
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final pickerFile = await picker.pickVideo(source: ImageSource.gallery);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorConstant.redColor,
        content: const Text('Please wait few seconds Video is Loading'),
      ),
    );
    videoFile = File(pickerFile!.path);
    if (videoFile != null) {
      Get.to(MediaFileSend(
        imageOrVideo: videoFile!,
        isVideo: true,
        userId: widget.userData.uid,
      ));
    }
  }

  final TextEditingController roomController = TextEditingController();

  void showJoinMeetingDialog(
      String title, BuildContext context, bool isVideoCall) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: roomController,
            decoration: const InputDecoration(labelText: "Enter Room Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (await requestPermissions()) {
                  if (roomController.text.isNotEmpty) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MeetRoom(
                              roomName: roomController.text,
                              isVideoCall: isVideoCall ? true : false,
                              profileUrl: widget.userData.profile,
                              displayName: widget.userData.displayName)),
                    );
                    await controller.sendMessage('Please Join The call',
                        widget.userData.uid, imageUrl, videoDownLoad);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: ColorConstant.redColor,
                        content: Text('Please Enter Room Name'),
                      ),
                    );
                  }
                }
              },
              child: Text("Join"),
            ),
          ],
        );
      },
    );
  }

  // Future<void> initializeAgora() async {
  //   RtcEngine rtcEngine = await RtcEngine.createWithContext()
  //
  //
  //   RtcEngineContext context = RtcEngineContext(
  //     appId: 'cbe2be175fdb4726ba1f60cdfc6240d7',
  //     channelProfile: ChannelProfileType.channelProfileCommunication,
  //     audioScenario: AudioScenarioType.audioScenarioDefault,
  //     areaCode: AreaCode.values[0].index,
  //     logConfig:
  //         const LogConfig(fileSizeInKB: 1024, level: LogLevel.logLevelInfo),
  //     threadPriority: ThreadPriorityType.high,
  //     useExternalEglContext: false,
  //     autoRegisterAgoraExtensions: true,
  //   );
  // }

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    if (statuses[Permission.camera] == PermissionStatus.granted &&
        statuses[Permission.microphone] == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorConstant.purple,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 90,
                  ),
                  CommonText(
                    title: widget.userData.displayName,
                    color: ColorConstant.whiteColor,
                    fontSize: 20,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  IconButton(
                    onPressed: () {
                      // Get.to(MeetRoom());
                      showJoinMeetingDialog('Join Audio Call', context, false);
                    },
                    icon: const Icon(
                      Icons.phone,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Get.to(MeetRoom());
                      showJoinMeetingDialog('Join Video Call', context, true);
                    },
                    icon: const Icon(
                      Icons.video_call,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('message')
                      .where('IdTo', isEqualTo: widget.userData.uid)
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.pink),
                        ),
                      );
                    }
                    List<ChatModel> messages = snapshot.data!.docs
                        .map((snapshot) => ChatModel.fromMap(snapshot.data()))
                        .toList();
                    return Container(
                        width: size.width,
                        height: size.height / 1.13,
                        decoration: BoxDecoration(
                            color: ColorConstant.whiteColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            )),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    print(
                                        'length --${snapshot.data!.docs.length}');
                                    return BubbleChat(
                                        left: messages[index].idFrom ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? 0
                                            : 1,
                                        imageUrl: messages[index].imageUrl,
                                        content: messages[index].content,
                                        videoUrl: messages[index].videoUrl);
                                  }),
                            ),
                            // const Spacer(),
                            Material(
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
                                    IconButton(
                                        onPressed: () async {
                                          await imagePick();
                                        },
                                        icon: Icon(
                                          Icons.camera,
                                          color: ColorConstant.purple,
                                        )),
                                    IconButton(
                                        onPressed: () async {
                                          await pickVideo();
                                        },
                                        icon: Icon(
                                          Icons.video_file,
                                          color: ColorConstant.purple,
                                        )),
                                    Expanded(
                                        child: TextField(
                                      controller: chatController,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Type message',
                                          hintStyle: TextStyle(
                                              color: ColorConstant.greyColor)),
                                    )),
                                    IconButton(
                                        onPressed: () async {
                                          if (imageUrl == '' &&
                                              videoDownLoad == '') {
                                            await controller.sendMessage(
                                                chatController.text,
                                                widget.userData.uid,
                                                imageUrl,
                                                videoDownLoad);
                                            chatController.clear();
                                            imageuser = null;
                                            imageUrl = '';
                                            videoDownLoad = '';
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    ColorConstant.redColor,
                                                content:
                                                    const Text('Please wait '),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.send,
                                          color: ColorConstant.purple,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ));
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class BubbleChat extends StatefulWidget {
  int left;
  String content;
  String imageUrl;
  String videoUrl;
  BubbleChat(
      {required this.left,
      required this.content,
      required this.imageUrl,
      required this.videoUrl});

  @override
  State<BubbleChat> createState() => _BubbleChatState();
}

class _BubbleChatState extends State<BubbleChat> {
  late VideoPlayerController videoPlayerController;
  late Future<void> initilizeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != '') {
      videoPlayerController = VideoPlayerController.network(widget.videoUrl);
      initilizeVideoPlayerFuture = videoPlayerController.initialize();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.videoUrl != '') {
      videoPlayerController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            Container(
                width: size.width / 1.06,
                margin: widget.left == 0
                    ? EdgeInsets.only(right: 10, top: 8)
                    : EdgeInsets.only(left: 10, top: 8),
                alignment: widget.left == 0
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(25.0),
                      topRight: const Radius.circular(25.0),
                      bottomLeft: widget.left == 0
                          ? const Radius.circular(25.0)
                          : const Radius.circular(1.0),
                      bottomRight: widget.left == 0
                          ? const Radius.circular(1.0)
                          : const Radius.circular(25.0),
                    ),
                    color: widget.left == 0
                        ? widget.imageUrl != '' || widget.videoUrl != ''
                            ? ColorConstant.whiteColor
                            : ColorConstant.blueColor
                        : widget.imageUrl != '' || widget.videoUrl != ''
                            ? ColorConstant.whiteColor
                            : Colors.grey[300],
                  ),
                  padding: const EdgeInsets.all(15),
                  constraints: BoxConstraints(maxWidth: 330),
                  child: (widget.imageUrl != null && widget.imageUrl != '') ||
                          (widget.videoUrl != '')
                      ? Column(
                          children: [
                            widget.content != null
                                ? CommonText(
                                    title: widget.content,
                                    color: widget.left == 0
                                        ? ColorConstant.whiteColor
                                        : ColorConstant.blackColor,
                                    fontSize: 20,
                                  )
                                : Container(),
                            widget.imageUrl != null && widget.imageUrl != ''
                                ? Container(
                                    height: 100,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        color: ColorConstant.whiteColor,
                                        image: DecorationImage(
                                            image:
                                                NetworkImage(widget.imageUrl))),
                                  )
                                : Container(),
                            widget.videoUrl != null && widget.videoUrl != ''
                                ? Container(
                                    alignment: widget.left == 0
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: FutureBuilder(
                                        future: initilizeVideoPlayerFuture,
                                        builder:
                                            (context, AsyncSnapshot snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            return Container(
                                              height: 100,
                                              width: 150,
                                              alignment: widget.left == 0
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                              color: Colors.white,
                                              child: VideoPlayer(
                                                  videoPlayerController),
                                            );
                                          } else {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        }),
                                  )
                                : Container()
                          ],
                        )
                      : CommonText(
                          title: widget.content,
                          color: widget.left == 0
                              ? ColorConstant.whiteColor
                              : ColorConstant.blackColor,
                          fontSize: 20,
                        ),
                )),
          ],
        ),
      ],
    );
  }
}
