import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:javerage_timer/features/timer/application/timer_bloc.dart';

/// The TimerText class is a StatelessWidget in Dart that displays a timer in minutes and seconds
/// format, and allows setting a custom duration when the timer is in its initial state.
class TimerText extends StatelessWidget {
  const TimerText({super.key});

  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final minutesStr = ((duration / 60) % 60).floor().toString().padLeft(
          2,
          '0',
        );
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () {
        // Only allow changing the duration if the timer is in its initial state
        if (context.read<TimerBloc>().state is TimerInitial) {
          _showDurationPickerDialog(context, duration);
        }
      },
      child: Text(
        '$minutesStr:$secondsStr',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  void _showDurationPickerDialog(BuildContext context, int currentDuration) {
    final controller = TextEditingController(text: currentDuration.toString());
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Set Duration (in seconds)'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              labelText: 'Duration (s)',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                final newDuration = int.tryParse(controller.text);
                if (newDuration != null && newDuration > 0) {
                  context
                      .read<TimerBloc>()
                      .add(TimerDurationChanged(newDuration));
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
