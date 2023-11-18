import 'dart:ffi';

class Doener {
  double lat;
  double lon;
  int priceCents;
  String name;

  Doener(this.lat, this.lon, this.priceCents, this.name);

  factory Doener.fromJson(Map<String, dynamic> json) {
    return Doener(
      json['lat'] as double,
      json['lon'] as double,
      json['price-cents'] as int,
      json['name'] as String,
    );
  }

}