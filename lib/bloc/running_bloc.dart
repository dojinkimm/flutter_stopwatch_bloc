import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../model/elapsed_time.dart';
import './bloc_provider.dart';

abstract class RunningEvent {}

class StartEvent extends RunningEvent {}

class StopEvent extends RunningEvent {}

class ResetEvent extends RunningEvent {}

class RunningBloc implements BlocBase {
  ///
  /// Timer와 몇 주기마다 timer가 콜백될지 알려주는 변수
  /// Timer and variable to refresh the timer
  ///
  Timer _timer;
  final int timerMillisecondsRefreshRate = 50;

  ///
  /// 스톱워치와 ElapsedTime(millisecond, second, minute, isRunning)
  /// Stopwatch and model ElapsedTime(millisecond, second, minute, isRunning)
  ///
  Stopwatch _stopwatch;

  // ##########  STREAMS  ##############

  ///
  /// 달리고 있을때 화면에 보여지는 시간을 보여줄 stream
  /// Stream controlling the stopwatch time
  ///
  BehaviorSubject<ElapsedTime> _elapsedTime = BehaviorSubject<ElapsedTime>(
      seedValue: ElapsedTime(
          seconds: "00", minutes: "00", hundreds: "00", isRunning: false));

  Sink<ElapsedTime> get _inTime => _elapsedTime.sink;
  Observable<ElapsedTime> get $outTime => _elapsedTime.stream;

  ///
  /// 이벤트에 따라 스톱워치를 제어할 컨트롤러
  /// Controller that will control stopwatch time according to the event
  ///
  BehaviorSubject<RunningEvent> _eventController =
      BehaviorSubject<RunningEvent>();

  Sink<RunningEvent> get eventSink => _eventController.sink;

  //
  // Constructor
  //
  RunningBloc() {
    _stopwatch = Stopwatch();
    _eventController.stream.listen(_mapEventToState);
  }

  ///
  /// event가 input으로 들어오면 output으로 state을 보여준다
  /// Event comes as an input, shows state as an output
  ///
  void _mapEventToState(RunningEvent event) {
    if (event is StartEvent) {
      _start();
    } else if (event is StopEvent) {
      _stop();
    } else if (event is ResetEvent) {
      _reset();
    }
  }

  ///
  /// 스톱워치 시작시 진행되는 함수
  /// Function called when stopwatch play is clicked
  ///
  void _start() {
    if (_timer != null) return;
    _stopwatch.start();
    _timer = Timer.periodic(
        new Duration(milliseconds: timerMillisecondsRefreshRate), _refresh);
  }

  ///
  /// 스톱워치 멈춤시 진행되는 함수
  /// Function called when stopwatch pause is clicked
  ///
  void _stop() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();

    _inTime.add(calculateTime(false, _stopwatch.elapsed));
  }

  ///
  /// 스톱워치 종료시 진행되는 함수
  /// Function called when stopwatch pause is clicked
  ///
  void _reset() {
    _stop();
    _stopwatch.reset();
    _inTime.add(ElapsedTime(
        seconds: "00", minutes: "00", hundreds: "00", isRunning: false));
  }

  ///
  /// $outTime stream에 새로운 값을 timer의 주기마다 넣어주는 함수
  /// callback function that adds new time to $outTime stream periodically
  ///
  void _refresh(Timer timer) {
    // stopwatch가 진행중이라면 새로운 시간을 stream에 넣는다
    // only when stopwatch is running, it adds new time to the stream
    if (_stopwatch.isRunning) {
      _inTime.add(calculateTime(true, _stopwatch.elapsed));
    }
  }

  ///
  /// 시간을 parsing하고 model에 넣는 함수
  /// Function that parses time and puts in the ElapsedTime model
  ///
  ElapsedTime calculateTime(bool isRunning, Duration runningTime) {
    List<String> _timeList = runningTime.toString().split(":");

    String minutesStr = _timeList[1];
    String secondsStr = _timeList[2].substring(0, 2);
    String hundredsStr = _timeList[2].substring(3, 5);
    //시간을 단위로 쪼개서 따로 저장한다
    ElapsedTime elapsedTime = new ElapsedTime(
        hundreds: hundredsStr,
        seconds: secondsStr,
        minutes: minutesStr,
        isRunning: isRunning);

    return elapsedTime;
  }

  void dispose() async {
    await _eventController.drain();
    _eventController.close();
    await _elapsedTime.drain();
    _elapsedTime.close();
  }
}
