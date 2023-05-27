import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String task;
  final String description;
  bool? isCanceled;

  Todo(
      {required this.id,
      required this.task,
      required this.description,
      this.isCanceled}) {
    isCanceled = isCanceled ?? false;
  }

  Todo copyWith({
    String? id,
    String? task,
    String? description,
    bool? isCanceled,
  }) {
    return Todo(
      id: id ?? this.id,
      task: task ?? this.task,
      description: description ?? this.description,
      isCanceled: isCanceled ?? this.isCanceled,
    );
  }

  // To Compare
  @override
  List<Object?> get props => [
        id,
        task,
        description,
        isCanceled,
      ];

  static List<Todo> todos = [
    Todo(
      id: '1',
      task: 'Sample Todo 1',
      description: 'Test Todo',
    ),
    Todo(
      id: '2',
      task: 'Sample Todo 2',
      description: 'Test Todo',
    ),
  ];
}
