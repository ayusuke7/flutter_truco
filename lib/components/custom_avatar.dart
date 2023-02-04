import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {

  final Widget asset;
  final String? name;
  final Color? backgroundColor;
  final Color? backgroundNameColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;

  const CustomAvatar({ 
    Key? key,
    required this.asset,
    this.name,
    this.backgroundColor,
    this.backgroundNameColor,
    this.margin,
    this.padding,
    this.decoration,
    this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        margin: margin,
        decoration: decoration,
        child: Column(
          children: [
            if(name != null) Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color:backgroundNameColor,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text("$name",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13
                )
              ),
            ),
            CircleAvatar(
              maxRadius: 40,
              backgroundColor: backgroundColor,
              child: asset,
            ),
          ],
        ),
      ),
    );
  }
}