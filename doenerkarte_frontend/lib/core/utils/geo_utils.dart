import 'package:latlong2/latlong.dart';

/// calculates the distance between two points in meters
int getDistanceInMeters(LatLng latLng1, LatLng latLng2){
  return const Distance().as(LengthUnit.Meter, latLng1, latLng2).round();

}