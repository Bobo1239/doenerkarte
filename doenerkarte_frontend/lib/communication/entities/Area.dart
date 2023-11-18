class Area{
  double minLat;
  double maxLat;
  double minLon;
  double maxLon;

  Area(this.minLat, this.maxLat, this.minLon, this.maxLon);

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      json['lat-min'],
      json['lat-max'],
      json['lon-min'],
      json['lon-max'],
    );
  }

  Map<String, dynamic> toJson() => {
    'lat-min': minLat,
    'lat-max': maxLat,
    'lon-min': minLon,
    'lon-max': maxLon,
  };
}