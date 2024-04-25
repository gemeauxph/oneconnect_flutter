import 'package:flutter/material.dart';
import 'package:ndvpn/ui/screens/spin_wheel/controller/lucky_wheel_controller.dart';
import 'package:ndvpn/ui/screens/spin_wheel/wheel.dart';

class Spinner extends StatefulWidget {
  final LuckyWheelController mySpinController;
  final List<SpinItem> itemList;
  final double wheelSize;
  final Function(void) onFinished;
  const Spinner({
    super.key,
    required this.mySpinController,
    required this.onFinished,
    required this.itemList,
    required this.wheelSize,
  });

  @override
  State<Spinner> createState() => _MySpinnerState();
}

class _MySpinnerState extends State<Spinner> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.mySpinController.initLoad(
      tickerProvider: this,
      itemList: widget.itemList,
    );
  }

  @override
  void dispose() {
    super.dispose();
    null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15),
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: widget.mySpinController.baseAnimation,
            builder: (context, child) {
              double value = widget.mySpinController.baseAnimation.value;
              double rotationValue = (360 * value);
              return RotationTransition(
                turns: AlwaysStoppedAnimation(rotationValue / 360),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotatedBox(
                      quarterTurns: 3,
                      child: Container(
                          width: widget.wheelSize,
                          height: widget.wheelSize,
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black,
                                  Colors.white,
                                  Colors.black,
                                  Colors.white,
                                  Colors.black
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(5),
                            child: CustomPaint(
                              painter: Wheel(items: widget.itemList),
                            ),
                          )),
                    ),
                    ...widget.itemList.map((each) {
                      int index = widget.itemList.indexOf(each);
                      double rotateInterval = 360 / widget.itemList.length;
                      double rotateAmount = (index + 0.5) * rotateInterval;
                      return RotationTransition(
                        turns: AlwaysStoppedAnimation(rotateAmount / 360),
                        child: Transform.translate(
                          offset: Offset(0, -widget.wheelSize / 4),
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(each.label, style: each.labelStyle),
                          ),
                        ),
                      );
                    }),
                    Container(
                      alignment: Alignment.center,
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                          color: Colors.transparent, shape: BoxShape.circle),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              Icons.location_on_sharp,
              size: 50,
              color: Colors.green,
            )),
      ],
    );
  }
}
