
// add textures to a given color
// change color

import 'dart:math';
import 'dart:ui';

import 'package:colorracer2/cellDrawer.dart';
import 'package:flutter/material.dart';

import 'Bouncer.dart';
import 'colors.dart';


class Config {
  Rect drawSpace;
  List<Bouncer> boxes = List.empty(growable: true);
  Rect selectedBoxRect;
  Rect setDefaultPatternsDarkButton;
  Rect setDefaultPatternsLightButton;
  Rect clearAllPatternsButton;
  Rect nextPatternButton;

  Rect colorContrastButton;

  Rect saveButton;
  Rect cancelButton;

  int activeCellIndex = 0;

  CellDrawer drawer = CellDrawer();
  Paint pWhite = CellDrawer().getPaintFromColor(Colors.white);
  Paint pGreen = CellDrawer().getPaintFromColor(Colors.green);
  Paint pRed = CellDrawer().getPaintFromColor(Colors.red);

  bool visible = false;

  Bouncer bouncerSelection = Bouncer();
  Bouncer bouncerDefaultPatternLight = Bouncer();
  Bouncer bouncerDefaultPatternDark = Bouncer();
  Bouncer bouncerClearPattern = Bouncer();

  void showConfig() {
    visible = true;
  }

  void hideConfig() {
    visible = false;
  }

  // todo: divide up screen into buttons to set, example button, inputs to change color / texture, save and cancel
  setSize(Rect size) {
    drawSpace = size;

    var boxWidth = min(drawSpace.width / 4, drawSpace.height / 6);
    var margin = boxWidth / 5;
    var index = 0;

    pWhite.strokeWidth = margin/2;
    pWhite.style = PaintingStyle.stroke;
    // pWhite.dashed = true;

    var ul = Rect.fromLTWH(drawSpace.left + margin, drawSpace.top + margin, boxWidth, boxWidth);
    Bouncer ulBouncer = Bouncer();
    ulBouncer.setRect(ul);
    ulBouncer.texture = MyTextures.getTexture(index);
    ulBouncer.color = MyColors.getColor(index);
    ulBouncer.borderTexture = MyTextures.getTexture(index);
    ulBouncer.borderColor = MyColors.getColor(index);
    boxes.add(ulBouncer);
    index++;

    selectedBoxRect = ul.inflate(margin);

    var uc = ul.shift(Offset(boxWidth + margin, 0));
    Bouncer ucBouncer = Bouncer();
    ucBouncer.setRect(uc);
    ucBouncer.texture = MyTextures.getTexture(index);
    ucBouncer.color = MyColors.getColor(index);
    ucBouncer.borderTexture = MyTextures.getTexture(index);
    ucBouncer.borderColor = MyColors.getColor(index);
    boxes.add(ucBouncer);
    index++;

    var ur = uc.shift(Offset(boxWidth + margin, 0));
    Bouncer urBouncer = Bouncer();
    urBouncer.setRect(ur);
    urBouncer.texture = MyTextures.getTexture(index);
    urBouncer.color = MyColors.getColor(index);
    urBouncer.borderTexture = MyTextures.getTexture(index);
    urBouncer.borderColor = MyColors.getColor(index);
    boxes.add(urBouncer);
    index++;

    var ll = ul.shift(Offset(0, boxWidth + margin));
    Bouncer clBouncer = Bouncer();
    clBouncer.setRect(ll);
    clBouncer.texture = MyTextures.getTexture(index);
    clBouncer.color = MyColors.getColor(index);
    clBouncer.borderTexture = MyTextures.getTexture(index);
    clBouncer.borderColor = MyColors.getColor(index);
    boxes.add(clBouncer);
    index++;

    var lc = ll.shift(Offset(boxWidth + margin, 0));
    Bouncer crBouncer = Bouncer();
    crBouncer.setRect(lc);
    crBouncer.texture = MyTextures.getTexture(index);
    crBouncer.color = MyColors.getColor(index);
    crBouncer.borderTexture = MyTextures.getTexture(index);
    crBouncer.borderColor = MyColors.getColor(index);
    boxes.add(crBouncer);
    index++;

    var lr = lc.shift(Offset(boxWidth + margin, 0));
    Bouncer brBouncer = Bouncer();
    brBouncer.setRect(lr);
    brBouncer.texture = MyTextures.getTexture(index);
    brBouncer.color = MyColors.getColor(index);
    brBouncer.borderTexture = MyTextures.getTexture(index);
    brBouncer.borderColor = MyColors.getColor(index);
    boxes.add(brBouncer);

    var active = Rect.fromLTWH(drawSpace.left + margin * 3, ll.bottom + margin * 3, boxWidth * 3 / 2, boxWidth * 3 / 2);
    bouncerSelection.setRect(active);
    bouncerSelection.color = boxes[0].color;
    bouncerSelection.borderColor = boxes[0].borderColor;
    bouncerSelection.texture = boxes[0].texture;
    bouncerSelection.borderTexture = boxes[0].borderTexture;
    boxes.add(bouncerSelection);

    setDefaultPatternsLightButton = Rect.fromLTWH(active.right + margin, active.top, boxWidth * 2 / 3, boxWidth * 2 / 3);
    setDefaultPatternsDarkButton = Rect.fromLTWH(setDefaultPatternsLightButton.right + margin, active.top, boxWidth * 2 / 3, boxWidth * 2 / 3);
    clearAllPatternsButton = Rect.fromLTWH(active.right + margin, setDefaultPatternsLightButton.bottom + margin, boxWidth * 2 / 3, boxWidth * 2 / 3);
    nextPatternButton = Rect.fromLTWH(active.right + margin, clearAllPatternsButton.bottom + margin, boxWidth * 2 / 3, boxWidth * 2 / 3);

    colorContrastButton = Rect.fromLTWH(margin, nextPatternButton.top, boxWidth, boxWidth);

    bouncerDefaultPatternLight.setRect(setDefaultPatternsLightButton);
    bouncerDefaultPatternLight.color = Colors.yellow;
    bouncerDefaultPatternLight.borderColor = Colors.yellow;
    bouncerDefaultPatternLight.texture = Textures.both1;
    bouncerDefaultPatternLight.borderTexture = Textures.both1;
    boxes.add(bouncerDefaultPatternLight);

    bouncerDefaultPatternDark.setRect(setDefaultPatternsDarkButton);
    bouncerDefaultPatternDark.color = Colors.yellow;
    bouncerDefaultPatternDark.borderColor = Colors.yellow;
    bouncerDefaultPatternDark.texture = Textures.largeStar;
    bouncerDefaultPatternDark.borderTexture = Textures.largeStar;
    boxes.add(bouncerDefaultPatternDark);

    bouncerClearPattern.setRect(clearAllPatternsButton);
    bouncerClearPattern.color = Colors.yellow;
    bouncerClearPattern.borderColor = Colors.yellow;
    bouncerClearPattern.texture = Textures.none;
    bouncerClearPattern.borderTexture = Textures.none;
    boxes.add(bouncerClearPattern);

    saveButton = Rect.fromLTRB(margin * 3, drawSpace.bottom - margin * 4, drawSpace.width/2 - margin, drawSpace.height - margin);
    cancelButton = Rect.fromLTRB(drawSpace.width/2 + margin, saveButton.top, drawSpace.width - margin * 3, saveButton.bottom);
  }

  void onClick(double x, double y) {
    var clickOffset = Offset(x, y);

    if (cancelButton.contains(clickOffset)) {
      hideConfig();
      return;
    }
//    if (saveButton.contains(clickOffset)) {
//      saveSelections();
//      return;
//    }
    if (setDefaultPatternsLightButton.contains(clickOffset)) {
      setDefaultPatterns(1);
      return;
    }
    if (setDefaultPatternsDarkButton.contains(clickOffset)) {
      setDefaultPatterns(2);
      return;
    }
    if (clearAllPatternsButton.contains(clickOffset)) {
      setDefaultPatterns(0);
      return;
    }
    if (nextPatternButton.contains(clickOffset)) {
      var pattern = boxes[activeCellIndex].texture;
      var nextPattern = MyTextures.increment(pattern);
      boxes[activeCellIndex].texture = nextPattern;
      boxes[activeCellIndex].borderTexture = nextPattern;
      bouncerSelection.texture = nextPattern;
      bouncerSelection.borderTexture = nextPattern;
      MyTextures.setTexture(activeCellIndex, nextPattern);
      return;
    }
    if (colorContrastButton.contains(clickOffset)) {
      MyColors.useHighContrast = !MyColors.useHighContrast;
      for (var i = 0 ; i < boxes.length ; i++) {
        if (i > 5) break;
        boxes[i].setColor(MyColors.getColor(i));
        boxes[i].setBorderColor(MyColors.getColor(i));
      }
      return;
    }

    int index = 0;
    for (var box in boxes) {
      if (box == bouncerSelection) break;
      if (box.getRect().contains(clickOffset)) {
        activeCellIndex = index;
        bouncerSelection.color = box.color;
        bouncerSelection.borderColor = Colors.white; // = box.borderColor;
        bouncerSelection.texture = box.texture;
        bouncerSelection.borderTexture = box.borderTexture;

        selectedBoxRect = box.getRect().inflate(5);

        print("Config : Selecting border = " + bouncerSelection.borderTexture.toString() + " , center = " + bouncerSelection.texture.toString());
        break;
      }
      index++;
    }
  }

  void clearAllPatterns() {
    for (var i = 0 ; i < boxes.length ; i++) {
      if (i >= 6) break;
      boxes[i].texture = Textures.none;
      boxes[i].borderTexture = Textures.none;
      MyTextures.setTexture(i, Textures.none);
    }
  }

  void setDefaultPatterns(int defaultSet) {
    List<Textures> defaultsDark = [Textures.largeX, Textures.vertical3, Textures.both3,
      Textures.largeStar, Textures.horizontal3, Textures.both2, Textures.none];
    List<Textures> defaultsLight = [Textures.none, Textures.vertical1, Textures.both1,
      Textures.horizontal1, Textures.horizontal2, Textures.vertical2, Textures.none];
    List<Textures> defaultsEmpty = [Textures.none, Textures.none, Textures.none,
      Textures.none, Textures.none, Textures.none, Textures.none];

    var defaults = defaultsEmpty;

    switch(defaultSet) {
      case 0:
        defaults = defaultsEmpty;
        break;
      case 1:
        defaults = defaultsLight;
        break;
      case 2:
        defaults = defaultsDark;
        break;
    }

    for (var i = 0 ; i < boxes.length ; i++) {
      if (i >= defaults.length) break;
      boxes[i].texture = defaults[i];
      boxes[i].borderTexture = defaults[i];
      MyTextures.setTexture(i, defaults[i]);
    }

    bouncerSelection.texture = boxes[activeCellIndex].texture;
    bouncerSelection.borderTexture = boxes[activeCellIndex].borderTexture;
  }

  void saveSelections() {
    MyColors.setColor(activeCellIndex, bouncerSelection.getColor());
    MyTextures.setTexture(activeCellIndex, bouncerSelection.texture);

    int index = 0;
    for (var b in boxes) {
      if (index == activeCellIndex) {
        b.setColor(bouncerSelection.getColor());
        b.setBorderColor(bouncerSelection.getColor());
        b.texture = bouncerSelection.texture;
        b.borderTexture = bouncerSelection.texture;
        break;
      }
      index++;
    }
  }

  void drawColorContrastButton(Canvas canvas) {
    var width = colorContrastButton.width/2;
    var height = colorContrastButton.height/2;

    var p1 = MyPaints.pYellow;
    var p2 = MyPaints.pRed;
    var p3 = MyPaints.pBlue;
    var p4 = MyPaints.pGreen;
    if (!MyColors.useHighContrast) {
      p1 = CellDrawer().getPaintFromColor(MyColors.colorsContrast[1]);
      p2 = CellDrawer().getPaintFromColor(MyColors.colorsContrast[2]);
      p3 = CellDrawer().getPaintFromColor(MyColors.colorsContrast[3]);
      p4 = CellDrawer().getPaintFromColor(MyColors.colorsContrast[4]);
    }

    canvas.drawRect(Rect.fromLTWH(colorContrastButton.left, colorContrastButton.top, width, height), p1);
    canvas.drawRect(Rect.fromLTWH(colorContrastButton.left, colorContrastButton.top + height, width, height), p2);
    canvas.drawRect(Rect.fromLTWH(colorContrastButton.left + width, colorContrastButton.top, width, height), p3);
    canvas.drawRect(Rect.fromLTWH(colorContrastButton.left + width, colorContrastButton.top + height, width, height), p4);
  }

  void renderConfig(Canvas canvas) {
    if (!visible) return;

    for(var b in boxes) {
      drawer.drawCell(canvas, b);
    }

    canvas.drawRect(selectedBoxRect, pWhite);

    canvas.drawRect(nextPatternButton, MyPaints.pBlue);

    drawColorContrastButton(canvas);

    // canvas.drawRect(saveButton, pGreen);
    canvas.drawRect(cancelButton, pRed);
  }
}

