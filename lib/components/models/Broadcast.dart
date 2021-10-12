// To parse this JSON data, do
//
//     final broadcast = broadcastFromJson(jsonString);

import 'dart:convert';

Broadcast broadcastFromJson(String str) => Broadcast.fromJson(json.decode(str));

String broadcastToJson(Broadcast data) => json.encode(data.toJson());

class Broadcast {
  Broadcast({
    this.ambulaceno,
    this.from,
    this.to,
    this.mobileno,
    this.coordinates,
  });

  String? ambulaceno;
  String? from;
  String? to;
  String? mobileno;
  List<Coordinate>? coordinates = [];

  factory Broadcast.fromJson(Map<String, dynamic> json) => Broadcast(
        ambulaceno: json["ambulaceno"],
        from: json["from"],
        to: json["to"],
        mobileno: json["mobileno"],
        coordinates: List<Coordinate>.from(
            json["coordinates"].map((x) => Coordinate.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ambulaceno": ambulaceno,
        "from": from,
        "to": to,
        "mobileno": mobileno,
        "coordinates": List<dynamic>.from(coordinates!.map((x) => x.toJson())),
      };
}

class Coordinate {
  Coordinate({
    this.latitude,
    this.longitude,
    this.duration,
  });

  double? latitude;
  double? longitude;
  double? duration;

  factory Coordinate.fromJson(Map<String, dynamic> json) => Coordinate(
        latitude: json["latitude"],
        longitude: json["longitude"],
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "duration": duration,
      };
}
