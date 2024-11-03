import 'package:equatable/equatable.dart' show Equatable;

class Stop extends Equatable {
  const Stop({required this.id, required this.name, required this.lat, required this.lon});

  final String id;
  final String name;
  final double lat;
  final double lon;

  @override
  List<Object?> get props => [id, name, lat, lon];
}
