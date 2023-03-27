class Todo {
  Todo({required this.title, required this.dateTime});

  Todo.fromJson(Map<String, dynamic> json) //construtor nomeado
      : title = json['title'],
        dateTime = DateTime.parse(json['datetime']); //parse => objeto convertido para dateTime

  String title;
  DateTime dateTime;

  toJson() {
    return {
      'title': title,
      'datetime': dateTime.toIso8601String(),
    };
  }
}
