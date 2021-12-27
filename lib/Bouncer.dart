import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'colors.dart';

enum Direction {
  up, down, left, right
}

class Bouncer
{
  final String LOG_TAG = "Bouncer";
  String name = "";
  int value = 0;
  Color color = Colors.white; // Color.WHITE;
  Color textColor = Colors.black;
  Color borderColor = Colors.black;
  Color fromColor = Colors.black;
  Color toColor = Colors.black;
  Color failColor = Colors.black;
  Textures texture = Textures.none;
  Textures borderTexture = Textures.none;
  double inX = 90;
  double inY = 130;
  double inH = 100;
  double inW = 60;
  double inMargin = 10;
  double inXDelta = 0;
  double inYDelta = 0;
  double inRotationCenterX = 0;
  double inRotationCenterY = 0;
  double inRotationRadius = 0;
  double inRotationAngleRadians = 0;
  double inRotationSpeed = 0;
  double inRotationSpeedMax = 0.4;
  double inRotationSpeedMin = (-0.4);
  double inRotationRadiusDelta = 0;
  double inRotationRadiusMin = 0;
  double inRotationRadiusMax = 0;
  Bouncer centerOfRotationBouncer = null;
  double maxXDelta = 50;
  double maxYDelta = 50;
  double minXDelta = 10;
  double minYDelta = 10;
  double ultimateDelta = (-1);
  double speedDecayRate = 0.01;
  bool reverseAtMaxSpeed = true;
  bool bouncesOffEdges = true;
  bool allowMoveOffScreen = true;
  bool capturedAwaitingDecay = false;
  double inMinHeight = 0;
  double inMaxHeight = 0;
  double inMinWidth = 0;
  double inMaxWidth = 0;
  double inWidthDelta = 0;
  double inHeightDelta = 0;
  bool heightDeltaStickAtMax = false;
  bool heightDeltaStickAtMin = false;
  bool widthDeltaStickAtMax = false;
  bool widthDeltaStickAtMin = false;
  static const int SQUARE = 0;
  static const int TRIANGLE = 1;
  static const int CIRCLE = 2;
  int shape = SQUARE;
  static const int SOLID = 0;
  static const int VERTICAL = 1;
  static const int HORIZONTAL = 2;
  static const int ALTERNATING = 3;
  int flicker = SOLID;
  static const int BOUNCEROTATE = 0;
  static const int BOUNCEUPDOWN = 1;
  static const int BOUNCELEFTRIGHT = 2;
  static const int BOUNCENONE = 3;
  int bounceDirection = BOUNCEROTATE;
  bool erased = false;
  int progress = 0;
  bool isShapeUnderDecay = false;
  int drawDecay = (-100);
  Bouncer parent = null;

  Bouncer()
  {
  }

  Bouncer.complete(String name, Rect location, double margin, double xVelocity, double yVelocity, Color color)
  {
    this.name = name;
    this.color = color;
    this.inX = location.left;
    this.inY = location.top;
    this.inH = location.height;
    this.inW = location.width;
    this.inMargin = margin;
    this.inXDelta = xVelocity;
    this.inYDelta = yVelocity;
    this.inMinHeight = this.inH;
    this.inMaxHeight = this.inH;
    this.inMinWidth = this.inW;
    this.inMaxWidth = this.inW;
  }

  Bouncer.location(String name, Rect location)
  {
    this.name = name;
    this.inX = location.left;
    this.inY = location.top;
    this.inH = location.height;
    this.inW = location.width;
    this.inMinHeight = this.inH;
    this.inMaxHeight = this.inH;
    this.inMinWidth = this.inW;
    this.inMaxWidth = this.inW;
  }

  void setSize(double width, double height)
  {
    this.inW = width;
    this.inH = height;
  }

  void setSizePoint(Point p)
  {
    setSize(p.x, p.y);
  }

  void offsetPosition(double x, double y)
  {
    inX += x;
    inY += y;
  }

  void setPosition(double x, double y)
  {
    inX = x;
    inY = y;
  }

  double getDistanceTo(Bouncer target, double screenWidth, double screenHeight)
  {
    Rect tmpTargetR = target.getRect();
    if (tmpTargetR.left < 0) {
      tmpTargetR = tmpTargetR.translate(screenWidth, 0);
    }
    if (tmpTargetR.top < 0) {
      tmpTargetR = tmpTargetR.translate(0, screenHeight);
    }
    Rect tmpMyR = getRect();
    if (tmpMyR.left < 0) {
      tmpMyR = tmpMyR.translate(screenWidth, 0);
    }
    if (tmpMyR.top < 0) {
      tmpMyR = tmpMyR.translate(0, screenHeight);
    }
    double xDelta = (tmpTargetR.left - tmpMyR.left);
    if (xDelta.abs() > ((screenWidth * 11) ~/ 12)) {
      xDelta = (xDelta.abs() - screenWidth);
    }
    double yDelta = (tmpTargetR.top - tmpMyR.top);
    if (yDelta.abs() > ((screenHeight * 11) ~/ 12)) {
      yDelta = (yDelta.abs() - screenHeight);
    }
    return sqrt((xDelta * xDelta) + (yDelta * yDelta));
  }

  static final Random _rnd = Random();

  void setRandomLocation()
  {
    try {
      if (parent == null) {
        // Log.e(LOG_TAG, "parent must be set before setting a random location.");
        return;
      }
      this.inX = ((_rnd.nextDouble() * (parent.inW - (inMargin * 3))) + inMargin);
      this.inY = ((_rnd.nextDouble() * (parent.inH - (inMargin * 3))) + inMargin);
    } on Exception catch (e) {
//      Log.e(LOG_TAG, "-----------------------");
//      Log.e(LOG_TAG, "-----------------------");
//      Log.e(LOG_TAG, "-----------------------");
//      Log.e(LOG_TAG, "-----------------------");
//      Log.e(LOG_TAG, e.toString());
//      Log.e(LOG_TAG, "-----------------------");
//      Log.e(LOG_TAG, "-----------------------");
//      Log.e(LOG_TAG, "-----------------------");
//      Log.e(LOG_TAG, "-----------------------");
//      Log.e(LOG_TAG, e.getMessage());
    }
  }

  void setMaxSpeed(double maxSpeed)
  {
    setMaxSpeeds(maxSpeed, maxSpeed);
  }

  void setMinSpeed(double minSpeed)
  {
    setMinSpeeds(minSpeed, minSpeed);
  }

  void setMaxSpeeds(double maxXSpeed, double maxYSpeed)
  {
    maxXDelta = maxXSpeed.abs();
    maxYDelta = maxYSpeed.abs();
    if (inXDelta > maxXDelta) {
      inXDelta = maxXDelta;
    }
    if (inXDelta < (-maxXDelta)) {
      inXDelta = (-maxXDelta);
    }
    if (inYDelta > maxYDelta) {
      inYDelta = maxYDelta;
    }
    if (inYDelta < (-maxYDelta)) {
      inYDelta = (-maxYDelta);
    }
  }

  void setMinSpeeds(double minXSpeed, double minYSpeed)
  {
    minXDelta = minXSpeed.abs();
    minYDelta = minYSpeed.abs();
    if ((inXDelta > 0) && (inXDelta < maxXDelta)) {
      inXDelta = maxXDelta;
    }
    if ((inXDelta < 0) && (inXDelta > (-maxXDelta))) {
      inXDelta = (-maxXDelta);
    }
    if ((inYDelta > 0) && (inYDelta < maxYDelta)) {
      inYDelta = maxYDelta;
    }
    if ((inYDelta < 0) && (inYDelta > (-maxYDelta))) {
      inYDelta = (-maxYDelta);
    }
  }

  void setMoveDirection(bool setX, bool movingPositive)
  {
    if (setX) {
      if (movingPositive && (this.inXDelta < 0)) {
        this.inXDelta = (-this.inXDelta);
      }
      if ((!movingPositive) && (this.inXDelta > 0)) {
        this.inXDelta = (-this.inXDelta);
      }
    } else {
      if (movingPositive && (this.inYDelta < 0)) {
        this.inYDelta = (-this.inYDelta);
      }
      if ((!movingPositive) && (this.inYDelta > 0)) {
        this.inYDelta = (-this.inYDelta);
      }
    }
  }

  void transitionToLinear(double linearSpeed)
  {
    double angle = getRotationAngleRadians();
    double rotationSpeed = getRotationSpeed();
    double carTurnRadius = getRotationRadius();
    double totalSpeed = linearSpeed;
    double xSpeed = totalSpeed * cos(angle).abs();
    double ySpeed = totalSpeed * sin(angle).abs();
    double angleNoPi = angle / pi;
    if ((angle > (pi / 2)) && (angle < ((pi * 3) / 2))) {
      xSpeed = (-xSpeed);
    }
    if ((angle > 0) && (angle < pi)) {
      ySpeed = (-ySpeed);
    }
    if (rotationSpeed < 0) {
      ySpeed = (-ySpeed);
      xSpeed = (-xSpeed);
    }
    double x = this.getRect().left;
    double y = this.getRect().top;
    double xChange = (carTurnRadius * sin(angle));
    double yChange = (carTurnRadius * cos(angle));
    xChange = 0;
    yChange = 0;
    if ((angle > (pi ~/ 2)) && (angle < ((pi * 3) ~/ 2))) {
    } else {
    }
    if (angle < pi) {
    }
    this.setSpeed(xSpeed, ySpeed);
    this.setPosition(x + xChange, y + yChange);
    this.setBounceDirection(Bouncer.BOUNCENONE);
    this.setRotationDetails(0, 0, 0);
  }

  void transitionToRotation(double radius, double turnSpeed, bool turnRight)
  {
    Point speeds = getSpeeds();
    double angle = (atan(speeds.x ~/ speeds.y) + pi);
    if (speeds.y > 0) {
      angle -= pi;
    }
    double turnArmAngle;
    if (turnRight) {
      turnArmAngle = (angle + (pi ~/ 2));
      turnSpeed = (-turnSpeed);
    } else {
      turnArmAngle = (angle - (pi ~/ 2));
    }
    while (turnArmAngle > (pi * 2)) {
      turnArmAngle -= (pi * 2);
    }
    while (turnArmAngle < 0) {
      turnArmAngle += (pi * 2);
    }
    double centerX = (getRect().left + getRect().width);
    double centerY = (getRect().top + getRect().height);
    double changeX = (radius * sin(turnArmAngle));
    double changeY = (radius * cos(turnArmAngle));
    changeX = (-changeX);
    changeY = (-changeY);
    this.setRotationCenter(centerX + changeX, centerY + changeY);
    this.setRotationDetails(radius, turnArmAngle, turnSpeed);
    this.setBounceDirection(Bouncer.BOUNCEROTATE);
    this.setSpeed(0, 0);
  }

  RotationData getRotation()
  {
    return new RotationData(this.inRotationRadius, this.inRotationAngleRadians, this.inRotationSpeed, this.inRotationCenterX, this.inRotationCenterY);
  }

  void setRotation(RotationData rd)
  {
    setRotationDetails(rd.radius, rd.angle, rd.rotationSpeed);
  }

  void setRotationRadius(double radius)
  {
    this.inRotationRadius = radius;
  }

  void setRotationDetails(double radius, double angle, double rotationSpeed)
  {
    this.inRotationRadius = radius;
    this.inRotationAngleRadians = angle;
    this.inRotationSpeed = rotationSpeed;
  }

  void setRotationRadiusDelta(double delta)
  {
    this.inRotationRadiusDelta = delta;
  }

  void setRotationRadiusMinMax(double min, double max)
  {
    this.inRotationRadiusMin = min;
    this.inRotationRadiusMax = max;
  }

  double getRotationRadius()
  {
    return this.inRotationRadius;
  }

  double getRotationAngleRadians()
  {
    return this.inRotationAngleRadians;
  }

  void setRotationSpeed(double rotationSpeed)
  {
    this.inRotationSpeed = rotationSpeed;
  }

  double getRotationSpeed()
  {
    return this.inRotationSpeed;
  }

  void setRotationCenter(double x, double y)
  {
    this.inRotationCenterX = x;
    this.inRotationCenterY = y;
  }

  void setRotationCenterAsSelf()
  {
    this.inRotationCenterX = (inX + (inW ~/ 2));
    this.inRotationCenterY = (inY + (inH ~/ 2));
  }

  void changeRotationSpeed(double deltaRotationSpeed)
  {
    this.inRotationSpeed += deltaRotationSpeed;
    if (this.inRotationSpeed > inRotationSpeedMax) {
      this.inRotationSpeed = inRotationSpeedMax;
    }
    if (this.inRotationSpeed < inRotationSpeedMin) {
      this.inRotationSpeed = inRotationSpeedMin;
    }
  }

  void setRotationCenterBouncer(Bouncer centerOfRotationBouncer)
  {
    this.centerOfRotationBouncer = centerOfRotationBouncer;
  }

  Bouncer getRotationCenterBouncer()
  {
    return this.centerOfRotationBouncer;
  }

  void setUltimateSpeed(double ultimateSpeed)
  {
    ultimateDelta = ultimateSpeed;
  }

  void setSpeedDecay(double decayRate)
  {
    speedDecayRate = decayRate;
  }

  void setBounceAtMaxSpeed(bool bounceAtMaxSpeed)
  {
    reverseAtMaxSpeed = bounceAtMaxSpeed;
  }

  double amountToSlow(double speed, double max, double rate)
  {
    double slow = 0;
    if (speed.abs() > max.abs()) {
      double ratio = speed.abs() / max.abs();
      slow = ((rate * ratio) * 3);
    }
    return slow;
  }

  void adjustToMaxSpeed()
  {
    if (reverseAtMaxSpeed) {
      if (inXDelta > maxXDelta) {
        inXDelta = (-maxXDelta);
      }
      if (inYDelta > maxYDelta) {
        inYDelta = (-maxYDelta);
      }
      if (inXDelta < (-maxXDelta)) {
        inXDelta = maxXDelta;
      }
      if (inYDelta < (-maxYDelta)) {
        inYDelta = maxYDelta;
      }
    } else {
      inXDelta -= amountToSlow(inXDelta, maxXDelta, speedDecayRate);
      inYDelta -= amountToSlow(inYDelta, maxYDelta, speedDecayRate);
      inXDelta += amountToSlow(inXDelta, maxXDelta, speedDecayRate);
      inYDelta += amountToSlow(inYDelta, maxYDelta, speedDecayRate);
    }
    if (ultimateDelta > 0) {
      if (inXDelta > ultimateDelta) {
        inXDelta = ultimateDelta;
      }
      if (inXDelta < (-ultimateDelta)) {
        inXDelta = (-ultimateDelta);
      }
      if (inYDelta > ultimateDelta) {
        inYDelta = ultimateDelta;
      }
      if (inYDelta < (-ultimateDelta)) {
        inYDelta = (-ultimateDelta);
      }
    }
  }

  void setRandomSpeedWithNegative(double minX, double maxX, double minY, double maxY)
  {
    setRandomSpeedFull(minX, maxX, minY, maxY);
    if (_rnd.nextDouble() > 0.5) {
      this.inXDelta *= (-1);
    }
    if (_rnd.nextDouble() > 0.5) {
      this.inYDelta *= (-1);
    }
  }

  void setRandomSpeed(double maxSpeed)
  {
    setRandomSpeedFull(-maxSpeed, maxSpeed, -maxSpeed, maxSpeed);
  }

  void setRandomSpeedFull(double minSpeedX, double maxSpeedX, double minSpeedY, double maxSpeedY)
  {
    this.inXDelta = (maxSpeedX - (_rnd.nextDouble() * (maxSpeedX - minSpeedX)));
    this.inYDelta = (maxSpeedY - (_rnd.nextDouble() * (maxSpeedY - minSpeedY)));
    adjustToMaxSpeed();
  }

  void setSpeed(double speedX, double speedY)
  {
    this.inXDelta = speedX;
    this.inYDelta = speedY;
    adjustToMaxSpeed();
  }

  Point getSpeeds()
  {
    Point pointSpeeds = new Point(this.inXDelta, this.inYDelta);
    return pointSpeeds;
  }

  Point getMaxSpeeds()
  {
    Point pointMaxSpeeds = new Point(this.maxXDelta, this.maxYDelta);
    return pointMaxSpeeds;
  }

  void deltaSpeed(double speedX, double speedY)
  {
    double preSpeedX = inXDelta;
    double preSpeedY = inYDelta;
    this.inXDelta += speedX;
    this.inYDelta += speedY;
    adjustToMaxSpeed();
  }

  bool isMoving()
  {
    return (inXDelta != 0) || (inYDelta != 0);
  }

  void deltaSpeedPoint(Point delta)
  {
    deltaSpeed(delta.x, delta.y);
  }

  void setColorNoRotateChange(Color newColor)
  {
    this.color = newColor;
  }

  void setColor(Color newColor)
  {
    this.color = newColor;
    setRotationDetails(0, 0, 0);
  }

  void setBorderColor(Color newColor)
  {
    this.borderColor = newColor;
  }

  void setTextColor(Color newColor)
  {
    this.textColor = newColor;
  }

  Color getTextColor()
  {
    return this.textColor;
  }

  void setFromColor(Color newColor)
  {
    this.fromColor = newColor;
  }

  void setToColor(Color newColor)
  {
    this.toColor = newColor;
  }

  void setFailColor(Color newColor)
  {
    this.failColor = newColor;
  }

  void setCaptured(bool isCaptured)
  {
    this.capturedAwaitingDecay = isCaptured;
  }

  bool isCaptured()
  {
    return this.capturedAwaitingDecay;
  }

  void setBounce(bool willBounceWhenHittingAnEdge)
  {
    this.bouncesOffEdges = willBounceWhenHittingAnEdge;
  }

  void setAllowMoveOffScreen(bool allowMoveOffScreen)
  {
    this.allowMoveOffScreen = allowMoveOffScreen;
  }

  void setGrowSpeed(double width, double height)
  {
    this.inWidthDelta = width;
    this.inHeightDelta = height;
  }

  Bouncer setParent(Bouncer parent)
  {
    this.parent = parent;
    return this;
  }

  Bouncer getParent()
  {
    return this.parent;
  }

  bool isAncestorOf(Bouncer parent)
  {
    bool result = false;
    if (this == parent) {
      result = true;
    }
    Bouncer b = parent;
    return result;
  }

  Bouncer copy(Bouncer source)
  {
    this.name = source.name;
    this.inX = source.inX;
    this.inY = source.inY;
    this.inH = source.inH;
    this.inW = source.inW;
    this.inMargin = source.inMargin;
    this.inXDelta = source.inXDelta;
    this.inYDelta = source.inYDelta;
    return this;
  }

  String getName()
  {
    return name;
  }

  void setName(String name)
  {
    this.name = name;
  }

  int getValue()
  {
    return this.value;
  }

  void setValue(int value)
  {
    this.value = value;
  }

  Rect getRect()
  {
    Rect location = new Rect.fromLTWH(inX, inY, inW, inH);
    return location;
  }

  void setRect(Rect rect)
  {
    inX = rect.left;
    inY = rect.top;
    inW = rect.width;
    inH = rect.height;
  }

  void insetRect(double inset)
  {
    Rect rect = new Rect.fromLTWH(inX, inY, inX + inW, inY + inH);
    rect.inflate(inset); // .inset(inset, inset);
    inX = rect.left;
    inY = rect.top;
    inW = rect.width;
    inH = rect.height;
  }

  bool isErased()
  {
    return erased;
  }

  void erase()
  {
    erased = true;
  }

  void unErase()
  {
    erased = false;
  }

  Color getColor()
  {
    return this.color;
  }

  Color getBorderColor()
  {
    return this.borderColor;
  }

  Color getFromColor()
  {
    return this.fromColor;
  }

  Color getToColor()
  {
    return this.toColor;
  }

  Color getFailColor()
  {
    return this.failColor;
  }

  int getShape()
  {
    return this.shape;
  }

  void setShape(int shape)
  {
    this.shape = shape;
  }

  void setFlicker(int flicker)
  {
    this.flicker = flicker;
  }

  int getFlicker()
  {
    return this.flicker;
  }

  void setBounceDirection(int bounce)
  {
    this.bounceDirection = bounce;
  }

  int getBounceDirection()
  {
    return this.bounceDirection;
  }

  int getProgress()
  {
    return this.progress;
  }

  void setProgress(int progress)
  {
    this.progress = progress;
  }

  void setUnderDecay(bool underDecay)
  {
    isShapeUnderDecay = underDecay;
  }

  bool isUnderDecay()
  {
    return isShapeUnderDecay;
  }

  void setDrawDecay(int decay)
  {
    this.drawDecay = decay;
  }

  int getDrawDecay()
  {
    return this.drawDecay;
  }

  void causeDrawDecay()
  {
    if (!isDrawDecayZero()) {
      this.drawDecay--;
    }
  }

  bool isDrawDecayZero()
  {
    return (this.drawDecay < 1) && (this.drawDecay > (-99));
  }



Bouncer bounce(Direction d)
  {
    switch (d) {
      case Direction.up:
        if (this.inYDelta > 0) {
          this.inYDelta *= (-1);
        }
        break;
      case Direction.down:
        if (this.inYDelta < 0) {
          this.inYDelta *= (-1);
        }
        break;
      case Direction.right:
        if (this.inXDelta < 0) {
          this.inXDelta *= (-1);
        }
        break;
      case Direction.left:
        if (this.inXDelta > 0) {
          this.inXDelta *= (-1);
        }
        break;
    }
    return this;
  }

  void move()
  {
    if (this.parent == null) {
      return;
    }
    Rect boundaries = this.parent.getRect();
    if ((inH + inHeightDelta) > inMaxHeight) {
      if (heightDeltaStickAtMax) {
        inHeightDelta = 0;
        inH = inMaxHeight;
      } else {
        inHeightDelta = ((-1) * inHeightDelta).abs();
      }
    }
    if ((inH + inHeightDelta) < inMinHeight) {
      if (heightDeltaStickAtMin) {
        inHeightDelta = 0;
        inH = inMinHeight;
      } else {
        inHeightDelta = inHeightDelta.abs();
      }
    }
    inH = (inH + inHeightDelta);
    if ((inW + inWidthDelta) > inMaxWidth) {
      if (widthDeltaStickAtMax) {
        inW = inMaxWidth;
        inWidthDelta = 0;
      } else {
        inWidthDelta = ((-1) * inWidthDelta).abs();
      }
    }
    if ((inW + inWidthDelta) < inMinWidth) {
      if (widthDeltaStickAtMin) {
        inW = inMinWidth;
        inWidthDelta = 0;
      } else {
        inWidthDelta = inWidthDelta.abs();
      }
    }
    inW = (inW + inWidthDelta);
    fixShapeLocation();
    if (inRotationRadius == 0) {
      inX += inXDelta;
      inY += inYDelta;
      int maxStep = 20;
      Bouncer parent = this.parent;
      while ((maxStep-- > 0) && (parent != null)) {
        inX += parent.inXDelta;
        inY += parent.inYDelta;
        parent = parent.parent;
      }
      if (!this.reverseAtMaxSpeed) {
        adjustToMaxSpeed();
      }
    } else {
      inRotationCenterX += inXDelta;
      inRotationCenterY += inYDelta;
      if (inRotationRadiusDelta != 0) {
        inRotationRadius += inRotationRadiusDelta;
        if (inRotationRadius < inRotationRadiusMin) {
          inRotationRadius = inRotationRadiusMin;
          inRotationRadiusDelta = (-inRotationRadiusDelta);
        }
        if (inRotationRadius > inRotationRadiusMax) {
          inRotationRadius = inRotationRadiusMax;
          inRotationRadiusDelta = (-inRotationRadiusDelta);
        }
      }
      inRotationAngleRadians += inRotationSpeed;
      if (inRotationAngleRadians > (pi * 2)) {
        inRotationAngleRadians -= (pi * 2);
      }
      if (inRotationAngleRadians < 0) {
        inRotationAngleRadians += (pi * 2);
      }
      inX = inRotationCenterX;
      inY = inRotationCenterY;
      if (centerOfRotationBouncer != null) {
        inX = (centerOfRotationBouncer.getRect().left + (centerOfRotationBouncer.getRect().width / 2));
        inY = (centerOfRotationBouncer.getRect().top + (centerOfRotationBouncer.getRect().height / 2));
      }
      if ((this.bounceDirection == BOUNCEROTATE) || (this.bounceDirection == BOUNCELEFTRIGHT)) {
        inX += (inRotationRadius * sin(inRotationAngleRadians));
      }
      if ((this.bounceDirection == BOUNCEROTATE) || (this.bounceDirection == BOUNCEUPDOWN)) {
        inY += (inRotationRadius * cos(inRotationAngleRadians));
      }
      if (this.bounceDirection == BOUNCEROTATE) {
        inX -= (getRect().width / 2);
        inY -= (getRect().height / 2);
      }
      if (!allowMoveOffScreen) {
        int maxTry = 200;
        while ((maxTry-- > 0) && (inX > boundaries.width)) {
          inX -= boundaries.width;
        }
        while ((maxTry-- > 0) && (inX < 0)) {
          inX += boundaries.width;
        }
        while ((maxTry-- > 0) && (inY < 0)) {
          inY += boundaries.height;
        }
        while ((maxTry-- > 0) && (inY > boundaries.height)) {
          inY -= boundaries.height;
        }
      }
    }
  }

  void moveDraggedShape(double deltaX, double deltaY)
  {
    inX += deltaX;
    inY += deltaY;
  }

  void fixShapeLocation()
  {
    if (parent == null) {
      return;
    }
    if (allowMoveOffScreen) {
      return;
    }
    Rect boundaries = parent.getRect();
    boundaries.deflate(parent.inMargin);
    bool parentMoving = parent.isMoving();
    Rect gpRect = parent.getRect();
    if (parent.parent != null) {
      gpRect = parent.parent.getRect();
    }
    double grandParentWidth = gpRect.width;
    double grandParentHeight = gpRect.height;
    if (bouncesOffEdges) {
      if (parentMoving) {
        if (inX < boundaries.left) {
          if ((inX + gpRect.width) < boundaries.right) {
            inX += grandParentWidth;
          } else {
            inX = boundaries.left;
            bounce(Direction.right);
          }
        } else {
          if ((inX + inW) > boundaries.right) {
            if ((inX - grandParentWidth) > boundaries.left) {
              inX -= grandParentWidth;
            } else {
              inX = (boundaries.right - inW);
              bounce(Direction.left);
            }
          }
        }
        if (inY < boundaries.top) {
          if ((inY + grandParentHeight) < boundaries.bottom) {
            inY += grandParentHeight;
          } else {
            inY = boundaries.top;
            bounce(Direction.down);
          }
        } else {
          if ((inY + inH) > boundaries.bottom) {
            if ((inY - grandParentHeight) > boundaries.top) {
              inY -= grandParentHeight;
            } else {
              if (inY > (boundaries.bottom * 2)) {
//                Log.e(LOG_TAG, (((("inY = " + inY) + ", gpH = ") + grandParentHeight) + ", boundaries.top = ") + boundaries.top);
              }
              inY = (boundaries.bottom - inH);
              bounce(Direction.up);
            }
          }
        }
      } else {
        if (inX < boundaries.left) {
          inX = boundaries.left;
          bounce(Direction.right);
        } else {
          if ((inX + inW) > boundaries.right) {
            inX = (boundaries.right - inW);
            bounce(Direction.left);
          }
        }
        if (inY < boundaries.top) {
          inY = boundaries.top;
          bounce(Direction.down);
        } else {
          if ((inY + inH) > boundaries.bottom) {
            inY = (boundaries.bottom - inH);
            bounce(Direction.up);
          }
        }
      }
    } else {
      if (inRotationRadius == 0) {
        if (inX < boundaries.left) {
          inX = boundaries.right;
        } else {
          if (inX > boundaries.right) {
            inX = boundaries.left;
          }
        }
        if (inY < boundaries.top) {
          inY = boundaries.bottom;
        } else {
          if (inY > boundaries.bottom) {
            inY = boundaries.top;
          }
        }
      } else {
        if (inRotationCenterX < boundaries.left) {
          inRotationCenterX = boundaries.right;
        } else {
          if (inRotationCenterX > boundaries.right) {
            inRotationCenterX = boundaries.left;
          }
        }
        if (inRotationCenterY < boundaries.top) {
          inRotationCenterY = boundaries.bottom;
        } else {
          if (inRotationCenterY > boundaries.bottom) {
            inRotationCenterY = boundaries.top;
          }
        }
      }
    }
  }

  void changeDimension(bool changingWidth, bool changingMax, double amount)
  {
    if (changingWidth) {
      if (changingMax) {
        inMaxWidth += amount;
      } else {
        inMinWidth += amount;
      }
    } else {
      if (changingMax) {
        inMaxHeight += amount;
      } else {
        inMinHeight += amount;
      }
    }
  }

  void setDimension(bool changingWidth, bool changingMax, double amount)
  {
    if (changingWidth) {
      if (changingMax) {
        inMaxWidth = amount;
      } else {
        inMinWidth = amount;
      }
    } else {
      if (changingMax) {
        inMaxHeight = amount;
      } else {
        inMinHeight = amount;
      }
    }
  }

  void setStick(bool changingWidth, bool changingMax, bool stickHere)
  {
    if (changingWidth) {
      if (changingMax) {
        widthDeltaStickAtMax = stickHere;
      } else {
        widthDeltaStickAtMin = stickHere;
      }
    } else {
      if (changingMax) {
        heightDeltaStickAtMax = stickHere;
      } else {
        heightDeltaStickAtMin = stickHere;
      }
    }
  }
}

class RotationData
{
  double radius;
  double angle;
  double rotationSpeed;
  double centerX;
  double centerY;

  RotationData(double r, double a, double rs, double centerX, double centerY)
  {
    this.radius = r;
    this.angle = a;
    this.rotationSpeed = rs;
    this.centerX = centerX;
    this.centerY = centerY;
  }
}