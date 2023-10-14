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

  void getTickerSearchResponse(String query) {
    if (query.isNotEmpty) {
      setRxRequestStatus(Status.LOADING);
      print("setRxRequestStatus LOADING");
      _api.tickerSearchListApi(query).then((value) {
        setRxRequestStatus(Status.COMPLETED);
        print("setRxRequestStatus COMPLETED " + value.tickerSearchResponse.length.toString());
        setTickerSearchResponse(value);
      }).onError((error, stackTrace) {
        setError(error.toString());
        setRxRequestStatus(Status.ERROR);
        Utils.toastMessage(error.toString());
        print("setRxRequestStatus ERROR " + error.toString());
      });
    } else {
      // Handle the case where the query is empty (e.g., clear the response list).
    }
  }

}
