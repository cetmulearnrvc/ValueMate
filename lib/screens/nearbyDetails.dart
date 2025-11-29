import 'package:flutter/material.dart';

class DataModel {
  final double longitude;
  final double latitude;
  final double distance;
  final double landValue;
  final String nameOfOwner;
  final String bankName;
  final String refNo;

  DataModel({
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.landValue,
    required this.nameOfOwner,
    required this.bankName,
    required this.refNo,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      longitude: _parseDouble(json['longitude']),
      latitude: _parseDouble(json['latitude']),
      distance: _parseDouble(json['distance']),
      landValue: _parseDouble(json['landValue']),
      nameOfOwner: json['nameOfOwner'] ?? 'Unknown Owner',
      bankName: json['bankName'] ?? 'Unknown Bank',
      refNo: json['refNo'] ?? 'Unknown ref no./appln no.',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() {
    return 'DataModel{longitude: $longitude, latitude: $latitude, distance: $distance, marketValue: $landValue, nameOfOwner: $nameOfOwner, bankName : $bankName, refNo : $refNo}';
  }
}

class Nearbydetails extends StatefulWidget {
  final List<dynamic> responseData;

  const Nearbydetails({
    super.key,
    required this.responseData,
  });

  @override
  State<Nearbydetails> createState() => _NearbydetailsState();
}

class _NearbydetailsState extends State<Nearbydetails> {
  late List<DataModel> data = [];

  @override
  void initState() {
    super.initState();
    data = widget.responseData.map((item) => DataModel.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Land Value of Nearby Locations'),
    //     backgroundColor: Colors.blue,
    //   ),
    //   body:
    // );
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: data.isNotEmpty
            ? ListView.separated(
                itemCount: data.length,
                separatorBuilder: (ctx, index) => const Divider(),
                itemBuilder: (ctx, index) {
                  final item = data[index];
                  return Card(
                    key: ValueKey('card-$index'), // Unique key
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        '₹${item.landValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.tag),
                              const SizedBox(width: 4),
                              Text(
                                item.refNo,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 18),
                              const SizedBox(width: 9),
                              Text(
                                '${item.latitude.toStringAsFixed(6)}, ${item.longitude.toStringAsFixed(6)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.linear_scale, size: 16),
                              const SizedBox(width: 10),
                              Text('${item.distance.toStringAsFixed(2)} km'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person),
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                item.nameOfOwner,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/bank.png',
                                height: 25,
                                width: 25,
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                item.bankName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Text('No nearby locations found'),
              ),
      ),
    );
  }
}
