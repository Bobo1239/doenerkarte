class Doener {
  double lat;
  double lon;
  double priceCents;

  Doener(this.lat, this.lon, this.priceCents);

  factory Doener.fromJson(Map<String, dynamic> json) {
    return Doener(
      json['lat'],
      json['lon'],
      json['priceCents'],
    );
  }

}