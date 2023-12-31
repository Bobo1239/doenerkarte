
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';

class AvgPriceGrid extends StatelessWidget {

  final List<int> prices;
  final LatLngBounds currentVisibleBounds;

  static int Y_GRID_SIZE = 16;
  static int X_GRID_SIZE = 16;

  AvgPriceGrid({super.key, required this.prices, required this.currentVisibleBounds});

  @override
  Widget build(BuildContext context) {
    List<Polygon> poligons = List.generate(prices.length, (index) => Polygon(points: getPointsViaIndex(index), color: Color.lerp(Colors.blue, Colors.red, prices[index]/1000)?.withOpacity(prices[index]/1000)??Colors.transparent, isDotted: true, isFilled: true, borderColor: Colors.black, borderStrokeWidth: 1));
    return PolygonLayer(polygons: poligons);
  }




  /// interpolates the points for the polygon with the given index
  List<LatLng> getPointsViaIndex(int index){
    int x = index ~/ X_GRID_SIZE;
    int y = index % Y_GRID_SIZE;

    double stepsX = (currentVisibleBounds!.east - currentVisibleBounds!.west)/X_GRID_SIZE;
    double stepsY = (currentVisibleBounds!.north - currentVisibleBounds!.south)/Y_GRID_SIZE;



    LatLng topLeft = LatLng((currentVisibleBounds?.south ?? 0) + (stepsY * x), (currentVisibleBounds?.west ?? 0) + stepsX * y);
    LatLng topRight = LatLng((currentVisibleBounds?.south ?? 0) + stepsY * (x+1), (currentVisibleBounds?.west ?? 0) + stepsX * y);
    LatLng bottomLeft = LatLng((currentVisibleBounds?.south ?? 0) + stepsY * x, (currentVisibleBounds?.west ?? 0) + stepsX * (y+1));
    LatLng bottomRight = LatLng((currentVisibleBounds?.south ?? 0) + stepsY * (x+1), (currentVisibleBounds?.west ?? 0) + stepsX * (y+1));


    return [topLeft, topRight, bottomRight, bottomLeft];

  }
}
