import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentIndex;
  final int total;

  const StepIndicator({
    super.key,
    required this.currentIndex,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        return SafeArea(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: currentIndex == index ? 24 : 8,
            height: 4,
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? Colors.blue
                  : Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}