
import 'package:flukit/flukit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GreatGradientButton extends GradientButton{

  GreatGradientButton({
    Key key,
    colors,
    onPressed,
    this.onLongPress,
    padding,
    borderRadius,
    textColor,
    splashColor,
    disabledColor,
    disabledTextColor,
    onHighlightChanged,
    @required child,
  }):super(
    key:key,
    colors:colors,
    onPressed:onPressed,
    padding:padding,
    borderRadius:borderRadius,
    textColor:textColor,
    splashColor:splashColor,
    disabledColor:disabledColor,
    disabledTextColor:disabledTextColor,
    onHighlightChanged:onHighlightChanged,
    child:child,
  );


  final GestureLongPressCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    //确保colors数组不空
    List<Color> _colors = colors ??
        [theme.primaryColor, theme.primaryColorDark ?? theme.primaryColor];
    var radius = borderRadius ?? BorderRadius.circular(2);
    bool disabled = onPressed == null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: disabled ? null : LinearGradient(colors: _colors),
        color: disabled
            ? disabledColor ?? disabledColor ?? theme.disabledColor
            : null,
        borderRadius: radius,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
          child: InkWell(
            splashColor: splashColor ?? _colors.last,
            highlightColor: Colors.transparent,
            borderRadius: borderRadius ?? BorderRadius.circular(5),
            onHighlightChanged: onHighlightChanged,
            onTap: onPressed,
            onLongPress: onLongPress,
            child: Padding(
              padding: padding ?? theme.buttonTheme.padding,
              child: DefaultTextStyle(
                style: TextStyle(fontWeight: FontWeight.bold),
                child: Center(
                  child: DefaultTextStyle(
                    style: theme.textTheme.button.copyWith(
                        color: disabled
                            ? disabledTextColor ?? Colors.black38
                            : textColor ?? Colors.white),
                    child: child,
                  ),
                  widthFactor: 1,
                  heightFactor: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}