class LocationValue {
  final String address;
  final double lat;
  final double lng;

  const LocationValue({
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory LocationValue.fromJson(Map<String, dynamic> json) => LocationValue(
        address: json['address'] as String? ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'lat': lat,
        'lng': lng,
      };

  @override
  String toString() => address;

  @override
  bool operator ==(Object other) =>
      other is LocationValue &&
      other.address == address &&
      other.lat == lat &&
      other.lng == lng;

  @override
  int get hashCode => Object.hash(address, lat, lng);
}
