import 'package:flutter/material.dart';
import 'package:todo_list/repositories/todo_repository.dart';
import '../widgets/todo_list_item.dart';
import 'models/todo.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoControler = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = []; //tarefas
  Todo? deletedTodo; //fução desfazer
  int? deledTodoPos; //função irá retornar a tarefa deletada na posição de origem

  String? errorText; //Nullable pois nem sempre teremos a mensagem de erro

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoControler,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Adicione uma tarefa',
                          hintText: 'Ex: Estudar Flutter',
                          errorText:  errorText,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoControler.text;

                        if(text.isEmpty){ //verifica se a caixa de texto esta vazia
                          setState(() {
                            errorText = 'O titulo não pode ser vazio';
                          });
                          return;
                        }

                        setState(() {
                          Todo newTodo = Todo( //adiciona nova tarefa
                            title: text,
                            dateTime: DateTime.now(),
                          );
                          todos.add(newTodo);
                          errorText = null;
                        });
                        todoControler.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightBlueAccent,
                        padding: EdgeInsets.all(16),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      //aumenta largura de acordo com as bordas
                      child: Text(
                        'Voce possui ${todos.length} tarefas pendentes',
                      ),
                    ),
                    SizedBox(width: 8), //Separa entre as colunas
                    ElevatedButton(
                      //Botão de limpar
                      onPressed: showDeletedTodosConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightBlueAccent,
                        padding: EdgeInsets.all(16),
                      ),
                      child: Text('Limpar tudo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo; //sava na variavel a tarefa deletada
    deledTodoPos = todos.indexOf(todo); //qual posição da tarefa na lista

    setState(() {
      todos.remove(todo); // remove a tarefa da lista
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context)
        .clearSnackBars(); // limpa a mensagem anterior de apagar e eatualiza para nova deletada
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa ${todo.title} foi removida com sucesso!'),
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.lightBlueAccent,
          onPressed: () {
            setState(() {
              todos.insert(deledTodoPos!,
                  deletedTodo!); //Para garantir que não são Nullables poem !
            });
            todoRepository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 5), // determina a duração da snackBar
      ),
    );
  }

  void showDeletedTodosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar tudo?'),
        content: Text('Você tem certeza que deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              primary: Colors.lightBlueAccent,
            ),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
            },
            style: TextButton.styleFrom(
              primary: Colors.red,
            ),
            child: Text('Limpar Tudo'),
          ),
        ],
      ),
    );
  }

  void deleteAllTodos(){
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }

}
