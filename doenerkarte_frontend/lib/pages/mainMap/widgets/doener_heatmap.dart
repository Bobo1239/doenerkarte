import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

import '../../../communication/entities/Doener.dart';
import 'package:latlong2/latlong.dart';

class DoenerHeatMap extends StatelessWidget{

  final List<Doener> doneers;
  final List<Map<double, MaterialColor>> gradients = [
    HeatMapOptions.defaultGradient,
    {0.25: Colors.blue, 0.55: Colors.red, 0.85: Colors.pink, 1.0: Colors.purple}
  ];


  DoenerHeatMap({Key? key, required this.doneers, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeatMapLayer(
      heatMapDataSource: InMemoryHeatMapDataSource(data: generateData()),
      heatMapOptions: HeatMapOptions(gradient: this.gradients[0],
          minOpacity: 0.3),

    );
  }

  generateData(){
    final List<WeightedLatLng> data = [];
    for(var doener in doneers){
      data.add(WeightedLatLng(LatLng(doener.lat, doener.lon), doener.priceCents.toDouble()));
    }
    return data;
  }
}