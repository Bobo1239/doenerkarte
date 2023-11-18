
import 'package:doenerkarte/communication/entities/Doener.dart';
import 'package:doenerkarte/communication/repositories/doener_area_repository.dart';
import 'package:doenerkarte/core/core_widgets/main_scaffold.dart';
import 'package:doenerkarte/core/reusable_widgetas/adress_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocode/geocode.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../communication/entities/Area.dart';
class MapMain extends StatefulWidget {
  const MapMain({super.key});

  @override
  State<MapMain> createState() => _MapMainState();
}

class _MapMainState extends State<MapMain> {

  MapController mapController = MapController();
  Future<List<Doener>>? doeners;
  LatLngBounds? currentVisibleBounds;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {

    super.initState();
    mapController.mapEventStream.listen((event) {
      setState(() {
        currentVisibleBounds = event.camera.visibleBounds;
      });
      loadDoener();
    });
  }


  @override
  Widget build(BuildContext context) {


    return MainScaffold(
      child: SizedBox(
          child: FlutterMap(
            mapController: mapController,
            options: const MapOptions(
              //TODO: disable rotation
              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              initialCenter: LatLng(48.1372, 11.5755),
              initialZoom: 9.2,
            ),
            children: [

              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
              ),
              Container(
                  color: Colors.blue,
                  child: IconButton(onPressed: loadDoener, icon: Icon(Icons.no_food))),
              FutureBuilder(
                future: doeners,
                builder: (context, snapshot) => buildForSnapshot(snapshot),
              ),
              // Container(
              //   margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //
              //   child: TextField(
              //     controller: TextEditingController(),
              //
              //     decoration: InputDecoration(
              //       suffixIcon: IconButton(
              //         onPressed: () => searchAdress(searchController.text),
              //           icon: Icon(Icons.search)),
              //
              //       fillColor: Colors.white,
              //
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       labelText: 'Search',
              //     ),),
              // )
              AutocompleteAdress(
                onSelected: (latLng) => mapController.move(latLng, 15),)
            ],
          ),
      ),
    );
  }


  searchAdress(String stringAdress){
    GeoCode geoCode = GeoCode();
    geoCode.forwardGeocoding(address: stringAdress).then((value) {
      if(value.latitude == null || value.longitude == null){
        return;
      }else{
        mapController.move(LatLng(value.latitude!, value.longitude!), 15);
        loadDoener();
      }
    });
  }

  buildForSnapshot(AsyncSnapshot<List<Doener>> snapshot) {
    if(snapshot.connectionState == ConnectionState.waiting){
      return CircularProgressIndicator();
    }
    if (snapshot.hasData) {
      return MarkerLayer(
          markers: snapshot.data!.map((e) => Marker(
            point: LatLng( e.lat , e.lon ),
            width: 60,
            height: 60,
            child: GestureDetector(
              onTap: () =>  showBottomSheet(context, e),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey.withOpacity(0.3),
                        child: Text("${(e.priceCents.toDouble() / 100).toStringAsFixed(2)}€", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF900000)),)),
                    Icon(Icons.location_on, size: 40,),
                  ],
                ),
              ),
            ),
          )).toList()
      );
    } else if (snapshot.hasError) {
      return Text("${snapshot.error}");
    }
    if(doeners == null){
      return Container();
    }
    return const CircularProgressIndicator();
  }



  void showBottomSheet(BuildContext context, Doener doener){
    showModalBottomSheet(
      showDragHandle: true,
        context: context, builder: (c1){
      return Container(
        child: ListTile(
          title: Text(doener.name),
          subtitle: Text("distance: 5000000km"),
          trailing: Text("${(doener.priceCents.toDouble() / 100)}€"),
        ),
      );
    });
  }

  void loadDoener() {
    print("load doener");
    setState(() {
      doeners = DoenerAreaRepository().getDoenerFromArea(Area(   currentVisibleBounds?.south??0, currentVisibleBounds?.north??0, currentVisibleBounds?.west??0, currentVisibleBounds?.east??0));
    });
  }
}