import '../../allpackages.dart';

class CommonAsset extends StatelessWidget {
  String name;
  double? width;
  double? heigth;

  CommonAsset({required this.name, this.heigth, this.width});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      name,
      height: heigth ?? 300.0,
      width: width ?? MediaQuery.of(context).size.width,
      repeat: true,
      reverse: true,
      animate: true,
    );
  }
}
