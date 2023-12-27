import '../../../allpackages.dart';

class MeetRoom extends StatefulWidget {
  String roomName;
  bool isVideoCall;
  String profileUrl;
  String displayName;
  MeetRoom(
      {required this.roomName,
      required this.isVideoCall,
      required this.profileUrl,
      required this.displayName});

  @override
  State<MeetRoom> createState() => _MeetRoomState();
}

class _MeetRoomState extends State<MeetRoom> {
  int? _remoteUid;
  bool _localUserJoined = false;

  bool isLoading = true;

  late RtcEngine _engine;

  bool isMute = false;

  bool isOffCamera = false;

  bool isSwithCamera = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: 'cbe2be175fdb4726ba1f60cdfc6240d7',
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    _engine.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint("local user ${connection.localUid} joined");
        setState(() {
          _localUserJoined = true;
        });
      }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint("remote user $remoteUid joined");
        setState(() {
          _remoteUid = remoteUid;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User $remoteUid joined the meeting'),
          ),
        );
      }, onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
        debugPrint("remote user $remoteUid left channel");
        setState(() {
          _remoteUid = null;
        });
      }, onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      }, onError: (ErrorCodeType type, String e) {
        debugPrint('[error] exception: ${type.toString()}, token: $e');
      }),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    print('channel name ${widget.roomName}');

    await _engine.joinChannel(
      token:
          '007eJxTYHh8SmbRnrNPHVn/yPy3c45SNbzRJzbNZf6xe1v3PptYW79TgSE5KdUoKdXQ3DQtJcnE3MgsKdEwzcwgOSUt2czIxCDFPGZxd2pDICPD194DrIwMEAjiszJ4paaWJTIwAABIqCMj',
      channelId: 'Jeeva',
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: widget.isVideoCall ? Text('Video Call') : Text('Audio Call'),
      ),
      body: isLoading
          ? SizedBox(
              height: size.height,
              width: size.width,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Stack(
              children: [
                Center(
                  child: _remoteVideo(),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 100,
                    height: 150,
                    child: Center(
                      child: _localUserJoined && widget.isVideoCall
                          ? AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: _engine,
                                canvas: const VideoCanvas(uid: 0),
                              ),
                            )
                          : widget.isVideoCall == false
                              ? Column(
                                  children: [
                                    Image.network(widget.profileUrl),
                                    CommonText(
                                      title: widget.displayName,
                                      color: ColorConstant.blackColor,
                                      fontSize: 16,
                                    ),
                                  ],
                                )
                              : const CircularProgressIndicator(),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 2,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            setState(() {
                              isMute = !isMute;
                            });
                            await _engine.muteLocalAudioStream(isMute);
                          },
                          child: SizedBox(
                            height: 55,
                            width: 90,
                            child: CircleAvatar(
                              backgroundColor: ColorConstant.greyColor,
                              child: !isMute
                                  ? Icon(Icons.mic)
                                  : Icon(Icons.mic_off),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              isOffCamera = !isOffCamera;
                            });
                            await _engine.muteLocalVideoStream(isOffCamera);
                          },
                          child: SizedBox(
                            height: 55,
                            width: 90,
                            child: CircleAvatar(
                              backgroundColor: ColorConstant.greyColor,
                              child: !isOffCamera
                                  ? Icon(Icons.camera_alt)
                                  : Icon(Icons.camera),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              isSwithCamera = !isSwithCamera;
                            });
                            await _engine.switchCamera();
                          },
                          child: SizedBox(
                            height: 55,
                            width: 90,
                            child: CircleAvatar(
                              backgroundColor: ColorConstant.greyColor,
                              child: !isSwithCamera
                                  ? Icon(Icons.switch_camera_outlined)
                                  : Icon(Icons.switch_camera),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            dispose();
                            Get.back();
                          },
                          child: SizedBox(
                            height: 55,
                            width: 90,
                            child: CircleAvatar(
                              backgroundColor: ColorConstant.redColor,
                              child: Icon(Icons.phone_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _remoteVideo() {
    var size = MediaQuery.of(context).size;
    if (_remoteUid != null && widget.isVideoCall) {
      return Container(
        height: size.height,
        width: size.width,
        child: AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: 1),
            connection: RtcConnection(channelId: 'Jeeva'),
          ),
        ),
      );
    } else if (_remoteUid != null && widget.isVideoCall == false) {
      return Container(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            Image.network(widget.profileUrl),
            CommonText(
              title: widget.displayName,
              color: ColorConstant.blackColor,
              fontSize: 16,
            ),
            Image.network(widget.profileUrl)
          ],
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
