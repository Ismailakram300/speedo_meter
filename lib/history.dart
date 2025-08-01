import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Database/database_helper.dart';
import 'Model/tracking_history.dart';

class HistoryScreen extends StatelessWidget {
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking History')),
      body: FutureBuilder<List<TrackingRecord>>(
        future: DatabaseHelper().getRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text("No history found."));

          final records = snapshot.data!;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[index];
              return ListTile(
                title: Text(
                  'Distance: ${r.distance.toStringAsFixed(2)} km, Avg: ${r.averageSpeed.toStringAsFixed(1)} km/h',
                ),
                subtitle: Text(
                  'Top: ${r.topSpeed.toStringAsFixed(1)} km/h, Duration: ${_formatDuration(r.duration)} mins\n${r.timestamp}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
