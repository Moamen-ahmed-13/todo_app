class Task {
  final String title;
  final bool isDone;
  final DateTime? date;

  Task({
    required this.title,
    this.isDone = false,
    this.date,
  });

  Task copyWith({
    String? title,
    bool? isDone,
    DateTime? date,
  }) {
    return Task(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      date: date ?? this.date,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isDone: json['isDone'] ?? false,
        date: json['date'] != null ? DateTime.parse(json['date']) : null,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
        'date': date?.toIso8601String(),
      };
}