import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speedo_meter/settings.dart';
import 'package:speedo_meter/widgets/newmete2.dart';
import 'package:speedo_meter/widgets/painter.dart';
import 'Services/current_location_map.dart';
import 'digital_meter.dart';
import 'gauge_meter.dart';
import 'gauge_selection_screen.dart';
void main() => runApp(SpeedometerApp());

class SpeedometerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speedometer',
      theme: ThemeData.dark(),
      home: TabScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class TabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Speedo Meter',style: TextStyle(color: Colors.white),),
          actions: [

            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsScreen()));
            }, icon: Icon(Icons.settings)),

            // IconButton(onPressed: (){
            //   Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomSpeedometerGauge(speed: 90,)));
            // }, icon: Icon(Icons.settings)),




    ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.speed),text: "Digital",),
              Tab(icon: Icon(Icons.shutter_speed),text: 'Gauge',),
              Tab(icon: Icon(Icons.map),text: 'Map',),
              Tab(icon: Icon(Icons.label),text: 'Map',),

            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: DigitalSpeedScreen()),
            Center(child: SpeedometerScreen()),
            Center(child: CurrentLocationMap()),
            Center(child: GaugeSelectionScreen()),
                        // Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => SingleCity(
            //             cityData: {
            //               'name': 'Lahore',
            //               'address': 'Lahore, Punjab, Pakistan',
            //               'lat': 31.5497,
            //               'lng': 74.3436,
            //             },
            //           ),
            //         ),
            //       );
            //     },
            //     child: Text('Show Lahore on Map'),
            //   ),
            // ),
          ],
        ),

      ),
    );
  }
}


