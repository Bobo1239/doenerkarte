class Area{
  double minLat;
  double maxLat;
  double minLon;
  double maxLon;

  Area(this.minLat, this.maxLat, this.minLon, this.maxLon);

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      json['minLat'],
      json['maxLat'],
      json['minLon'],
      json['maxLon'],
    );
  }

  Map<String, dynamic> toJson() => {
    'minLat': minLat,
    'maxLat': maxLat,
    'minLon': minLon,
    'maxLon': maxLon,
  };
}