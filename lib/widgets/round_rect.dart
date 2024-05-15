import 'package:flutter/material.dart';

class RoundRect extends StatefulWidget{
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  const RoundRect({
    super.key,
    this.color = Colors.white12,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(12),
    required this.child
  });

  @override
  State<RoundRect> createState() => _RoundRect();
}

class _RoundRect extends State<RoundRect>{
  late Color? color;
  late EdgeInsetsGeometry? margin;
  late EdgeInsetsGeometry? padding;
  late Widget? child;

  @override
  void initState() {
    super.initState();
    color = widget.color;
    margin = widget.margin;
    padding = widget.padding;
    child = widget.child;
  }
  
  @override
  Widget build(BuildContext context) {
  return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: child
    );
  }
}