

import 'package:doenerkarte/communication/communicator/backend_communicator.dart';
import 'package:doenerkarte/communication/entities/Area.dart';

import '../entities/Doener.dart';

class DoenerAreaRepository{

  BackendCommunicator backendCommunicator = BackendCommunicator();

  /// gets list of all doeners in area
  Future<List<Doener>> getDoenerFromArea(Area area) async {
    var  response = await backendCommunicator.post('doener_in_bounding_box', body: area.toJson());
    var list = response.map((e) => Doener.fromJson(e as Map<String, dynamic>));
    return  list.toList();
  }
}