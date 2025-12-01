// todo_list.dart
import 'package:flutter/material.dart';

class TodoList extends StatelessWidget {
  const TodoList({
    super.key,
    required this.tarea,
    required this.asignado,
    required this.estado,
    required this.prioridad,
    this.onEstadoChanged,
    this.onPrioridadChanged,
  });

  final String tarea;
  final String asignado;
  final String estado;
  final String prioridad;
  final Function(String)? onEstadoChanged;
  final Function(String)? onPrioridadChanged;

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Icons.access_time;
      case 'En Progreso':
        return Icons.play_arrow;
      case 'Completado':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  IconData _getPrioridadIcon(String prioridad) {
    switch (prioridad) {
      case 'Alta':
        return Icons.arrow_upward;
      case 'Media':
        return Icons.remove;
      case 'Baja':
        return Icons.arrow_downward;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = estado == 'Completado';
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 106, 1, 226),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tarea,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.white,
                decorationThickness: 3,
              ),
            ),
            SizedBox(height: 10),
            Text('Asignado: $asignado', style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(_getEstadoIcon(estado), color: Colors.white),
                SizedBox(width: 10),
                Text('Estado:', style: TextStyle(color: Colors.white)),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: estado,
                    dropdownColor: const Color.fromARGB(255, 1, 21, 199),
                    style: TextStyle(color: Colors.white),
                    items: ['Pendiente', 'En Progreso', 'Completado'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => onEstadoChanged?.call(value!),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(_getPrioridadIcon(prioridad), color: Colors.white),
                SizedBox(width: 10),
                Text('Prioridad:', style: TextStyle(color: Colors.white)),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: prioridad,
                    dropdownColor: const Color.fromARGB(255, 2, 15, 197),
                    style: TextStyle(color: Colors.white),
                    items: ['Alta', 'Media', 'Baja'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => onPrioridadChanged?.call(value!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
