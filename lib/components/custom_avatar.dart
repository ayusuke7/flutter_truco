import 'package:flutter/material.dart';

import 'card_game.dart';

class CustomAvatar extends StatelessWidget {

  final Widget asset;
  final String? name;
  final Color? backgroundColor;
  final Color? backgroundNameColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final int cards;
  final Size size;

  const CustomAvatar({ 
    Key? key,
    required this.asset,
    this.name,
    this.backgroundColor,
    this.backgroundNameColor,
    this.margin,
    this.padding,
    this.decoration,
    this.onTap,
    this.cards = 0,
    this.size = const Size(120, 120)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width,
        height: size.height,
        padding: padding,
        margin: margin,
        decoration: decoration,
        child: Stack(
          alignment: Alignment.center,
          children: [
            
            if (cards > 0) Positioned(
              top: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(cards, (i) => CardGame(
                  width: 30
                )).toList()
              ),
            ),

            Positioned(
              bottom: 10,
              child: CircleAvatar(
                child: asset,
                maxRadius: size.width / 4,
                backgroundColor: backgroundColor ?? Colors.transparent,
              ),
            ),

            if(name != null) Positioned(
              bottom: 0,
              child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}