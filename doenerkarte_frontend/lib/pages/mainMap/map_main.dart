import 'package:doenerkarte/communication/entities/Doener.dart';
import 'package:doenerkarte/communication/repositories/doener_area_repository.dart';
import 'package:doenerkarte/core/core_widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
  @override
  void initState() {
    Future<List<Doener>> doeners = DoenerAreaRepository().getDoenerFromArea(Area(48.1372, 11.5755, 48.1372, 11.5755));
    doeners.then((value) => print(value));

    super.initState();
    mapController.mapEventStream.listen((event) {
      var visibleBounds = event.camera.visibleBounds;
      print("${visibleBounds.east}, ${visibleBounds.north}, ${visibleBounds.south}, ${visibleBounds.west}");
    });
    Future.delayed(Duration(milliseconds: 2000)).then((value) => mapController.rotate(30));
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
            ],
          ),
      ),
    );
  }
}