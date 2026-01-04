class Plant {
  final String id;
  final String name;
  final String category;
  final String description;
  final String benefits;

  final String planting;
  final String sunlight;
  final String water;
  final String soil;
  final String temperature;

  final String tasmeed;
  final String pruningHarvest;

  final String imageUrl;

  // nested objects
  final CareInfo fertilizing;
  final CareInfo watering;
  final CareInfo pruning;

  Plant({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.benefits,
    required this.planting,
    required this.sunlight,
    required this.water,
    required this.soil,
    required this.temperature,
    required this.tasmeed,
    required this.pruningHarvest,
    required this.imageUrl,
    required this.fertilizing,
    required this.watering,
    required this.pruning,
  });

  factory Plant.fromFirestore(Map<String, dynamic> data, String id) {
    return Plant(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      benefits: data['benefits'] ?? '',
      planting: data['planting'] ?? '',
      sunlight: data['sunlight'] ?? '',
      water: data['water'] ?? '',
      soil: data['soil'] ?? '',
      temperature: data['tempreture'] ?? '',
      tasmeed: data['tasmeed'] ?? '',
      pruningHarvest: data['pruning-harvest'] ?? '',
      imageUrl: data['image'] ?? '',

fertilizing:
    CareInfo.fromMap(data['fertilizing'] as Map<String, dynamic>?),

watering:
    CareInfo.fromMap(data['watering'] as Map<String, dynamic>?),

pruning:
    CareInfo.fromMap(data['pruning'] as Map<String, dynamic>?),
    );
  }
}

class CareInfo {
  final String description;
  final int frequencyDays;

  CareInfo({
    required this.description,
    required this.frequencyDays,
  });

  factory CareInfo.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return CareInfo(description: '', frequencyDays: 0);
    }

    return CareInfo(
      description: data['description'] ?? '',
      frequencyDays: data['frequency_days'] ?? 0,
    );
  }
}
