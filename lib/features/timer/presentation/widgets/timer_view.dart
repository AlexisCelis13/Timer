import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:javerage_timer/features/timer/application/timer_bloc.dart';
import 'package:javerage_timer/features/timer/presentation/widgets/actions_buttons.dart';
import 'package:javerage_timer/features/timer/presentation/widgets/background.dart';
import 'package:javerage_timer/features/timer/presentation/widgets/timer_text.dart';

/// The TimerView class in Dart defines a widget for displaying a timer with associated actions in a
/// responsive layout.
class TimerView extends StatefulWidget {
  const TimerView({super.key});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimerBloc, TimerState>(
      listener: (context, state) {
        if (state is TimerFinished) {
          _audioPlayer.play(AssetSource('audio/notification.mp3'));
        } else if (state is TimerInitial) {
          _audioPlayer.stop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Timer')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait = constraints.maxHeight > constraints.maxWidth;
            final verticalPadding = isPortrait
                ? constraints.maxHeight * 0.1
                : constraints.maxHeight * 0.05;
            return Stack(
              children: [
                const Background(),
                _TimerView(verticalPadding: verticalPadding, constraints: constraints),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The _TimerView class is a StatelessWidget in Dart that displays a TimerText widget with specified
/// vertical padding and ActionButtons below it.
class _TimerView extends StatelessWidget {
  const _TimerView({required this.verticalPadding, required this.constraints});

  final double verticalPadding;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final double timerSize = constraints.maxHeight < constraints.maxWidth
        ? constraints.maxHeight * 0.6 // Smaller in landscape
        : constraints.maxHeight * 0.3; // Larger in portrait

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: Center(
              child: BlocBuilder<TimerBloc, TimerState>(
                builder: (context, state) {
                  final double progress = (state is TimerTicking)
                      ? state.duration / state.initialDuration
                      : 1.0;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: timerSize,
                        height: timerSize,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      const TimerText(),
                    ],
                  );
                },
              ),
            ),
          ),
          const ActionsButtons(),
          BlocBuilder<TimerBloc, TimerState>(
            buildWhen: (prev, current) => prev.laps != current.laps,
            builder: (context, state) {
              if (state.laps.isEmpty) {
                return const SizedBox.shrink();
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.laps.length,
                itemBuilder: (context, index) {
                  final lapDuration = state.laps[index];
                  final minutesStr =
                      ((lapDuration / 60) % 60).floor().toString().padLeft(2, '0');
                  final secondsStr =
                      (lapDuration % 60).floor().toString().padLeft(2, '0');
                  return ListTile(
                    leading: Text(
                      'Lap ${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      '$minutesStr:$secondsStr',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
