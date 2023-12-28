import '../../../../allpackages.dart';

class Message extends StatelessWidget {
  const Message({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(MessageController());
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorConstant.purple,
          title: CommonText(
            title: 'Message',
            color: ColorConstant.whiteColor,
            fontSize: 20,
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                controller.logout();
              },
              child: Icon(
                FontAwesome.logout,
                size: 25,
                color: ColorConstant.whiteColor,
              ),
            )
          ],
        ),
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: GetBuilder<MessageController>(
              id: 'messageList',
              builder: (_) {
                return controller.isLoading.value == true
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : controller.userData != null &&
                            controller.userData.length > 0
                        ? ListView.builder(
                            itemCount: controller.userData.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              var data = controller.userData[index];
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      //  Get.to(MediaFileSend());
                                      Get.to(ChatScreen(userData: data));
                                    },
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundColor:
                                            ColorConstant.blueColor,
                                        backgroundImage:
                                            NetworkImage(data.profile),
                                      ),
                                      title: CommonText(
                                        title: data.displayName,
                                        color: ColorConstant.blackColor,
                                        fontSize: 13,
                                      ),
                                      subtitle: CommonText(
                                        title: 'Hi',
                                        color: ColorConstant.greyColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                    color: ColorConstant.purple,
                                  )
                                ],
                              );
                            })
                        : Center(
                            child: CommonText(
                              title: 'No Data Found',
                              color: ColorConstant.blackColor,
                              fontSize: 20,
                            ),
                          );
              }),
        ),
      ),
    );
  }
}
