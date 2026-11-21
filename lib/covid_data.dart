class CovidData {
  final String country;
  final int cases;
  final int todayCases;
  final int deaths;
  final int todayDeaths;
  final int recovered;
  final DateTime updated;
  final String? flag; // Ampliación 1: URL de la bandera

  CovidData({
    required this.country,
    required this.cases,
    required this.todayCases,
    required this.deaths,
    required this.todayDeaths,
    required this.recovered,
    required this.updated,
    this.flag,
  });

  factory CovidData.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => (v as num?)?.toInt() ?? 0;

    final countryInfo = json['countryInfo'] as Map<String, dynamic>?;

    return CovidData(
      country: json['country'] as String,
      cases: toInt(json['cases']),
      todayCases: toInt(json['todayCases']),
      deaths: toInt(json['deaths']),
      todayDeaths: toInt(json['todayDeaths']),
      recovered: toInt(json['recovered']),
      updated: DateTime.fromMillisecondsSinceEpoch(toInt(json['updated'])),
      flag: countryInfo?['flag'] as String?,
    );
  }
}