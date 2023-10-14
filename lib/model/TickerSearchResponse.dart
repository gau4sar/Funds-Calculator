import 'package:get/get.dart';

class BestMatch {
  var symbol = ''.obs;
  var name = ''.obs;
  var type = ''.obs;
  var region = ''.obs;
  var marketOpen = ''.obs;
  var marketClose = ''.obs;
  var timezone = ''.obs;
  var currency = ''.obs;
  var matchScore = ''.obs;

  BestMatch({
    required this.symbol,
    required this.name,
    required this.type,
    required this.region,
    required this.marketOpen,
    required this.marketClose,
    required this.timezone,
    required this.currency,
    required this.matchScore,
  });

  factory BestMatch.fromJson(Map<String, dynamic> json) {
    return BestMatch(
      symbol: json['1. symbol'],
      name: json['2. name'],
      type: json['3. type'],
      region: json['4. region'],
      marketOpen: json['5. marketOpen'],
      marketClose: json['6. marketClose'],
      timezone: json['7. timezone'],
      currency: json['8. currency'],
      matchScore: json['9. matchScore'],
    );
  }
}

class TickerSearchResponse {
  var tickerSearchResponse = <BestMatch>[].obs;

  TickerSearchResponse({required this.tickerSearchResponse});

  factory TickerSearchResponse.fromJson(Map<String, dynamic> json) {
    List<BestMatch> tickerSearchResponseList = List<BestMatch>.from(
        json['TickerSearchResponse'].map((item) => BestMatch.fromJson(item)));
    return TickerSearchResponse(tickerSearchResponse: tickerSearchResponseList.obs);
  }
}
