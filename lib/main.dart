import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/src/widgets/binding.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(App());
}

class App extends Widget {
  @override
  Element createElement() {
    MyRenderObjectWidget myRenderObjectWidget = MyRenderObjectWidget();
    Element element = myRenderObjectWidget.createElement();
    return element;
  }
}

class MyRenderObjectWidget extends RenderObjectWidget {
  MyRenderObjectWidget({Key key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MyRenderObject();
  }

  @override
  RenderObjectElement createElement() => MyRenderObjectElement(this);
}

class MyRenderObjectElement extends RenderObjectElement {
  MyRenderObjectElement(RenderObjectWidget widget) : super(widget);

  @override
  void insertChildRenderObject(RenderObject child, slot) {}

  @override
  void moveChildRenderObject(RenderObject child, slot) {}

  @override
  void removeChildRenderObject(RenderObject child) {}
}

class MyRenderObject extends RenderBox {
  Size _size;
  Offset _dx1dy1, _dx2dy2;

  @override
  bool get sizedByParent => true;
  double bias = 0.0, stop;
  bool direction = true;
  int showCenterInRange = 40, speed = 140;

  Future<void> _handlePointerDataPacket(PointerDataPacket packet) {
    speed = packet.data[0].physicalY ~/ 20;
    print(speed);
    return null;
  }

  @override
  set size(Size value) {
    _size = value;
    _dx1dy1 = Offset(bias, 0);
    _dx2dy2 = Offset(bias, _size.height);
    stop = _size.width.roundToDouble();
    window.onPointerDataPacket = _handlePointerDataPacket;
    print('window.physicalSize: ${window.physicalSize}');
    loop();
    super.size = value;
  }

  loop() {
    Future.doWhile(() {
      return Future.delayed(Duration(milliseconds: speed)).then((value) {
        if (bias == stop) direction = false;
        if (bias == 0.0) direction = true;
        direction ? bias++ : bias--;
        _dx1dy1 = Offset(bias, 0);
        _dx2dy2 = Offset(bias, _size.height);
        markNeedsPaint();
        return true;
      });
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Paint paint = Paint();
    paint.style = PaintingStyle.stroke;

    Offset offsetYellowDot1 = Offset(stop - _dx1dy1.dx, _dx1dy1.dy),
        offsetYellowDot2 = Offset(stop - _dx2dy2.dx, _dx2dy2.dy);

    if (_dx2dy2.dx > offsetYellowDot1.dx - showCenterInRange &&
        _dx2dy2.dx < offsetYellowDot1.dx + showCenterInRange) {
      paint.strokeWidth = 1;
      paint.color = Colors.white;
      context.canvas.drawLine((offsetYellowDot1 + _dx1dy1) / 2,
          (offsetYellowDot2 + _dx2dy2) / 2, paint);
    }

    paint
      ..strokeWidth = 1
      ..color = Colors.red;
    context.canvas
      ..drawLine(_dx1dy1, _dx2dy2, paint)
      ..drawCircle(Offset(bias, _size.height / _size.width * bias), 5.0, paint)
      ..drawLine(Offset(bias, _size.height / _size.width * bias),
          Offset(stop - bias, _size.height / _size.width * bias), paint)
      ..drawCircle(
          Offset(bias, _size.height - _size.height / _size.width * bias),
          5.0,
          paint);
    paint.color = Colors.yellow;
    context.canvas
      ..drawLine(offsetYellowDot1, offsetYellowDot2, paint)
      ..drawCircle(
          Offset(stop - bias, _size.height - _size.height / _size.width * bias),
          5.0,
          paint)
      ..drawLine(
          Offset(stop - bias, _size.height - _size.height / _size.width * bias),
          Offset(bias, _size.height - _size.height / _size.width * bias),
          paint)
      ..drawCircle(
          Offset(stop - bias, _size.height / _size.width * bias), 5.0, paint);
  }
}
