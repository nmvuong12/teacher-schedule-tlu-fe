// School Class Model
class SchoolClass {
  final int? classId;
  final String className;

  SchoolClass({
    this.classId,
    required this.className,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      classId: json['classId'],
      className: json['className'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'className': className,
    };
    
    // Only include classId if it's not null (for updates)
    if (classId != null) {
      json['classId'] = classId!;
    }
    
    return json;
  }
}


