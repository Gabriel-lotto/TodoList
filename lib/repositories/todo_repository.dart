import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/app/models/todo_model.dart';

const todoListKey = 'todo_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;

  Future<List<TodoTarefa>> getTodoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecoded = jsonDecode(jsonString) as List;
    return jsonDecoded.map((json) => TodoTarefa.fromJson(json)).toList();
  }

  void saveTodoList(List<TodoTarefa> todos) {
    final jsonString = jsonEncode(todos);
    sharedPreferences.setString(todoListKey, jsonString);
  }
}
