import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Size? size;
  final Color? backgroundColor;
  final Color? color;
  final EdgeInsets? margin;
  final TextStyle? style;
  final bool disable;
  final bool visible;
  
  const CustomButton({ 
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.size,
    this.backgroundColor,
    this.margin,
    this.style,
    this.disable = false,
    this.visible = true,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var textStyle = TextStyle(
      fontSize: 16,
      color: color
    )..merge(style);

    return Container(
      margin: margin,
      child: TextButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: disable ? null : onPressed,
        style: TextButton.styleFrom(
          textStyle: textStyle,
          foregroundColor: textStyle.color,
          fixedSize: size ?? Size(150, 40),
          backgroundColor: disable 
            ? Colors.grey.withOpacity(.5) 
            : backgroundColor,
        ),
      ),
    );
  }
}