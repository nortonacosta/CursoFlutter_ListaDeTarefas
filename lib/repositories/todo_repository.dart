import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../pages/models/todo.dart';


const todoListKey = 'todo_list';


class TodoRepository{

  late SharedPreferences sharedPreferences;

  Future<List<Todo>> getTodoList() async{

    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]'; // - ?? se a lista esta vazia o valor padrão é []
    final List jsonDecode = json.decode(jsonString) as List; // decodificando o json
    return jsonDecode.map((e) => Todo.fromJson(e)).toList(); //que tipo de lista deverá ser convertida
  }



  void saveTodoList(List<Todo> todos){  //Salvando lista em um Json
    final String jsonString = json.encode(todos);
    sharedPreferences.setString('todo_list', jsonString);
  }

}