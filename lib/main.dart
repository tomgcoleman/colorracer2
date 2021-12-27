import 'dart:math';

import 'package:colorracer2/state.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';

import 'Bouncer.dart';
import 'cellDrawer.dart';
import 'colors.dart';
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // remove banner, page navigation
  await Flame.util.fullScreen();
  // ignore device rotation
  await Flame.util.setPortraitUpOnly();

  final size = await Flame.util.initialDimensions();

  final game = MyGame(size);
  runApp(game.widget);
}

enum WinState {
  topHasWon,
  botHasWon,
  undecided,
}

enum Direction {
  up,
  down,
  left,
  right,
  none,
}

class Box extends Component with Resizable {
  double x; // perthou of container
  double y; // perthou of container
  double vx;
  double vy;
  Paint color;
  double boxWidth = 80;
  double boxHeight = 80;
  String a = "";

  static Size screenSize;

  static void setScreenSize(Size size) {
    Box.screenSize = size;
  }

  Box(double x, double y, double vx, double vy, int color) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.color = Paint()..color = Color(color);

    if (Box.screenSize != null) {
      this.x -= boxWidth * 500 / Box.screenSize.width;
      this.y -= boxHeight * 500 / Box.screenSize.height;
    }
  }

  @override
  void update(double t) {
    this.x += vx * t;
    this.y += vy * t;

    if (this.x < 0 && vx < 0) vx = -vx;
    if (this.y < 0 && vy < 0) vy = -vy;
    if (this.x > 1000 && vx > 0) vx = -vx;
    if (this.y > 1000 && vy > 0) vy = -vy;
  }

  @override
  void render(Canvas c) {
    c.drawRect(Rect.fromLTWH(size.width * x / 1000, size.height * y / 1000, boxWidth, boxHeight), color);
  }
}

class Bg {
  Rect drawSpace;

  Paint pBackground = MyPaints.pBlack;
  Paint pWinBackground = MyPaints.pYellow;
  bool useWinColor = false;

  Bg(Size size, bool topHalf) {
    if (topHalf) {
      drawSpace = Rect.fromLTRB(0, 0, size.width, size.height/2);
    } else {
      drawSpace = Rect.fromLTRB(0, size.height/2, size.width, size.height);
    }
  }

  void setWin(bool isWin) {
    useWinColor = isWin;
  }

  void renderBackground(Canvas c) {
    if (useWinColor) {
      c.drawRect(drawSpace, pWinBackground);
    } else {
      c.drawRect(drawSpace, pBackground);
    }
  }
}

class MyGame extends BaseGame with MultiTouchTapDetector, KeyboardEvents {
  static final Random _rnd = Random();
  Bg topBackground;
  Bg botBackground;
  static Size screenSize;

  StateDetector stateDetector = StateDetector();
  Config config = Config();
  bool configWasShowing = false;
  bool needToCaptureConfigValues = false;

  WinState winner = WinState.undecided;
  bool topHasWon = false;
  bool botHasWon = false;

  bool showResetButton = false;
  int timeRemainingForResetButton = 0;

  int screenWidth = 400;
  int screenHeight = 800;

  int rowCount = -1;
  int colCount = -1;

  Bouncer screen = new Bouncer();

  List<Bouncer> topCells = new List.empty(growable: true);
  List<Bouncer> botCells = new List.empty(growable: true);

  Rect topBoard = new Rect.fromLTWH(0, 0, 0, 0);
  Rect botBoard = new Rect.fromLTWH(0, 0, 0, 0);
  Rect topSideStrip = new Rect.fromLTWH(0, 0, 0, 0);
  Rect botSideStrip = new Rect.fromLTWH(0, 0, 0, 0);
  Rect topBackStrip = new Rect.fromLTWH(0, 0, 0, 0);
  Rect botBackStrip = new Rect.fromLTWH(0, 0, 0, 0);
  Rect centerStrip = new Rect.fromLTWH(0, 0, 0, 0);
  Rect resetButton = new Rect.fromLTWH(0,0,0,0);

  Rect configA = new Rect.fromLTWH(0,0,0,0);
  Rect configB = new Rect.fromLTWH(0,0,0,0);
  bool configASelected = false;
  bool configBSelected = false;
  bool drawConfigButtons = false;

  Point topBoardCenter = new Point(0, 0);
  Point botBoardCenter = new Point(0, 0);

  Bouncer gapForCellToMoveInto = null;
  int valueForCellToMoveInto = -1;
  Bouncer gapForCellToMoveOutOf = null;
  int valueForCellToMoveOutOf = -1;
  Bouncer movingCell = null;
  bool isMoving = false;
  bool movingHasBeenAcceleratedByTap = false;
  double xMove = 0;
  double yMove = 0;
  int cellSizeWidth;
  int cellSizeHeight;

  MyGame(Size size){
    Box.setScreenSize(size);
    screenSize = Size(size.width, size.height);
    topBackground = Bg(size, true);
    botBackground = Bg(size, false);

    config.setSize(Rect.fromLTRB(0, 0, size.width, size.height));
    storeSize(size.width.toInt(), size.height.toInt());

    resetGame();
  }

  void resetGame() {
    winner = WinState.undecided;
    topHasWon = false;
    botHasWon = false;
    topBackground.setWin(false);
    botBackground.setWin(false);

    prepareLevel(1, 5, 5);

    prepareGameCells();
  }

  // move stuff based on tap location
  Bouncer getCellFromTap(double inX, double inY) {
    Bouncer b = null;

    List<Bouncer> checkMe = topCells;
    if (inY > screenHeight/2) {
      checkMe = botCells;
    }

    for (int col = 0 ; col < colCount ; col++) {
      for (int row = 0 ; row < rowCount ; row++) {
        if (checkMe[col + row * colCount].getRect().contains(Offset(inX, inY))) {
          b = checkMe[col + row * colCount];
          return b;
        }
      }
    }

    return b;
  }

  Bouncer getCellFromKeyAction(bool isTopPart, Direction dir, bool isShiftHeld) {
    Bouncer blackCell = null;
    int voidRow = -1;
    int voidCol = -1;
    var group = isTopPart ? topCells : botCells;
    for (int row = 0 ; row < rowCount ; row++) {
      for (int col = 0 ; col < colCount ; col++) {
        if (group[col + row*colCount].getColor() == Colors.black) {
          blackCell = group[col + row*colCount];
          voidRow = row;
          voidCol = col;
          break;
        }
        if (blackCell != null) break;
      }
    }
    if (blackCell == null) return null;
    switch(dir) {
      case Direction.right:
        voidCol--;
        if (isShiftHeld && voidCol > 0) voidCol = 0;
        break;
      case Direction.down:
        voidRow--;
        if (isShiftHeld && voidRow > 0) voidRow = 0;
        break;
      case Direction.left:
        voidCol++;
        if (isShiftHeld && voidCol < colCount-1) voidCol = colCount-1;
        break;
      case Direction.up:
        voidRow++;
        if (isShiftHeld && voidRow < rowCount-1) voidRow = rowCount-1;
        break;
      case Direction.none:
        break;
    }
    if (voidCol < 0 || voidRow < 0 || voidCol >= colCount || voidRow >= rowCount) return null;
    return group[voidCol + voidRow * rowCount];
  }
  // @override
  void onKeyEvent(RawKeyEvent event) {

    // only respond to key down
    if (!event.isKeyPressed(event.logicalKey)) return;

    bool isTop = true;
    Direction dir = Direction.none;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      isTop = false;
      dir = Direction.left;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      isTop = false;
      dir = Direction.up;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      isTop = false;
      dir = Direction.right;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      isTop = false;
      dir = Direction.down;
    }
    if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.enter) {
      if (this.winner != WinState.undecided) {
        resetGame();
      }
    }

    switch(event.character) {
      case 'a':
      case 'A':
        isTop = true;
        dir = Direction.left;
        break;
      case 'l':
      case 'L':
        isTop = false;
        dir = Direction.left;
        break;
      case 'w':
      case 'W':
        isTop = true;
        dir = Direction.up;
        break;
      case 'p':
      case 'P':
        isTop = false;
        dir = Direction.up;
        break;
      case 's':
      case 'S':
        isTop = true;
        dir = Direction.down;
        break;
      case ';':
      case ':':
        isTop = false;
        dir = Direction.down;
        break;
      case 'd':
      case 'D':
        isTop = true;
        dir = Direction.right;
        break;
      case '\'':
      case '\"':
        isTop = false;
        dir = Direction.right;
        break;
      default:
    }

    if (dir == Direction.none) return;

    bool isShiftHeld = isTop ? event.isKeyPressed(LogicalKeyboardKey.shiftLeft) : event.isKeyPressed(LogicalKeyboardKey.shiftRight);


    var inputCell = getCellFromKeyAction(isTop, dir, isShiftHeld);

    moveCell(inputCell);
  }

  void showConfig() {
    configWasShowing = true;
    needToCaptureConfigValues = true;
    configASelected = false;
    configBSelected = false;
    config.showConfig();
  }

  List<int> tapsHeld = List.empty(growable: true);

  @override
  void onTapUp(int pointerId, TapUpDetails details) {
    // todo: detect which pointers are active.
    // tapsHeld.remove(pointerId);
    tapsHeld.clear();
    // print("CRView : pointer id : " + pointerId.toString() + ", holdCount = " + tapsHeld.length.toString());
  }

  @override
  void onTapDown(int pointerId, TapDownDetails details) {
    double xClick = details.globalPosition.dx;
    double yClick = details.globalPosition.dy;
    var clickOffset = Offset(xClick, yClick);

    tapsHeld.add(pointerId);

    // print("CRView : pointer id : " + pointerId.toString() + ", holdCount = " + tapsHeld.length.toString() + " config showing? " + config.visible.toString());

    if (config.visible) {
      config.onClick(xClick, yClick);
      return;
    }

    if (configA.contains(clickOffset)) {
      configASelected = true;
      if (configBSelected) {
        showConfig();
      }
      return;
    }
    if (configB.contains(clickOffset)) {
      configBSelected = true;
      if (configASelected) {
        showConfig();
      }
      return;
    }

    configASelected = false;
    configBSelected = false;

    if (tapsHeld.length == 3) {
      showConfig();
      return;
    }

    Bouncer moveMe = getCellFromTap(xClick, yClick);
    moveCell(moveMe);
    drawConfigButtons = moveMe == null;

    if (this.winner != WinState.undecided) {
      if (resetButton.contains(Offset(xClick, yClick))) {
        resetGame();
      }
    }
    super.onTapDown(pointerId, details);
  }

  void moveCell(Bouncer moveMe) {
    if (moveMe == null) {
      // Log.e("CRView", "cell is null : " + moveMe);
      return;
    }
    List<Bouncer> group = null;
    int cellCol = -1;
    int cellRow = -1;

    for (int row = 0 ; row < rowCount ; row++) {
      for (int col = 0; col < colCount; col++) {
        if (topCells[col + row*colCount] == moveMe) {
          group = topCells;
          cellCol = col;
          cellRow = row;
          break;
        }
        if (botCells[col + row*colCount] == moveMe) {
          group = botCells;
          cellCol = col;
          cellRow = row;
          break;
        }
      }
      if (group != null) break;
    }
    if (group == null) {
      // Log.e("CRView", "could not find cell in group");
      return;
    }

    Bouncer blackCell = null;
    int voidRow = -1;
    int voidCol = -1;
    for (int row = 0 ; row < rowCount ; row++) {
      for (int col = 0 ; col < colCount ; col++) {
        if (group[col + row*colCount].getColor() == Colors.black) {
          blackCell = group[col + row*colCount];
          voidRow = row;
          voidCol = col;
          break;
        }
        if (blackCell != null) break;
      }
    }
    if (blackCell == null) {
      //Log.e("CRView", "failed to find black cell");
      return;
    }

    if (cellCol != voidCol && cellRow != voidRow) {
      // todo: get something close.
      return;
    }
    int colDelta = cellCol - voidCol;
    int rowDelta = cellRow - voidRow;
    if (colDelta != 0) {
      // +1 or -1
      colDelta = colDelta ~/ colDelta.abs();
    }
    if (rowDelta != 0) {
      // +1 or -1
      rowDelta = rowDelta ~/ rowDelta.abs();
    }
    int row = voidRow;
    int col = voidCol;
    int maxTry = 100;
    while (row != cellRow || col != cellCol) {
      Bouncer slideMe = group[col + row * colCount];
      Bouncer fromMe = group[(col+colDelta) + (row+rowDelta) * colCount];

      slideMe.setColor(fromMe.getColor());
      slideMe.texture = fromMe.texture;
      // todo: if going to slide, then border is drawn separate.
//            slideMe.setBorderColor(fromMe.getBorderColor());
//            slideMe.setPosition(fromMe.getRect().left, fromMe.getRect().top);
//            slideMe.setSpeed(-colDelta * 10, -rowDelta * 10);

      row += rowDelta;
      col += colDelta;
      if (maxTry-- < 0) break;
      if (fromMe == moveMe) break;
    }
    moveMe.setColor(Colors.black);

    var newTopHasWon = stateDetector.checkForWinState(topCells);
    var newBotHasWon = stateDetector.checkForWinState(botCells);

    if (newTopHasWon != topHasWon) {
      topHasWon = newTopHasWon;
      if (winner == WinState.undecided && newTopHasWon) {
        winner = WinState.topHasWon;
        topBackground.setWin(topHasWon);
      }
    }
    if (newBotHasWon != botHasWon) {
      botHasWon = newBotHasWon;
      if (winner == WinState.undecided && botHasWon) {
        winner = WinState.botHasWon;
        botBackground.setWin(botHasWon);
      }
    }
  }

  Paint getPaintFromColorAlpha(Color color, int alpha) {
    Paint p = getPaintFromColor(color);
    // p.setAlpha(alpha);
    return p;
  }

  // todo: store paint within item to be drawn
  Paint getPaintFromColor(Color color) {
    Paint p = Paint()..color = color;
    return p;
  }

  CellDrawer cellDrawer = CellDrawer();

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (config.visible) {
      config.renderConfig(canvas);
      return;
    }

    if (needToCaptureConfigValues) {
      resetGame();
      needToCaptureConfigValues = false;
    }


    topBackground.renderBackground(canvas);
    botBackground.renderBackground(canvas);

    topCells.forEach((b) {
      cellDrawer.drawCell(canvas, b);
    });

    botCells.forEach((b) {
      cellDrawer.drawCell(canvas, b);
    });

    if (this.winner != WinState.undecided) {
      canvas.drawCircle(resetButton.center, resetButton.width/2, MyPaints.pGreen);
    }

    if (drawConfigButtons) {
      if (!configASelected)
        canvas.drawOval(configA, MyPaints.pCyan);
      if (!configBSelected)
        canvas.drawOval(configB, MyPaints.pCyan);
    }
  }

  @override
  void update(double t) {
    super.update(t);
  }

  void storeSize(int width, int height) {
    this.screenWidth = width;
    this.screenHeight = height;

    screen.setPosition(0, 0);
    screen.setSize(width.toDouble(), height.toDouble());

    showResetButton = false;

    centerStrip = new Rect.fromLTRB(
        0, screenHeight * 7 / 15, screenWidth.toDouble(),
        screenHeight * 8 / 15);
    double buttonWidth = centerStrip.height;
    resetButton = new Rect.fromLTWH(
        centerStrip.center.dx - buttonWidth / 2, centerStrip.top, buttonWidth,
        buttonWidth);

    // each player has tool kit to the right of, or below play field
    topSideStrip = new Rect.fromLTRB(0, 0, 0, 0);
    topBackStrip = new Rect.fromLTRB(0, 0, 0, 0);
    botSideStrip = new Rect.fromLTRB(
        screenWidth.toDouble(), screenHeight.toDouble(), screenWidth.toDouble(),
        screenHeight.toDouble());
    botBackStrip =
    new Rect.fromLTRB(0, screenHeight.toDouble(), 0, screenHeight.toDouble());

    if (screenHeight * 7 / 15 < screenWidth) {
      // wide screen, use side bar to show tools
      topSideStrip =
      new Rect.fromLTRB(0, 0, screenWidth * 2 / 15, centerStrip.top);
      botSideStrip = new Rect.fromLTRB(
          screenWidth * 13 / 15, centerStrip.bottom, screenWidth.toDouble(),
          screenHeight.toDouble());

      double step = topSideStrip.width;
      double size = topSideStrip.width * 12 / 15;
      double left = topSideStrip.left + topSideStrip.width * 1.5 / 15;
      double top = topSideStrip.top + step * 2;
//      topBlockTool .setPosition(left, top);
//      topBlockTool.setSize(size, size);
//      topWhiteOutTool.setPosition(left, top - step);
//      topWhiteOutTool.setSize(size, size);
//      topTornadoTool.setPosition(left, top - step * 2);
//      topTornadoTool.setSize(size, size);

      left = botSideStrip.left + botSideStrip.width * 1.5 / 15;
      step = botSideStrip.width;
      top = botSideStrip.top + botSideStrip.height / 2;
//      botBlockTool.setPosition(left, top);
//      botBlockTool.setSize(size, size);
//      botWhiteOutTool.setPosition(left, top+step);
//      botWhiteOutTool.setSize(size, size);
//      botTornadoTool.setPosition(left, top+step*2);
//      botTornadoTool.setSize(size, size);

    } else {
      // narrow screen, use back strip to show tools
      topBackStrip =
      new Rect.fromLTRB(0, 0, screenWidth.toDouble(), screenHeight * 2 / 15);
      botBackStrip = new Rect.fromLTRB(
          0, screenHeight * 13 / 15, screenWidth.toDouble(),
          screenHeight.toDouble());

      double size = topBackStrip.width * 12 / 15;
      double left = topBackStrip.left + topBackStrip.width / 2;
      double step = topBackStrip.height;
      double top = topBackStrip.top + topBackStrip.height * 1.5 / 15;
      ;

//      topBlockTool.setPosition(left, top);
//      topBlockTool.setSize(size, size);
//      topWhiteOutTool.setPosition(left+step, top);
//      topWhiteOutTool.setSize(size, size);
//      topTornadoTool.setPosition(left+step*2, top);
//      topTornadoTool.setSize(size, size);

      left = botBackStrip.left + botBackStrip.width * 1.5 / 15;

      step = botBackStrip.height;
      top = botBackStrip.top + botBackStrip.height / 2;

//      botBlockTool.setPosition(left, top);
//      botBlockTool.setSize(size,size);
//      botWhiteOutTool.setPosition(left-size, top);
//      botWhiteOutTool.setSize(size,size);
//      botTornadoTool.setPosition(left-size*2, top);
//      botTornadoTool.setSize(size,size);
    }

    topBoard = new Rect.fromLTRB(
        topSideStrip.right, topBackStrip.bottom, screenWidth.toDouble(),
        centerStrip.top);
    topBoardCenter = new Point(
        topBoard.left + topBoard.width / 2, topBoard.top + topBoard.height / 2);

    double left = topBoard.left;
    double top = topBoard.top;
    double right = topBoard.right;
    double bottom = topBoard.bottom;
    // center playing field, make it square.
    if (topBoard.height < width) {
      // make more narrow, to match height.
      left = topBoardCenter.x - topBoard.height / 2;
      right = topBoardCenter.x + topBoard.height / 2;
    } else {
      // make more short, to match width.
      top = topBoardCenter.y - topBoard.width / 2;
      bottom = topBoardCenter.y + topBoard.width / 2;
    }

    topBoard = new Rect.fromLTRB(left, top, right, bottom);

    botBoard = new Rect.fromLTRB(
        0, centerStrip.bottom, botSideStrip.left, botBackStrip.top);
    botBoardCenter = new Point(
        botBoard.left + botBoard.width / 2, botBoard.top + botBoard.height / 2);

    left = botBoard.left;
    top = botBoard.top;
    right = botBoard.right;
    bottom = botBoard.bottom;

    // center playing field, make it square.
    if (botBoard.height < width) {
      // make more narrow, to match height.
      left = botBoardCenter.x - botBoard.height / 2;
      right = botBoardCenter.x + botBoard.height / 2;
    } else {
      // make more short, to match width.
      top = botBoardCenter.y - botBoard.width / 2;
      bottom = botBoardCenter.y + botBoard.width / 2;
    }

    botBoard = new Rect.fromLTRB(left, top, right, bottom);

    double cellHeight = topBoard.height / rowCount;
    double cellWidth = topBoard.width / colCount;

    cellSizeWidth = cellWidth.toInt();
    cellSizeHeight = cellHeight.toInt();

    var configSize = width/11;
    configA = Rect.fromLTWH(configSize/2, height/2-configSize/2, configSize, configSize);
    configB = Rect.fromLTWH(width-configSize-configSize/2, height/2-configSize/2, configSize, configSize);

//    topTornadoMover.setSize(cellSizeWidth, cellSizeHeight);
//    topTornadoMover.setPosition(0, -cellSizeHeight);
//
//    botTornadoMover.setSize(cellSizeWidth, cellSizeHeight);
//    botTornadoMover.setPosition(0, -cellSizeHeight);
  }

  void prepareGameCells() {
    var left = botBoard.left;
    var top = botBoard.top;
    var right = botBoard.right;
    var bottom = botBoard.bottom;

    double cellHeight = topBoard.height / rowCount;
    double cellWidth = topBoard.width / colCount;

    for (int row = 0 ; row < rowCount ; row++) {
      double top = topBoard.top + cellHeight * row;
      double bottom = top + cellHeight;
      for (int col = 0 ; col < colCount ; col++) {
        left = topBoard.left + cellWidth * col;
        right = left + cellWidth;
        int index = col + row * colCount;
        topCells[index].setPosition(left,top);
        topCells[index].setSize(cellWidth, cellHeight);
      }
    }

    int cellCount = rowCount * colCount;
    if (botCells.length != cellCount) {
      botCells.clear();
      for (int i = 0 ; i < cellCount ; i++) {
        botCells.add(new Bouncer());
      }
    }

    for (int row = 0 ; row < rowCount ; row++) {
      double top = botBoard.top + cellHeight * row;
      for (int col = 0 ; col < colCount ; col++) {
        double left = botBoard.left + cellWidth * col;
        int index = col + row * colCount;
        botCells[index].setPosition(left, top);
        botCells[index].setSize(cellWidth, cellHeight);
      }
    }

//        float blockButtonCellSizeRatio = 1.5f;
//        topBlock.setSize(cellWidth * blockButtonCellSizeRatio, cellHeight * blockButtonCellSizeRatio);
//        topBlock.setPosition(topBoardCenter.x - cellWidth * blockButtonCellSizeRatio / 2,
//                topBoardCenter.y - cellHeight * blockButtonCellSizeRatio / 2);
//        botBlock.setSize(cellWidth * blockButtonCellSizeRatio, cellHeight * blockButtonCellSizeRatio);
//        botBlock.setPosition(botBoardCenter.x - cellWidth * blockButtonCellSizeRatio / 2,
//                botBoardCenter.y - cellHeight * blockButtonCellSizeRatio / 2);

    // ****  todo: do we need init() ? ****
    // init();

    clickPoints = new List.empty(growable: true);

    if (clickPoints.length != topCells.length) {
      bool top = true;
      prepareClickPoints(top);
    }

  }

  List<Point> clickPoints;

  void prepareClickPoints(bool useTopCells) {
    int left = 9999;
    int right = 0;
    int top = 9999;
    int bot = 0;

    List<Bouncer> scanMe = topCells;
    if (!useTopCells) {
      scanMe = botCells;
    }
    for (int i = 0 ; i < scanMe.length ; i++) {
      Bouncer b = scanMe[i];
      Rect location = b.getRect();
      if (location.left < left) {
        left = location.left.toInt();
      }
      if (location.top < top) {
        top = location.top.toInt();
      }
      if (location.right > right) {
        right = location.right.toInt();
      }
      if (location.bottom > bot) {
        bot = location.bottom.toInt();
      }
    }
    // now that we know the boundaries
    // we can calculate the click points.
    // each cell has the same size
    int cellWidth = (right - left) ~/ colCount;
    int cellHeight = (bot - top) ~/ rowCount;

    int x = left + cellWidth~/2;
    int y = top + cellHeight~/2;

    for (int row = 0 ; row < rowCount ; row++) {
      x = left + cellWidth~/2;
      for (int col = 0 ; col < colCount ; col++) {
        clickPoints.add(new Point(x, y));
        x += cellWidth;
      }
      y += cellHeight;
    }
  }


  void prepareLevel(int level, int rowCount, int colCount) {
    this.rowCount = rowCount;
    this.colCount = colCount;

    // todo: support dynamic number of colors
    List<Color> colors = [Colors.white, Colors.yellow, Colors.red, MyColors.darkBlue,
      MyColors.darkGreen, Colors.cyan[300]];

    // List<Color> colors =

    // -1 because one of them is blank.
    List<int> availableColorUnits = new List.filled(rowCount * colCount - 1, 0);
    int cellCount = availableColorUnits.length;

    int colorIndex = 0;
    for (int i = 0 ; i < cellCount ; i++) {
      availableColorUnits[i] = colorIndex;
      colorIndex++;
      if (colorIndex >= MyColors.colors.length) {
        colorIndex = 0;
      }
    }

    // make a copy so we can randomize them, including a black / empty cell
    List<int> boardColorLayout = new List.filled(cellCount+1, 0);
    for (int i = 0 ; i < cellCount ; i++) {
      boardColorLayout[i] = availableColorUnits[i];
    }
    boardColorLayout[cellCount] = -1;

    // todo: consider the tiles don't shift between levels
    // mix them up, same pattern for both sides
    for (int i = 0 ; i < 5000 ; i++) {
      int from = _rnd.nextInt(boardColorLayout.length);
      int to = _rnd.nextInt(boardColorLayout.length);
      int tmp = boardColorLayout[to];
      boardColorLayout[to] = boardColorLayout[from];
      boardColorLayout[from] = tmp;
    }

    topCells.clear();
    int cellIndex = 0;
    for (int row = 0 ; row < rowCount ; row++) {
      for (int col = 0 ; col < colCount ; col++) {
        Bouncer cell = new Bouncer();
        // border color == target / solution color
        cell.setBorderColor(Colors.black);
        Color cellColor = MyColors.getColor(boardColorLayout[cellIndex]);
        cell.setColor(cellColor);
        Textures cellTexture = MyTextures.getTexture(boardColorLayout[cellIndex]);
        cell.texture = cellTexture;
        topCells.add(cell);
        cellIndex++;
      }
    }

    // solution cells will be marked with non Color.BLACK color
    markSolutionCells(level, topCells);

    // set top cells with random values
    // then copy to lower cells in reverse order
    // cells with background color of Color.LTGRAY are changed
    setColorsForSolution(availableColorUnits, topCells);

    botCells.clear();
    // for (Bouncer b : topCells) {
    topCells.forEach((b) {
      Bouncer cell = new Bouncer();
      botCells.add(cell);
    });

    // copy from top to bot in reverse order, to get a mirror going.

    // botCells = topCells.reversed;
    int botIndex = topCells.length - 1;

    for (int i = 0 ; i < topCells.length ; i++) {
      botCells[botIndex].setColor(topCells[i].getColor());
      botCells[botIndex].texture = topCells[i].texture;
      botCells[botIndex].setBorderColor(topCells[i].getBorderColor());
      botCells[botIndex].borderTexture = topCells[i].borderTexture;
      botIndex--;
    }

//    int topIndex = topCells.toList().length()-1;
//    for (int botIndex = 0 ; botIndex < botCells.size() ; botIndex++) {
//      Bouncer botCell = botCells[botIndex];
//      Bouncer topCell = topCells[topIndex];
//
//      botCell.setColor(topCell.getColor());
//      botCell.setBorderColor(topCell.getBorderColor());
//
//      topIndex--;
//    }
  }

  // based on the level, mark cells as part of solution
  // a different set of code will set those cells to something.
  void markSolutionCells(int level, List<Bouncer> cells) {
    // first initialize all to black
    cells.forEach((b){
      b.setBorderColor(Colors.black);
    });

    bool useBorders = false;
    bool useAllCenters = true;

    // then set solution cells to something non black, like gray.
    switch(level) {
      default:
        break;
    }

    // todo: support other patterns than just centers.
    for (int row = 1 ; row < rowCount-1 ; row++) {
      for (int col = 1 ; col < colCount-1 ; col++) {
        cells[col + row * colCount].setBorderColor(Colors.grey);
      }
    }
  }

  void setColorsForSolution(List<int> solutionSet, List<Bouncer> cells) {
    int cellCount = solutionSet.length;
    List<int> cellsToPickFrom = new List.filled(cellCount, 0);

    // make a copy so we can scramble and use in order
    for (int i = 0 ; i < cellCount ; i++) {
      cellsToPickFrom[i] = solutionSet[i];
    }

    // mix them up, just for fun.  probably redundant.
    for (int i = 0 ; i < 5000 ; i++) {
      int from = _rnd.nextInt(cellCount);
      int to = _rnd.nextInt(cellCount);
      int tmp = cellsToPickFrom[to];
      cellsToPickFrom[to] = cellsToPickFrom[from];
      cellsToPickFrom[from] = tmp;
    }

    int cellIndexToUse = 0;
    cells.forEach((b) {
      if (b.getBorderColor() != Colors.black) {
        b.setBorderColor(MyColors.getColor(cellsToPickFrom[cellIndexToUse]));
        b.borderTexture = MyTextures.getTexture(cellsToPickFrom[cellIndexToUse]);
        cellIndexToUse++;
      }
    });
  }

}