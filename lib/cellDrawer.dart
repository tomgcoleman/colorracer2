

import 'dart:ui';

import 'package:colorracer2/Bouncer.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class CellDrawer {
  Paint pBlack = Paint()..color = Colors.black;

  CellDrawer() {
    pBlack.strokeWidth = 4;
  }

  Paint getPaintFromColor(Color color) {
    Paint p = Paint()..color = color;
    return p;
  }

  void drawLargeX(Canvas canvas, Bouncer drawMe, bool drawBorder) {
    double borderThickness = drawMe.getRect().width / 10;
    double shiftIn = !drawBorder ? borderThickness + 1 : 0;
    // diagonal down
    canvas.drawLine(
        Offset(drawMe.getRect().left + shiftIn, drawMe.getRect().top + shiftIn),
        Offset(drawMe.getRect().right - shiftIn, drawMe.getRect().bottom - shiftIn),
        pBlack);
    // diagonal up
    canvas.drawLine(
        Offset(drawMe.getRect().left + shiftIn, drawMe.getRect().bottom - shiftIn),
        Offset(drawMe.getRect().right - shiftIn, drawMe.getRect().top + shiftIn),
        pBlack);
  }

  drawLargeStar(Canvas canvas, Bouncer drawMe, bool drawBorder) {
    double borderThickness = drawMe.getRect().width / 10;
    double shiftIn = !drawBorder ? borderThickness + 1 : 0;

    canvas.drawLine(
        Offset(drawMe.getRect().left + shiftIn, drawMe.getRect().center.dy),
        Offset(drawMe.getRect().right - shiftIn, drawMe.getRect().center.dy),
        pBlack);
    canvas.drawLine(
        Offset(drawMe.getRect().center.dx, drawMe.getRect().top + shiftIn),
        Offset(drawMe.getRect().center.dx, drawMe.getRect().bottom - shiftIn),
        pBlack);

    drawLargeX(canvas, drawMe, drawBorder);
  }

  int skip = 0;

  void drawFlats(Canvas canvas, Bouncer drawMe, bool drawBorder) {
    Textures texture = !drawBorder ? drawMe.texture : drawMe.borderTexture;
    double borderThickness = drawMe.getRect().width / 10;
    double shiftIn = !drawBorder ? borderThickness + 1 : 0;
    double lineStep = borderThickness * 3;

    if (false && !drawBorder && drawMe.getRect().width > 100) {
      if (skip++ > 15) {
        skip = 0;
        print("texture is " + texture.toString() + " height: " + drawMe.getRect().height.toString());
      }
      canvas.drawLine(
          Offset(drawMe.getRect().left, drawMe.getRect().center.dy - 20),
          Offset(drawMe.getRect().right, drawMe.getRect().center.dy - 20),
          pBlack);
      canvas.drawLine(
          Offset(drawMe.getRect().left, drawMe.getRect().center.dy + 30),
          Offset(drawMe.getRect().right, drawMe.getRect().center.dy + 30),
          pBlack);
    }

    if (texture == Textures.horizontal1 || texture == Textures.horizontal3 || texture == Textures.both1 || texture == Textures.both3) {
      // horizontal center line
      canvas.drawLine(
          Offset(drawMe.getRect().left + shiftIn, drawMe.getRect().center.dy),
          Offset(drawMe.getRect().right - shiftIn, drawMe.getRect().center.dy),
          pBlack);
      if (texture == Textures.horizontal3 || texture == Textures.both3) {
        canvas.drawLine(
            Offset(drawMe.getRect().left + shiftIn, drawMe.getRect().center.dy - lineStep),
            Offset(drawMe.getRect().right - shiftIn, drawMe.getRect().center.dy - lineStep),
            pBlack);
        canvas.drawLine(
            Offset(drawMe.getRect().left + shiftIn, drawMe.getRect().center.dy + lineStep),
            Offset(drawMe.getRect().right - shiftIn, drawMe.getRect().center.dy + lineStep),
            pBlack);
      }
    }

    if (texture == Textures.horizontal2 || texture == Textures.both2) {
      // horizontal center line
      canvas.drawLine(
          Offset(drawMe.getRect().left + shiftIn, drawMe.getRect().center.dy - lineStep),
          Offset(drawMe.getRect().right - shiftIn, drawMe.getRect().center.dy - lineStep),
          pBlack);

      canvas.drawLine(
          Offset(drawMe.getRect().left + shiftIn, drawMe.getRect().center.dy + lineStep),
          Offset(drawMe.getRect().right - shiftIn, drawMe.getRect().center.dy + lineStep),
          pBlack);
    }

    if (texture == Textures.vertical1 || texture == Textures.vertical3 || texture == Textures.both1 || texture == Textures.both3) {
      // horizontal center line
      canvas.drawLine(
          Offset(drawMe.getRect().center.dx, drawMe.getRect().top + shiftIn),
          Offset(drawMe.getRect().center.dx, drawMe.getRect().bottom - shiftIn),
          pBlack);
      if (texture == Textures.vertical3 || texture == Textures.both3) {
        // horizontal center line
        canvas.drawLine(
            Offset(drawMe.getRect().center.dx - lineStep, drawMe.getRect().top + shiftIn),
            Offset(drawMe.getRect().center.dx - lineStep, drawMe.getRect().bottom - shiftIn),
            pBlack);
        canvas.drawLine(
            Offset(drawMe.getRect().center.dx + lineStep, drawMe.getRect().top + shiftIn),
            Offset(drawMe.getRect().center.dx + lineStep, drawMe.getRect().bottom - shiftIn),
            pBlack);
      }
    }

    if (texture == Textures.vertical2 || texture == Textures.both2 ) {
      // horizontal non center lines. two stripes
      canvas.drawLine(
          Offset(drawMe.getRect().center.dx - lineStep, drawMe.getRect().top + shiftIn),
          Offset(drawMe.getRect().center.dx - lineStep, drawMe.getRect().bottom - shiftIn),
          pBlack);

      canvas.drawLine(
          Offset(drawMe.getRect().center.dx + lineStep, drawMe.getRect().top + shiftIn),
          Offset(drawMe.getRect().center.dx + lineStep, drawMe.getRect().bottom - shiftIn),
          pBlack);
    }
  }

  void drawTexture(Canvas canvas, Bouncer drawMe, bool drawBorder) {
    Textures texture = drawBorder ? drawMe.borderTexture : drawMe.texture;

    switch(texture) {
      case Textures.largeX:
        drawLargeX(canvas, drawMe, drawBorder);
        break;
      case Textures.largeStar:
        drawLargeStar(canvas, drawMe, drawBorder);
        break;
      case Textures.both1:
      case Textures.both2:
      case Textures.both3:
        drawFlats(canvas, drawMe, drawBorder);
        break;
      case Textures.vertical1:
      case Textures.vertical2:
      case Textures.vertical3:
      case Textures.horizontal1:
      case Textures.horizontal2:
      case Textures.horizontal3:
        drawFlats(canvas, drawMe, drawBorder);
        break;
    }
  }

  void drawCell(Canvas canvas, Bouncer drawMe) {
    double borderThickness = drawMe.getRect().width / 10;
    Rect r = drawMe.getRect();
    canvas.drawRect(r, MyPaints.pBlack);
    r = r.deflate(1); // .inset(5, 5);
    canvas.drawRect(r, getPaintFromColor(drawMe.getBorderColor()));
    drawTexture(canvas, drawMe, true);

    r = r.deflate(borderThickness); // inset(13, 13);
    canvas.drawRect(r, MyPaints.pBlack);
    r = r.deflate(1); // inset(2, 2);
    Paint cellCelterPaint = getPaintFromColor(drawMe.getColor());
    canvas.drawRect(r, cellCelterPaint);

    drawTexture(canvas, drawMe, false);
  }
}