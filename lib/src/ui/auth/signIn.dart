import '../../../allpackages.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignInController());
    var size = MediaQuery.of(context).size;
    return GetBuilder<SignInController>(
        id: 'signIn',
        builder: (_) {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: ColorConstant.whiteColor,
                body: SizedBox(
                  height: size.height,
                  width: size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height * 0.1,
                      ),
                      CommonText(
                        title: 'Welcome To OneDataChat',
                        color: ColorConstant.blueColor,
                        fontSize: 20,
                      ),
                      SizedBox(
                        height: size.height * 0.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 60,
                          width: size.width,
                          child: ElevatedButton(
                              onPressed: () {
                                controller.handleSignIn();
                              },
                              style: ElevatedButton.styleFrom(
                                primary:
                                    ColorConstant.redColor, // Background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // BorderRadius
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesome5.google,
                                    color: ColorConstant.whiteColor,
                                  ),
                                  CommonText(
                                    title: 'oogle Signin',
                                    color: ColorConstant.whiteColor,
                                    fontSize: 18,
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              controller.isLoading.value == true
                  ? Positioned(
                      child: Container(
                        width: size.width,
                        height: size.height,
                        color: Colors.grey.withOpacity(0.6),
                        child: Center(
                            child: CircularProgressIndicator(
                          color: ColorConstant.purple,
                        )),
                      ),
                    )
                  : Container()
            ],
          );
        });
  }
}
