import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/subjects/data/models/canvas_course.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';
import 'package:my_first_app/features/subjects/data/remote/canvas_course_remote_data_source.dart';
import 'package:my_first_app/features/subjects/data/remote/supabase_subject_dao.dart';

final subjectDaoProvider = Provider<SubjectDao>(
  (ref) => SupabaseSubjectDao(client: ref.watch(supabaseClientProvider)),
);

final subjectListProvider = FutureProvider<List<SubjectRow>>(
  (ref) async => ref.watch(subjectDaoProvider).getAll(),
);

final canvasCourseRemoteDataSourceProvider =
    Provider<CanvasCourseRemoteDataSource>(
      (ref) => CanvasCourseRemoteDataSource(
        client: ref.watch(supabaseClientProvider),
      ),
    );

final canvasCoursesProvider = FutureProvider<List<CanvasCourse>>((ref) async {
  return ref.watch(canvasCourseRemoteDataSourceProvider).fetchCourses();
});

final canvasCourseImporterProvider = Provider<CanvasCourseImporter>(
  (ref) => CanvasCourseImporter(ref),
);

enum CanvasImportStatus { imported, alreadyImported }

class CanvasImportResult {
  const CanvasImportResult({required this.status, required this.subjectName});

  final CanvasImportStatus status;
  final String subjectName;
}

class CanvasCourseImporter {
  CanvasCourseImporter(this._ref);

  final Ref _ref;

  Future<CanvasImportResult> importCourse(CanvasCourse course) async {
    final trimmedName = course.name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Canvas course name is required for import.');
    }

    final dao = _ref.read(subjectDaoProvider);
    final existing = await dao.findByName(trimmedName);
    if (existing != null) {
      _invalidateLists();
      return CanvasImportResult(
        status: CanvasImportStatus.alreadyImported,
        subjectName: existing.name,
      );
    }

    await dao.insert(
      SubjectRow(
        name: trimmedName,
        code: course.courseCode.trim(),
        description: course.importDescription,
        colorValue: 0xFFE2D4C7,
        iconCodepoint: Icons.menu_book_rounded.codePoint,
        isArchived: false,
      ),
    );

    _invalidateLists();
    return CanvasImportResult(
      status: CanvasImportStatus.imported,
      subjectName: trimmedName,
    );
  }

  void _invalidateLists() {
    _ref.invalidate(subjectListProvider);
    _ref.invalidate(canvasCoursesProvider);
  }
}

final subjectDeleterProvider = Provider<SubjectDeleter>(
  (ref) => SubjectDeleter(ref),
);

class SubjectDeleter {
  SubjectDeleter(this._ref);

  final Ref _ref;

  Future<void> delete(String id) async {
    await _ref.read(subjectDaoProvider).delete(id);
    _ref.invalidate(subjectListProvider);
    _ref.invalidate(canvasCoursesProvider);
  }
}
