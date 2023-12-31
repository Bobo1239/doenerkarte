

import '../communicator/backend_communicator.dart';
import '../entities/Area.dart';

class AverageGridDataRepository{

  BackendCommunicator backendCommunicator = BackendCommunicator();

  Future<List<int>> getAvgGridPrices(Area area) async {
    var  response = await backendCommunicator.post('/price_grid_in_bounding_box', body: area.toJson());
    var list = response.map((e) => e as int);
    return  list.toList();
  }

  Future<List<int>> getAvrgRating(Area area) async {
    var  response = await backendCommunicator.post('/price_grid_in_bounding_box', body: area.toJson());
    var list = response.map((e) => e as int);
    return  list.toList();
  }

}