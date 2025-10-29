class ServiceModel {
  final String? id;
  final String? name;
  final String? description;
  final String? specialization;

  const ServiceModel({
    this.id,
    this.name,
    this.description,
    this.specialization,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String? pickStr(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return null;
    }

    String? specialization;
    final practiceArea = json['practiceArea'];
    if (practiceArea is Map<String, dynamic>) {
      specialization = practiceArea['name']?.toString();
    }

    return ServiceModel(
      id: pickStr(['id', 'serviceId', 'serviceID', 'Id', 'ServiceId']),
      name: pickStr(['name', 'serviceName', 'title', 'Name']),
      description: pickStr(['description', 'desc', 'Description']),
      specialization: specialization ??
          pickStr([
            'specialization',
            'specializationName',
            'category',
            'field',
            'domain',
            'type'
          ]),
    );
  }
}
