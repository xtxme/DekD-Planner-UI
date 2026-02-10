import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';

abstract class AssignmentDao {
  Future<int> insert(AssignmentRow row);
  Future<List<AssignmentRow>> getAll();
  Future<int> update(AssignmentRow row);
  Future<int> delete(int id);
}
