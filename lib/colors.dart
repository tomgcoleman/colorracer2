
import 'dart:ui';

import 'package:flutter/material.dart';

enum Textures {
  none,
  vertical1,
  horizontal1,
  both1,
  vertical2,
  horizontal2,
  both2,
  vertical3,
  horizontal3,
  both3,
  largeX,
  largeStar,
}

class MyTextures {
  static Textures increment(Textures current) {
    switch(current) {
      case Textures.none:
        return Textures.vertical1;
      case Textures.vertical1:
        return Textures.vertical2;
      case Textures.vertical2:
        return Textures.vertical3;
      case Textures.vertical3:
        return Textures.horizontal1;
      case Textures.horizontal1:
        return Textures.horizontal2;
      case Textures.horizontal2:
        return Textures.horizontal3;
      case Textures.horizontal3:
        return Textures.both1;
      case Textures.both1:
        return Textures.both2;
      case Textures.both2:
        return Textures.both3;
      case Textures.both3:
        return Textures.largeX;
      case Textures.largeX:
        return Textures.largeStar;
    }
    return Textures.none;
  }

  static List<Textures> textures = [Textures.none, Textures.none, Textures.none, Textures.none,
    Textures.none, Textures.none];

  static void setTexture(int index, Textures newTexture) {
    if (index < 0 || index >= textures.length) return;
    textures[index] = newTexture;
  }

  static Textures getTexture(int index) {
    if (index < 0 || index >= textures.length) return Textures.largeStar;

    return textures[index];
  }

}

class MyColors {
  static final darkBlue = Color(0xff0000ff);
  static final darkGreen = Color(0xff00ff00);
  static final lightCyan = Color(0xff3355ff);
  static final defaultColor = Color(0xafa360b3);

  static bool useHighContrast = false;

  static List<Color> colors = [Colors.white, Colors.yellow, Colors.red, MyColors.darkBlue,
    MyColors.darkGreen, Colors.cyan[300]];

  // http://mkweb.bcgsc.ca/colorblind/distinct.colors.mhtml
  static List<Color> colorsContrast = [
    Colors.white,
    Color.fromARGB(0xff, 190, 152,  69), // yellow
    Color.fromARGB(0xff, 166,  76,  50), // red
    Color.fromARGB(0xff, 110,  69, 146), // purple
    Color.fromARGB(0xff,  79, 141,  75), // green
    Color.fromARGB(0xff,  50, 154, 200), // cyan
  ];

  static void setColor(int index, Color newColor) {
    if (index < 0 || index >= colors.length) return;

    colors[index] = newColor;
  }

  static Color getColor(int index) {

    if (useHighContrast) {
      if (index < 0 || index >= colorsContrast.length) return Colors.black;
      return colorsContrast[index];
    }

    if (index < 0 || index >= colors.length) return Colors.black;
    return colors[index];
  }
}


class MyPaints {
  static final Paint _magenta = Paint()
    ..color = Color(0xffff00a3);
  static final Paint _white = Paint()
    ..color = Color(0xffffffff);
  static final Paint _black = Paint()
    ..color = Color(0xff000000);
  static final Paint _yellow = Paint()
    ..color = Color(0xffffff63);
  static final Paint _red = Paint()
    ..color = Color(0xffff0000);
  static final Paint _blue = Paint()
    ..color = Color(0xff0000ff);
  static final Paint _green = Paint()
    ..color = Color(0xff22ff00);
  static final Paint _cyan = Paint()
    ..color = Color(0xff00ffff);

  static final Paint pMagenta = Paint()
    ..color = Color(0xffff00a3);
  static final Paint pWhite = Paint()
    ..color = Color(0xffffffff);
  static final Paint pBlack = Paint()
    ..color = Color(0xff000000);
  static final Paint pYellow = Paint()
    ..color = Color(0xffffff63);
  static final Paint pRed = Paint()
    ..color = Color(0xffff0000);
  static final Paint pBlue = Paint()
    ..color = Color(0xff0000ff);
  static final Paint pGreen = Paint()
    ..color = Color(0xff00ff00);
  static final Paint pCyan = Paint()
    ..color = Color(0xff00ffff);
}