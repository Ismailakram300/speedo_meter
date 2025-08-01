import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speedo_meter/widgets/stat_row.dart';
import 'package:speedo_meter/widgets/tracking_ctrl.dart';
import 'Database/database_helper.dart';
import 'Services/SpeedAlertHelper.dart';
import 'distance_tracking.dart';

class DigitalSpeedScreen extends StatefulWidget {
  @override
  _DigitalSpeedScreenState createState() => _DigitalSpeedScreenState();
}

class _DigitalSpeedScreenState extends State<DigitalSpeedScreen> {
  double _speed = 0.0;
  double _distance = 0.0;
  Duration _elapsedTime = Duration.zero;// in m/s
  String status = 'Idle';
  int _speedLimit = 200; // default fallback
  bool _alertShown = false;
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndSetup();
    _setupTrackerListener();
    _startUITimer();
    final tracker = DistanceTracker();
    _loadSpeedLimit();
    tracker.onSpeedChanged = _handleSpeedChange;
    // Manually simulate high speed to test alert
    Future.delayed(Duration(seconds: 2), () {
      _handleSpeedChange(
        250,
      ); // This should trigger the alert if speedLimit < 250
    });
  }
  Future<void> _loadSpeedLimit() async {
    final dbLimit = await DatabaseHelper().getSpeedLimit();
    setState(() {
      _speedLimit = dbLimit.toInt();
    });
  }

  void _handleSpeedChange(double speed) {
    if (!mounted) return;

    setState(() {
      _speed = speed;
    });

    if (speed > _speedLimit && !_alertShown) {
      _alertShown = true;
      SpeedAlertHelper.showSpeedAlert(
        context: context,
        speed: speed,
        speedLimit: _speedLimit.toDouble(),
        vibrate: true,
        autoDismiss: true, // Will dismiss after 5 seconds
        soundPath: 'sounds/warning.mp3',
      );


    }

    if (speed <= _speedLimit) {
      _alertShown = false;
    }
  }
  void _setupTrackerListener() {
    final tracker = DistanceTracker();

    tracker.onSpeedChanged = (double speed) {
      if (!mounted) return;
      setState(() {
        _speed = speed;
      });
    };
  }

  void _requestPermissionAndSetup() async {
    await Permission.locationWhenInUse.request();
  }

  void _startUITimer() {
    _uiTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!mounted) return;
      final tracker = DistanceTracker();
      setState(() {
        _distance = tracker.totalKm;
        _elapsedTime = tracker.elapsedTime;
      });
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracker = DistanceTracker();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              '${_speed.toStringAsFixed(1)} km/h',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20),
          Column(
            children: [
              StatRow(
                title1: 'Distance',
                value1: '${DistanceTracker().totalKm.toStringAsFixed(2)} km',
                title2: 'Top Speed',
                value2: '${DistanceTracker().topSpeed.toStringAsFixed(1)} km/h',
              ),
              StatRow(
                title1: 'Avg Speed',
                value1: '${DistanceTracker().averageSpeed.toStringAsFixed(1)} km/h',
                title2: 'Duration',
                value2: 'Time: ${_formatDuration(tracker.elapsedTime)}',
              ),
            ],
          ),
          SizedBox(height: 20),
          TrackingControls(
            onUpdate: () {
              setState(() {
                _distance = tracker.totalKm;
                _elapsedTime = tracker.elapsedTime;
              });
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(duration.inHours);
    final m = twoDigits(duration.inMinutes.remainder(60));
    final s = twoDigits(duration.inSeconds.remainder(60));
    return "$h:$m:$s";
  }
}
