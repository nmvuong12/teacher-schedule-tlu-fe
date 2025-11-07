// Subject Model
class Subject {
  final int? subjectId;
  final String subjectName;
  final int credits;

  Subject({
    this.subjectId,
    required this.subjectName,
    required this.credits,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subjectId'],
      subjectName: json['subjectName'] ?? '',
      credits: json['credits'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'subjectName': subjectName,
      'credits': credits,
    };
    
    // Only include subjectId if it's not null (for updates)
    if (subjectId != null) {
      json['subjectId'] = subjectId!;
    }
    
    return json;
  }
}


