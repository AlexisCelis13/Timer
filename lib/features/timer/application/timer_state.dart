part of 'timer_bloc.dart';

/// The `sealed class TimerState extends Equatable` in Dart is defining a base class `TimerState` that
/// is marked as `sealed`. In Dart, a sealed class restricts its subclasses to be defined in the same
/// file. This helps in ensuring that all possible subclasses of `TimerState` are known and handled
/// within the same file.
sealed class TimerState extends Equatable {
  const TimerState(this.duration, {this.laps = const []});
  final int duration;
  final List<int> laps;

  @override
  List<Object> get props => [duration, laps];
}

/// The `TimerInitial` class represents the initial state of a timer with a specified duration in Dart.
class TimerInitial extends TimerState {
  const TimerInitial(super.duration, {super.laps});

  @override
  String toString() => 'TimerInitial { duration: $duration, laps: ${laps.length} }';
}

/// The `TimerTicking` class represents the state of a timer that is currently ticking with a specific
/// duration.
class TimerTicking extends TimerState {
  const TimerTicking({
    required int duration,
    required this.initialDuration,
    super.laps,
  }) : super(duration);

  final int initialDuration;

  @override
  List<Object> get props => [duration, initialDuration, laps];

  @override
  String toString() =>
      'TimerTicking { duration: $duration, initialDuration: $initialDuration, laps: ${laps.length} }';
}

/// The `TimerFinished` class represents a state where the timer has finished.
class TimerFinished extends TimerState {
  const TimerFinished({super.laps}) : super(0);
}
