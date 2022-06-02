import 'package:flutter/material.dart';
import 'package:todo_list/app/models/todo_model.dart';
import 'package:todo_list/app/widgets/todo_list_widget.dart';
import 'package:todo_list/repositories/todo_repository.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();
  List<TodoTarefa> todos = [];

  TodoTarefa? deletedTodo;

  int? deletedTodoPosicao;

  String? errorText;

  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then(
      (value) {
        setState(
          () {
            todos = value;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lista de Tarefas"),
          centerTitle: true,
          backgroundColor: const Color(0xff00d7f3),
        ),
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
                        controller: todoController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Adicione uma Tarefa',
                          hintText: "ex. Estudar Flutter",
                          errorText: errorText,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff00d7f3),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;

                        if (text.isEmpty) {
                          setState(() {
                            errorText = "O título não pode ser vazio";
                          });
                          return;
                        }
                        setState(() {
                          TodoTarefa newTodoTarefa = TodoTarefa(
                            title: text,
                            dateTime: DateTime.now(),
                          );
                          todos.add(newTodoTarefa);
                          errorText = null;
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xff00d7f3),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (TodoTarefa todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Voce possui ${todos.length} tarefas pendentes'),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: showDeleteTodosConfirmationDialog,
                      child: const Text("Limpar Tudo"),
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xff00d7f3),
                        padding: const EdgeInsets.all(14),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(TodoTarefa todo) {
    deletedTodo = todo;
    deletedTodoPosicao = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Tarefa ${todo.title} foi removida com sucesso",
          style: const TextStyle(
            color: Color(0xff060708),
          ),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: "Desfazer",
          textColor: const Color(0xff00d7f3),
          onPressed: () {
            setState(() {
              todos.insert(
                deletedTodoPosicao!,
                deletedTodo!,
              );
            });
            todoRepository.saveTodoList(todos);
          },
        ),
      ),
    );
  }

  void showDeleteTodosConfirmationDialog() {
    if (todos.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Tem certeza que deseja pagar todas as tarefas?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                primary: const Color(0xff00d7f3),
              ),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteAllTodos();
              },
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
              child: const Text("Limpar Tudo"),
            ),
          ],
        ),
      );
    }
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
