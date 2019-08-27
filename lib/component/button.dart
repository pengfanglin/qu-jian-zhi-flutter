import 'package:flutter/material.dart';
import 'package:qjz/utils/application.dart';

class Button extends FlatButton{
  const Button({
    Key key,
    @required VoidCallback onPressed,
    ValueChanged<bool> onHighlightChanged,
    ButtonTextTheme textTheme=ButtonTextTheme.normal,
    Color textColor=Colors.white,
    Color disabledTextColor=Colors.white,
    Color color=Application.themeColor,
    Color disabledColor=Colors.grey,
    Color highlightColor=Application.themeColor,
    Color splashColor=Colors.transparent,
    Brightness colorBrightness=Brightness.light,
    EdgeInsetsGeometry padding=const EdgeInsets.all(10),
    ShapeBorder shape=const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15))),
    Clip clipBehavior = Clip.antiAlias,
    MaterialTapTargetSize materialTapTargetSize=MaterialTapTargetSize.padded,
    @required Widget child,
  }) : super(
    key: key,
    onPressed: onPressed,
    onHighlightChanged: onHighlightChanged,
    textTheme: textTheme,
    textColor: textColor,
    disabledTextColor: disabledTextColor,
    color: color,
    disabledColor: disabledColor,
    highlightColor: highlightColor,
    splashColor: splashColor,
    colorBrightness: colorBrightness,
    padding: padding,
    shape: shape,
    clipBehavior: clipBehavior,
    materialTapTargetSize: materialTapTargetSize,
    child: child,
  );
}