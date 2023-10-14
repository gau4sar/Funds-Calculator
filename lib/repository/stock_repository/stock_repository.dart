import 'package:funds_calculator/model/TickerSearchResponse.dart';

import '../../data/network/network_api_services.dart';

class StockRepository {
  final _apiService = NetworkApiServices();

  Future<TickerSearchResponse> tickerSearchListApi(String keywords) async {

    const baseUrl = "https://www.alphavantage.co";
    const function = "SYMBOL_SEARCH";
    final url = "$baseUrl/query?function=$function&keywords=$keywords";

    dynamic response = await _apiService.getApi(url);
    return TickerSearchResponse.fromJson(response);
  }
}
