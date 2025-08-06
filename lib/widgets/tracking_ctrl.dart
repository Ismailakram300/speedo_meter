  import 'dart:async';

  import 'package:flutter/material.dart';
  import '../Database/database_helper.dart';

  import '../Model/tracking_history.dart';
  import '../distance_tracking.dart';
import '../main.dart';

  class TrackingControls extends StatefulWidget {
    final VoidCallback? onUpdate;

    const TrackingControls({Key? key, this.onUpdate}) : super(key: key);

    @override
    State<TrackingControls> createState() => _TrackingControlsState();
  }

  class _TrackingControlsState extends State<TrackingControls> {
    final tracker = DistanceTracker();
    Timer? _uiTimer;

    @override
    void initState() {
      super.initState();
      _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {}); // update timer UI every second
      });
    }

    @override
    void dispose() {
      _uiTimer?.cancel();
      super.dispose();
    }

    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final h = twoDigits(d.inHours);
      final m = twoDigits(d.inMinutes.remainder(60));
      final s = twoDigits(d.inSeconds.remainder(60));
      return "$h:$m:$s";
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          // Text(
          //   'Time: ${formatDuration(tracker.elapsedTime)}',
          //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          // ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 1,
            children: [
              startButton(
                onStart: tracker.isTracking
                    ? null
                    : () {
                  tracker.startTracking();
                  setState(() {});
                },


              ),
              ElevatedButton(
                onPressed: !tracker.isTracking
                    ? null
                    : () {
                        tracker.pauseTracking();
                        setState(() {});
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Pause'),
              ),
              ElevatedButton(
                onPressed: tracker.isTracking
                    ? null
                    : () {
                        tracker.resumeTracking();
                        setState(() {});
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: const Text('Resume'),
              ),
              ElevatedButton(
                onPressed: () async {
                  tracker.stopTracking();

                  final record = TrackingRecord(
                    distance: tracker.totalKm,
                    averageSpeed: tracker.averageSpeed,
                    topSpeed: tracker.topSpeed,
                    duration: tracker.elapsedTime,
                    timestamp: DateTime.now(),
                  );

                  await DatabaseHelper().insertRecord(record);

                  tracker.reset();
                  setState(() {});
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      );
    }
  }
