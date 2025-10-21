import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:javerage_timer/features/timer/domain/repositories/timer_repository.dart';

part 'timer_event.dart';
part 'timer_state.dart';

/// The TimerBloc class in Dart is responsible for managing timer events and states, utilizing a
/// TimerRepository for functionality like starting, ticking, pausing, and resetting timers.
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc({required TimerRepository timerRepository})
      : _timerRepository = timerRepository,
        super(const TimerInitial(_duration)) {
    on<TimerStarted>(_onStarted);
    on<TimerTicked>(_onTicked);
    on<TimerPaused>(_onPaused);
    on<TimerReset>(_onReset);
    on<TimerDurationChanged>(_onDurationChanged);
    on<TimerLapPressed>(_onLapPressed); // Register new event
  }

  final TimerRepository _timerRepository;
  static const int _duration = 60;

  StreamSubscription<int>? _tickerSubscription;

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    // Start with empty laps
    emit(TimerTicking(
      duration: event.duration,
      initialDuration: event.duration,
      laps: const [],
    ));
    _tickerSubscription?.cancel();
    _tickerSubscription = _timerRepository
        .ticker()
        .listen((ticks) => add(TimerTicked(duration: event.duration - ticks)));
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0
          ? TimerTicking(
              duration: event.duration,
              initialDuration: (state as TimerTicking).initialDuration,
              laps: state.laps, // Propagate laps
            )
          : TimerFinished(laps: state.laps), // Pass final laps to finished state
    );
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerTicking) {
      _tickerSubscription?.pause();
      // Preserve laps when pausing
      emit(TimerInitial(state.duration, laps: state.laps));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    // Resetting also clears laps by creating a new default TimerInitial
    emit(const TimerInitial(_duration));
  }

  void _onDurationChanged(TimerDurationChanged event, Emitter<TimerState> emit) {
    if (state is TimerInitial) {
      // Changing duration also clears laps
      emit(TimerInitial(event.duration));
    }
  }

  // New handler for lap pressing
  void _onLapPressed(TimerLapPressed event, Emitter<TimerState> emit) {
    if (state is TimerTicking) {
      final newLaps = List<int>.from(state.laps)..add(state.duration);
      emit(TimerTicking(
        duration: state.duration,
        initialDuration: (state as TimerTicking).initialDuration,
        laps: newLaps,
      ));
    }
  }
}
