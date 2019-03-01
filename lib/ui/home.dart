import 'package:flutter/material.dart';
import '../bloc/bloc_provider.dart';
import '../bloc/running_bloc.dart';
import '../model/elapsed_time.dart';
import './widget/running_button.dart';

class HomePage extends StatelessWidget {
  final TextStyle _numberStyle =
      TextStyle(color: Colors.white, fontSize: 100.0, fontFamily: "Bebas Neue");
  final TextStyle _explanationStyle =
      TextStyle(color: Colors.white, fontSize: 30.0, fontFamily: "Bebas Neue");

  @override
  Widget build(BuildContext context) {
    final runningBloc = BlocProvider.of<RunningBloc>(context);
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        Column(
          children: <Widget>[
            new Expanded(child: _buildStopWatch(runningBloc)), //시간
            RunningButton() //버튼들
          ],
        )
      ],
    ));
  }

  ///
  /// 시간이 가는 스톱워치 위젯
  /// stopwatch widget
  ///
  Widget _buildStopWatch(var runningBloc) {
    return StreamBuilder<ElapsedTime>(
      stream: runningBloc.$outTime,
      builder: (BuildContext context, AsyncSnapshot<ElapsedTime> snapshot) {
        if (!snapshot.hasData)
          return Container();
        else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.timer, color: Colors.white),
                  SizedBox(width: 5.0),
                  Text("DURATION", style: _explanationStyle)
                ],
              ),
              Text("${snapshot.data.minutes} : ${snapshot.data.seconds}.${snapshot.data.hundreds}",
                  style: _numberStyle)
            ],
          );
        }
      },
    );
  }
}
