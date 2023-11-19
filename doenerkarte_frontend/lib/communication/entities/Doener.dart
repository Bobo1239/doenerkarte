import 'dart:ffi';

class Doener {
  double lat;
  double lon;
  int priceCents;
  String name;
  String address;
  double rating;

  Doener(this.lat, this.lon, this.priceCents, this.name, this.address, this.rating);

  factory Doener.fromJson(Map<String, dynamic> json) {
    return Doener(
      json['lat'] as double,
      json['lon'] as double,
      (json['price-cents']??0) as int,
      json['name'] as String,
      json['address'] as String,
      (json['rating']??0.0) as double,
    );
  }

}