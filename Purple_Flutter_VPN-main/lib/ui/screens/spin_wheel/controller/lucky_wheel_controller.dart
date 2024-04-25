import 'package:flutter/material.dart';

class LuckyWheelController {
  late AnimationController baseAnimation;
  late TickerProvider _tickerProvider;
  bool _xSpinning = false;
  List<SpinItem> itemList = [];

  Future<void> initLoad({
    required TickerProvider tickerProvider,
    required List<SpinItem> itemList,
  }) async {
    _tickerProvider = tickerProvider;
    itemList = itemList;
    await setAnimations(_tickerProvider);
  }

  Future<void> setAnimations(TickerProvider tickerProvider) async {
    baseAnimation = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 200),
    );
  }

  Future<void> spinNow(
      {required int luckyIndex,
      int totalSpin = 10,
      int baseSpinDuration = 100}) async {
    int itemsLength = itemList.length;
    int factor = luckyIndex % itemsLength;
    if (factor == 0) factor = itemsLength;
    double spinInterval = 1 / itemsLength;
    double target = 1 - ((spinInterval * factor) - (spinInterval / 2));

    if (!_xSpinning) {
      _xSpinning = true;
      int spinCount = 0;

      do {
        baseAnimation.reset();
        baseAnimation.duration = Duration(milliseconds: baseSpinDuration);
        if (spinCount == totalSpin) {
          await baseAnimation.animateTo(target);
        } else {
          await baseAnimation.forward();
        }
        baseSpinDuration = baseSpinDuration + 50;
        baseAnimation.duration = Duration(milliseconds: baseSpinDuration);
        spinCount++;
      } while (spinCount <= totalSpin);

      _xSpinning = false;
    }
  }
}

class SpinItem {
  String label;
  TextStyle labelStyle;
  Color color;

  SpinItem(
      {required this.label, required this.color, required this.labelStyle});
}
