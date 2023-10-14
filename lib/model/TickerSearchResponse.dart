class BestMatch {
  String symbol;
  String name;
  String type;
  String region;
  String marketOpen;
  String marketClose;
  String timezone;
  String currency;
  double matchScore;  // Change the type to double

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
      matchScore: double.parse(json['9. matchScore']),  // Convert the value to double
    );
  }
}

class TickerSearchResponse {
  List<BestMatch> tickerSearchResponse;

  TickerSearchResponse({required this.tickerSearchResponse});

  factory TickerSearchResponse.fromJson(Map<String, dynamic> json) {

    List<BestMatch> bestMatches = (json['bestMatches'] as List).map((item) => BestMatch.fromJson(item)).toList();

    return TickerSearchResponse(tickerSearchResponse: bestMatches);
  }
}
