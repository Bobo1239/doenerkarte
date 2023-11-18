

import 'package:doenerkarte/communication/communicator/backend_communicator.dart';
import 'package:doenerkarte/communication/entities/Area.dart';

import '../entities/Doener.dart';

class DoenerAreaRepository{

  BackendCommunicator backendCommunicator = BackendCommunicator(baseUrl: 'http://131.159.202.238:8000/');

  /// gets list of all doeners in area
  Future<List<Doener>> getDoenerFromArea(Area area) async {
    final response = await backendCommunicator.post('doener_in_bounding_box', body: area.toJson());
    return response.map(Doener.fromJson).toList();
  }
}