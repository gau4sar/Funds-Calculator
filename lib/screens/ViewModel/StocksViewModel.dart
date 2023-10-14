import 'package:get/get.dart';
import '../../../utils/Utils.dart';
import '../../data/response/status.dart';
import '../../model/TickerSearchResponse.dart';
import '../../repository/stock_repository/stock_repository.dart';

class StocksViewModel extends GetxController {
  final _api = StockRepository();

  final rxRequestStatus = Status.LOADING.obs;

  final tickerSearchResponse = TickerSearchResponse(tickerSearchResponse: RxList<BestMatch>()).obs;

  RxString error = ''.obs;

  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;

  void setTickerSearchResponse(TickerSearchResponse value) => tickerSearchResponse.value = value;

  void setError(String value) => error.value = value;

  Future<List<String>> getTickerSearchResponse(String query) async {
    if (query.isNotEmpty) {
      setRxRequestStatus(Status.LOADING);
      print("setRxRequestStatus LOADING");
      try {
        print("setRxRequestStatus LOADING1");
        final value = await _api.tickerSearchListApi(query);
        print("setRxRequestStatus LOADING2");
        setRxRequestStatus(Status.COMPLETED);
        print("setRxRequestStatus COMPLETED " + (value.tickerSearchResponse?.length ?? 0).toString());
        setTickerSearchResponse(value);

        print("setRxRequestStatus LOADING3");

        // Check if value.tickerSearchResponse is not null before using map
        if (value.tickerSearchResponse != null) {

          print("setRxRequestStatus LOADIN4");
          // Extract and return all the names from the tickerSearchResponse
          List<String> names = value.tickerSearchResponse.map((bestMatch) => bestMatch.name).toList();

          print("setRxRequestStatus LOADING5");
          return names;
        } else {
          // Return an empty list if tickerSearchResponse is null.
          return [];
        }
      } catch (error) {
        setError(error.toString());
        setRxRequestStatus(Status.ERROR);
        Utils.toastMessage(error.toString());
        print("setRxRequestStatus ERROR " + error.toString());
        // Return an empty list in case of an error.
        return [];
      }
    } else {
      // Handle the case where the query is empty (e.g., clear the response list).
      return [];
    }
  }
}