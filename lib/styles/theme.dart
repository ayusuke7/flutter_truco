import 'package:flutter/material.dart';

class ThemeCustom {

  static ThemeData theme() {
    return ThemeData(
        primarySwatch: Colors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all<Color>(
              Colors.black.withOpacity(0.085)
            ),
            shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) {
              if (states.contains(MaterialState.focused)) {
                return RoundedRectangleBorder(
                  side: BorderSide(color: Colors.yellow, width: 3.5),
                  borderRadius: BorderRadius.circular(10),
                );
              }

              return RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
              );
            }
          )
        ))
      );
  }
}