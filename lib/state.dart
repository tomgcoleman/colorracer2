
import 'package:flutter/material.dart';

import 'Bouncer.dart';

class StateDetector {
  bool checkForWinState(List<Bouncer> cells) {
    for(var b in cells) {
      if (b.getBorderColor() == Colors.black) continue;
      if (b.getBorderColor() != b.getColor()) return false;
    }
    return true;
  }
}