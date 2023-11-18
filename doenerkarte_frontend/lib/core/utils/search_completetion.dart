
import 'dart:convert';

import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class AddressDetailed {
  final String? housenumber;
  final String? postcode;
  final String? name;
  final String? street;
  final String? city;
  final String? state;
  final String? country;


  AddressDetailed(
      {this.housenumber,
        this.postcode,
        this.name,
        this.street,
        this.city,
        this.state,
        this.country,
      });

  AddressDetailed.fromPhotonAPI(Map data)
      : this.housenumber = data["housenumber"] as String? ,
        this.postcode = data["postcode"] as String?,
          this.name = data["name"] as String?,
          this.street = data["street"] as String?,
          this.city = data["city"] as String?,
          this.state = data["state"] as String?,
          this.country = data["country"] as String?;

  @override
  String toString() {
    String addr = "";
    if (name != null && name!.isNotEmpty) {
      addr = addr + "$name ";
    }
    if (street != null && street!.isNotEmpty) {
      addr = addr + "$street ";
    }
    if (housenumber != null && housenumber!.isNotEmpty) {
      addr = addr + "$housenumber ";
    }
    if (postcode != null && postcode!.isNotEmpty) {
      addr = addr + "$postcode ";
    }
    if (city != null && city!.isNotEmpty) {
      addr = addr + "$city ";
    }
    if (state != null && state!.isNotEmpty) {
      addr = addr + "$state ";
    }
    if (country != null && country!.isNotEmpty) {
      addr = addr + "$country";
    }

    return addr;
  }
}

class SearchInfoDetailed {

  final LatLng point;
  AddressDetailed? addressDetailed;
  AddressDetailed? address;
  SearchInfoDetailed({
    required this.point,
    this.address,
    this.addressDetailed
  });

  SearchInfoDetailed.fromPhotonAPI(Map data)
      : this.addressDetailed = AddressDetailed.fromPhotonAPI(data['properties'] as Map) , point = LatLng(data["geometry"]["coordinates"][1] as double,  data["geometry"]["coordinates"][0] as double),
      address = AddressDetailed.fromPhotonAPI(data["properties"] as Map);
}



Future<List<SearchInfoDetailed>> addressSuggestionDetailed(String searchText,
    {int limitInformation = 5}) async {

    var uri = Uri.http("photon.komoot.io","/api", {
      "q": searchText,
      "limit": limitInformation == 0 ? "" : "$limitInformation"
    });
  Response response = await http.get(
    uri
  );
  final json = jsonDecode(response.body);

  return (json["features"] as List)
      .map((d) => SearchInfoDetailed.fromPhotonAPI(d as Map))
      .toList();
}