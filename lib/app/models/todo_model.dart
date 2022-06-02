class TodoTarefa {
  String title;
  DateTime dateTime;

  TodoTarefa({required this.title, required this.dateTime});

  TodoTarefa.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        dateTime = DateTime.parse(json['dateTime']);

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "dateTime": dateTime.toIso8601String(),
    };
  }
}
