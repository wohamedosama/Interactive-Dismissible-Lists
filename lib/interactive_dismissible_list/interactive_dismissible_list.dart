import 'package:flutter/material.dart';

class InteractiveDismissibleList extends StatelessWidget {
  const InteractiveDismissibleList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        centerTitle: true,
        leading: const Icon(Icons.arrow_back_ios),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.5,
        title: const Text('Task Manager', style: TextStyle(fontSize: 24)),
      ),
      body: const ReorderableExample(),
    );
  }
}

class ReorderableExample extends StatefulWidget {
  const ReorderableExample({super.key});

  @override
  State<ReorderableExample> createState() => _ReorderableExampleState();
}

class _ReorderableExampleState extends State<ReorderableExample> {
  final List<String> _tasks = [
    'Complete Flutter assignment',
    'Review Clean Architecture ',
    'Practice Widget catalog',
  ];

  late List<bool> _completedTasks;

  @override
  void initState() {
    super.initState();
    _completedTasks = List.generate(_tasks.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(_tasks[index]),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            await _showDeleteDialog(context, index);
            return false;
          },
          child: BoxShadowContainer(
            child: ListTile(
              key: ValueKey(_tasks[index]),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              leading: const Icon(Icons.drag_handle, color: Colors.grey),
              title: Text(
                _tasks[index],
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  decoration: _completedTasks[index]
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: _completedTasks[index] ? Colors.grey : Colors.black87,
                ),
              ),
              trailing: Checkbox(
                activeColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                value: _completedTasks[index],
                onChanged: (value) {
                  setState(() {
                    _completedTasks[index] = value ?? false;
                  });
                },
              ),
            ),
          ),
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) newIndex -= 1;
          final task = _tasks.removeAt(oldIndex);
          final completed = _completedTasks.removeAt(oldIndex);
          _tasks.insert(newIndex, task);
          _completedTasks.insert(newIndex, completed);
        });
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, int index) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Delete "${_tasks[index]}" ?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                final deletedTask = _tasks[index];
                final deletedIndex = index;
                final deletedTaskCompleted = _completedTasks[index];
                setState(() {
                  _tasks.removeAt(index);
                  _completedTasks.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Task Deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        setState(() {
                          _tasks.insert(deletedIndex, deletedTask);
                          _completedTasks.insert(
                            deletedIndex,
                            deletedTaskCompleted,
                          );
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class BoxShadowContainer extends StatelessWidget {
  const BoxShadowContainer({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12.0),
        ],
      ),
      child: child,
    );
  }
}
