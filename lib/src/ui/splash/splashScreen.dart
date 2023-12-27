import '../../../allpackages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Timer(
          const Duration(seconds: 5),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const Message())));
    } else {
      Timer(
          const Duration(seconds: 15),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const SignIn())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonAsset(
              name: 'assets/splash.json',
            ),
            RichText(
              text: TextSpan(
                text: 'OneData',
                style: TextStyle(
                    color: ColorConstant.blueColor,
                    fontSize: 50,
                    fontFamily: 'Agbalumo'),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Chat',
                    style: TextStyle(
                      color: ColorConstant.purple,
                      fontSize: 50,
                    ),
                  ),
                ],
              ),
            ),
            CommonText(
              title: 'Connect with your Friends',
              color: ColorConstant.blackColor,
              fontSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
