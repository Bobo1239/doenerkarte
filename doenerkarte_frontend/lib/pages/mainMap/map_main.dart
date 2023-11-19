
import 'dart:async';

import 'package:doenerkarte/communication/entities/Doener.dart';
import 'package:doenerkarte/communication/repositories/doener_area_repository.dart';
import 'package:doenerkarte/core/core_widgets/main_scaffold.dart';
import 'package:doenerkarte/core/reusable_widgetas/adress_autocomplete.dart';
import 'package:doenerkarte/pages/mainMap/widgets/avg_price_grid.dart';
import 'package:doenerkarte/pages/mainMap/widgets/doener_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../communication/entities/Area.dart';
import '../../core/utils/geo_utils.dart';
class MapMain extends StatefulWidget {
  const MapMain({super.key});

  @override
  State<MapMain> createState() => _MapMainState();
}

class _MapMainState extends State<MapMain> {




  final LatLng startLocation = const LatLng(48.1372, 11.5755);
  MapController mapController = MapController();
  //TODO: this should not be a future
  Future<List<Doener>>? doeners;
  LatLngBounds? currentVisibleBounds;
  TextEditingController searchController = TextEditingController();
  LatLng? currentLocation;

  @override
  void initState() {

    super.initState();
    currentLocation = startLocation;
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
            options: MapOptions(
              //TODO: disable rotation
              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              initialCenter: startLocation,
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
              FutureBuilder(
                future: doeners,
                builder: (context, snapshot) => buildForSnapshot(snapshot),
              ),
              FutureBuilder(
                future: doeners,
                builder: (context, snapshot) => snapshot.hasData ? DoenerHeatMap(doneers: snapshot.data!) : Container()
              ),
              if((currentVisibleBounds??0) != 0)
                AvgPriceGrid(prices: List.generate(100, (index) => index), currentVisibleBounds: currentVisibleBounds!,),
              AutocompleteAdress(
                onSelected: (latLng) => {mapController.move(latLng, 15), currentLocation = latLng},)
            ],
          ),
      ),
    );
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
          subtitle: Text("${getDistanceInMeters(currentLocation??LatLng(0, 0), LatLng(doener.lat, doener.lon))/1000} km"),
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