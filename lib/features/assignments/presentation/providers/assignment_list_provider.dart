//ข้อมูลชั่วคราวจากผู้ใช้ (sync)
//โหลด “รายการ Assignment” จาก Database เพื่อแสดงผล

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';

import 'assignment_form_provider.dart';

final assignmentListProvider = FutureProvider<List<AssignmentRow>>(
  (ref) async {
    final dao = ref.watch(assignmentDaoProvider);
    return dao.getAll();
  },
);
