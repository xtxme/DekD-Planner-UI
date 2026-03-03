import 'package:my_first_app/features/subjects/data/models/canvas_course.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//ติดต่อกับ Server (ในที่นี้คือ Supabase) เพื่อขอข้อมูลวิชาเรียนมาจาก Canvas LMS แล้วนำมา "ตรวจสอบและจัดระเบียบ" ให้กลายเป็น List ของวิชาเรียนที่พร้อมใช้งานในแอป

class CanvasCourseRemoteDataSource {
  const CanvasCourseRemoteDataSource({required SupabaseClient client}) //คลาสนี้มีสิทธิ์ในการเรียกใช้ฟังก์ชันต่างๆ ของ Supabase ได้
    : _client = client;

  final SupabaseClient _client;

  Future<List<CanvasCourse>> fetchCourses() async {
    final response = await _client.functions.invoke('canvas-proxy');

    if (response.status >= 400) {
      throw Exception(_extractErrorMessage(response.data)); //เอาข้อความสั้นๆ มาบอกเราว่า "พังเพราะอะไร"
    }

    final data = response.data;
    if (data is! List) {
      throw const FormatException('Canvas proxy returned an invalid response.');
    }

    return data
        .whereType<Map>() //เอาเฉพาะข้อมูลที่เป็น Map (ป้องข้อมูลแปลกปลอม)
        .map((item) => CanvasCourse.fromMap(Map<String, dynamic>.from(item))) //แปลง Map เป็น Object CanvasCourse
        .where((course) => course.id != 0 && course.name.trim().isNotEmpty) //กรองทิ้ง! ถ้า ID เป็น 0 หรือชื่อว่าง
        .toList(); //รวมเป็น List ส่งออกไป
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    return 'Canvas sync failed.';
  }
}
