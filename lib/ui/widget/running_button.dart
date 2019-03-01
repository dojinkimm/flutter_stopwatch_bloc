import 'package:flutter/material.dart';
import 'dart:math';

import '../../model/elapsed_time.dart';
import '../../bloc/bloc_provider.dart';
import '../../bloc/running_bloc.dart';

///
/// Buttons that perform some actions
///
class RunningButton extends StatefulWidget {
  @override
  _RunningButtonState createState() => _RunningButtonState();
}

class _RunningButtonState extends State<RunningButton>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final RunningBloc runningBloc = BlocProvider.of<RunningBloc>(context);
    return StreamBuilder<ElapsedTime>(
      stream: runningBloc.$outTime,
      builder: (BuildContext context, AsyncSnapshot<ElapsedTime> snapshot) {
        if (snapshot.hasData && snapshot.data.isRunning) {
          return pauseButton(runningBloc);
        } else if (snapshot.hasData && !snapshot.data.isRunning) {
          return Container(
              margin: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  playButton(runningBloc),
                  resetButton(runningBloc),
                ],
              ));
        } else {
          return Container();
        }
      },
    );
  }

  Widget pauseButton(RunningBloc runningBloc) {
    return Container(
        margin: const EdgeInsets.only(bottom: 30.0),
        height: MediaQuery.of(context).size.height * 0.11,
        width: MediaQuery.of(context).size.width * 0.21,
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.2,
            child: RawMaterialButton(
              fillColor: Colors.white,
              onPressed: () => runningBloc.eventSink.add(StopEvent()),
              child: Icon(Icons.pause, size: 40.0),
              shape: CircleBorder(),
            ),
          ),
        ));
  }

  Widget playButton(RunningBloc runningBloc) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15.0),
        height: MediaQuery.of(context).size.height * 0.11,
        width: MediaQuery.of(context).size.width * 0.21,
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.2,
            child: RawMaterialButton(
              onPressed: () => runningBloc.eventSink.add(StartEvent()),
              child: Icon(Icons.play_arrow, size: 40.0),
              fillColor: Colors.white,
              shape: CircleBorder(),
            ),
          ),
        ));
  }

  Widget resetButton(RunningBloc runningBloc) {
    return new Container(
        height: MediaQuery.of(context).size.height * 0.11,
        width: MediaQuery.of(context).size.width * 0.21,
        margin: const EdgeInsets.symmetric(horizontal: 15.0),
        child: CustomPaint(
          foregroundPainter: new MyPainter(
              completeColor: Colors.blueAccent,
              completePercent:
                  controller.value == null ? 0.0 : controller.value,
              width: 6.0),
          child: GestureDetector(
              onTapDown: (_) {
                controller.forward().then((value) {
                  runningBloc.eventSink.add(ResetEvent());
                  controller.value = 0;
                });
              },
              onTapUp: (_) {
                if (controller.status == AnimationStatus.forward) {
                  controller.reverse();
                }
              },
              child: Center(
                  child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.stop, size: 40.0),
              ))),
        ));
  }
}

class MyPainter extends CustomPainter {
  Color completeColor;
  double completePercent;
  double width;
  MyPainter({this.completeColor, this.completePercent, this.width});
  @override
  void paint(Canvas canvas, Size size) {
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    double arcAngle = 2 * pi * (completePercent);
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
