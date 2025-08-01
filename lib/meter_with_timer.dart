import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'distance_tracking.dart';

class SpeedometerWithTimer extends StatefulWidget {
  @override
  _SpeedometerWithTimerState createState() => _SpeedometerWithTimerState();
}

class _SpeedometerWithTimerState extends State<SpeedometerWithTimer> {
  double _speed = 0.0;
  Position? _lastPosition;
  double _totalDistance = 0.0; // in meters
  Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _elapsedTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    _initPermissionsAndGPS();
    _startTimer();
  }

  Future<void> _initPermissionsAndGPS() async {
    await Permission.locationWhenInUse.request();
    _stopwatch.start();

    final tracker = DistanceTracker();

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (position != null) {
       // tracker.updateDistance(position);
        setState(() {
          _speed = position.speed * 3.6;
        });
      }
    });


  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final duration = _stopwatch.elapsed;
      setState(() {
        _elapsedTime =
        "${_twoDigits(duration.inHours)}:${_twoDigits(duration.inMinutes % 60)}:${_twoDigits(duration.inSeconds % 60)}";
      });
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, "0");

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Speedometer + Timer'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Digital Speed Display
          Text(
            '${_speed.toStringAsFixed(1)} km/h',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),

          SizedBox(height: 20),
          Text(
            'Distance: ${(_totalDistance / 1000).toStringAsFixed(2)} km',
            style: TextStyle(fontSize: 24, color: Colors.white70),
          ),

          SizedBox(height: 20),

          // Timer Display
          Text(
            'Time: $_elapsedTime',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),

          SizedBox(height: 40),

          // Speed Gauge
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 180,
                ranges: [
                  GaugeRange(startValue: 0, endValue: 60, color: Colors.green),
                  GaugeRange(startValue: 60, endValue: 120, color: Colors.orange),
                  GaugeRange(startValue: 120, endValue: 180, color: Colors.red),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(value: _speed),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      '${_speed.toStringAsFixed(1)} km/h',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    angle: 90,
                    positionFactor: 0.8,
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(

                  foregroundColor: Colors.green, // this actually sets the text color
                ),
                onPressed: () {
                  DistanceTracker().startTracking();
                  setState(() {});
                },
                child: Text('Start'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(

                  foregroundColor: Colors.red, // this actually sets the text color
                ),
                onPressed: () {
                  DistanceTracker().pauseTracking();
                  setState(() {});
                },
                child: Text('Pause'),
              ),

              SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(

                  foregroundColor: Colors.yellow, // this actually sets the text color
                ),
                onPressed: () {
                  DistanceTracker().resumeTracking();
                  setState(() {});
                },
                child: Text('Resume'),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
