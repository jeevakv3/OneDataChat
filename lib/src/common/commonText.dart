import '../../../allpackages.dart';

class CommonText extends StatelessWidget {
  String? title;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  FontStyle? fontStyle;
  bool? isUnderLine;
  CommonText(
      {required this.title,
      required this.color,
      this.fontSize,
      this.fontStyle,
      this.fontWeight,
      this.isUnderLine});

  @override
  Widget build(BuildContext context) {
    // 'Agbalumo'
    return Text(title!,
        style: TextStyle(
            decoration: isUnderLine != null
                ? TextDecoration.underline
                : TextDecoration.none,
            color: color,
            fontSize: fontSize,
            fontStyle: fontStyle,
            fontWeight: fontWeight));
  }
}
