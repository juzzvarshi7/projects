class Appointment {
  final int id;
  final int staffId;
  final int principalId;
  final String title;
  final String details;
  final String requestedDatetime;
  final String status;
  final String? suggestedDatetime;
  final String staffName;
  final String principalName;

  Appointment({
    required this.id,
    required this.staffId,
    required this.principalId,
    required this.title,
    required this.details,
    required this.requestedDatetime,
    required this.status,
    this.suggestedDatetime,
    required this.staffName,
    required this.principalName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      staffId: json['staff_id'],
      principalId: json['principal_id'],
      title: json['title'],
      details: json['details'] ?? '',
      requestedDatetime: json['requested_datetime'],
      status: json['status'],
      suggestedDatetime: json['suggested_datetime'],
      staffName: json['staff_name'] ?? '',
      principalName: json['principal_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'staff_id': staffId,
        'principal_id': principalId,
        'title': title,
        'details': details,
        'requested_datetime': requestedDatetime,
        'status': status,
        'suggested_datetime': suggestedDatetime,
        'staff_name': staffName,
        'principal_name': principalName,
      };
}
