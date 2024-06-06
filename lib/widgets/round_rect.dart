import 'package:flutter/material.dart';

class RoundRect extends StatefulWidget{
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final void Function()? onTap;

  const RoundRect({
    super.key,
    this.color = Colors.white12,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(12),
    this.onTap,
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
  late void Function()? onTap;

  late Color? _color;

  @override
  void initState() {
    super.initState();
    color = widget.color;
    _color = color!;
    margin = widget.margin;
    padding = widget.padding;
    onTap = widget.onTap;
    child = widget.child;
  }

  void _doTapAnimation() {
    setState(() {
      _color = (_color == color) ? color!.withOpacity(0.3) : color;
    });
  }
  
  @override
  Widget build(BuildContext context) {
  return GestureDetector(
      onTap: (onTap == null) ? () {} : () {
        _doTapAnimation();
        Future.delayed(const Duration(milliseconds: 150), () {
          _doTapAnimation();
          Future.delayed(const Duration(milliseconds: 150), () {
            onTap!();
          });
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: child
      )
    );
  }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

class RoundRectColumned extends StatefulWidget{
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  // final Widget? child;
  final void Function()? onTap;

  final List<Widget> children;
  final double? width;
  final double? height;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const RoundRectColumned({
    super.key,
    this.color = Colors.white12,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(12),
    this.onTap,
    required this.children,
    this.width,
    this.height,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start
  });

  @override
  State<RoundRectColumned> createState() => _RoundRectColumned();
}

class _RoundRectColumned extends State<RoundRectColumned>{
  late Color? color;
  late EdgeInsetsGeometry? margin;
  late EdgeInsetsGeometry? padding;
  late void Function()? onTap;

  late List<Widget> children;
  late double? width;
  late double? height;
  late CrossAxisAlignment crossAxisAlignment;
  late MainAxisAlignment mainAxisAlignment;

  @override
  void initState() {
    super.initState();
    color = widget.color;
    margin = widget.margin;
    padding = widget.padding;
    onTap = widget.onTap;

    children = widget.children;
    width = widget.width;
    height = widget.height;
    crossAxisAlignment = widget.crossAxisAlignment;
    mainAxisAlignment = widget.mainAxisAlignment;
  }
  
  @override
  Widget build(BuildContext context) {
    return RoundRect(
      color: color,
      margin: margin,
      padding: padding,
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          children: children
        )
      )
    );
  }
}