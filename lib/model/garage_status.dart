class GarageStatus{
  final int id;
  final String title;

  final bool porta_estado;

  final DateTime createdAt;
  final DateTime? updatedAt;

  GarageStatus({
    required this.id,
    required this.title,
    required this.porta_estado,
    required this.createdAt,
    this.updatedAt
  });

  factory GarageStatus.fromMap(Map<String, dynamic> map) {
    return GarageStatus(
      id: map['id'],
      title: map['title'],
      porta_estado: map['porta_estado'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}