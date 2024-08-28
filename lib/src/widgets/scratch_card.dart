import 'package:flutter/material.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_game_framework/flutter_game_framework.dart';

class ScratchElement {
  final IconData? icon;
  final String? image;
  final Rarity rarity; // 전부 다 매칭될 경우 보상으로 주는 아이템의 희귀도

  ScratchElement({this.icon, this.image, required this.rarity});
}

class ScratchCard extends StatefulWidget {
  final double cardWidth;
  final double cardHeight;
  final double scratchAreaWidth;
  final double scratchAreaHeight;
  final double cardBorderRadius;
  final Color backgroundColor;
  final Color scratchAreaColor;
  final Color scratchAreaBackgroundColor;
  final double scratchAreaBorderRadius;
  final double brushSize;
  final double threshold;
  final VoidCallback? onNotMatch;
  final Function(Rarity) onMatch;
  final List<ScratchElement> elements;
  final int elementCount;

  const ScratchCard({
    super.key,
    this.cardWidth = 600,
    this.cardHeight = 200,
    this.scratchAreaWidth = 40,
    this.scratchAreaHeight = 40,
    this.cardBorderRadius = 20,
    this.scratchAreaBorderRadius = 10,
    this.backgroundColor = Colors.white,
    this.scratchAreaColor = Colors.grey,
    this.scratchAreaBackgroundColor = Colors.white,
    this.brushSize = 30,
    this.threshold = 50,
    required this.onNotMatch,
    required this.onMatch,
    required this.elements,
    required this.elementCount,
  });

  @override
  _ScratchCardState createState() => _ScratchCardState();
}

class _ScratchCardState extends State<ScratchCard> {
  Widget _buildContainer() {
    return Container(
      width: widget.cardWidth,
      height: widget.cardHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.cardBorderRadius),
      ),
      child: Stack(
        children: [
          for (int i = 0; i < widget.elementCount; i++)
            Positioned(
              left: i * widget.scratchAreaWidth,
              child: Scratcher(
                brushSize: widget.brushSize,
                threshold: widget.threshold,
                color: widget.scratchAreaColor,
                onChange: (value) {
                  if (value > widget.threshold) {
                    widget.onMatch(widget.elements[i].rarity);
                  } else {
                    widget.onNotMatch?.call();
                  }
                },
                child: Container(
                  width: widget.scratchAreaWidth,
                  height: widget.scratchAreaHeight,
                  decoration: BoxDecoration(
                    color: widget.scratchAreaBackgroundColor,
                    borderRadius: BorderRadius.circular(widget.scratchAreaBorderRadius),
                  ),
                  child: widget.elements[i].icon != null
                      ? Icon(widget.elements[i].icon, color: widget.elements[i].rarity.color)
                      : Image.asset(widget.elements[i].image!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContainer();
  }
}
