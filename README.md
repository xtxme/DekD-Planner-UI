# DekD Planner UI (Flutter)

UI สำหรับ DekD Planner ใช้ Flutter + Riverpod เพื่อการจัดการสถานะ และ UI ที่สวยงาม โดยออกแบบให้สามารถพัฒนาและขยายฟีเจอร์ต่างๆ ได้ง่าย

## Overview / ภาพรวม
DekD Planner UI คือส่วนหน้าของแอปที่ให้ผู้ใช้ลงชื่อเข้าใช้งาน ดูหน้าวิชา, งาน, ปฏิทิน และการตั้งค่า ผ่าน Navbar ที่ใช้งานร่วมกันทั่วทั้งแอป

## Tech Stack / เทคโนโลยี
- Flutter
- Riverpod (State Management)
- Dart

## Getting Started / เริ่มใช้งาน
Prerequisites / สิ่งที่ต้องมี
- Flutter SDK ติดตั้งแล้ว
- ติดตั้ง Xcode (macOS) หรือ Android Studio / Android SDK ตามแพลตฟอร์มที่ใช้งาน

Setup / ตั้งค่า
- Clone หรือคัดลอกโปรเจกต์ DekD Planner UI ไปยังเครื่องของคุณ
- ในโฟลเดอร์ DekD-Planner-UI รัน:
  - `flutter pub get`
  - `flutter run`

Run / รันแอป
- เลือก target device (iOS/Android) แล้วคลิก Run หรือใช้คำสั่ง `flutter run` ในเทอร์มินัล

## Project Structure / โครงสร้างโปรเจกต์
```
lib/
├── main.dart
├── features/
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── providers.dart          # Riverpod providers สำหรับ auth
│   ├── home/
│   │   ├── home_page.dart
│   │   └── providers.dart
│   ├── subjects/
│   │   ├── subjects_page.dart
│   │   └── providers.dart
│   ├── assignments/
│   │   ├── assignments_page.dart
│   │   └── providers.dart
│   ├── calendar/
│   │   ├── calendar_page.dart
│   │   └── providers.dart
│   └── settings/
│       ├── settings_page.dart
│       └── providers.dart
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   └── routes/
│       └── app_routes.dart
├── shared/
│   └── widgets/
│       ├── app_navbar.dart         # Component ใช้บ่อย (Navbar)
│       ├── common_button.dart
│       ├── custom_textfield.dart
│       └── loading_indicator.dart
└── models/
    ├── user.dart
    ├── subject.dart
    └── assignment.dart
```

## File Descriptions / อธิบายไฟล์หลัก
- lib/main.dart
  จุดเริ่มต้นของแอป ตั้งค่า MaterialApp, theme, initial route และ ProviderScope สำหรับ Riverpod
- lib/core/theme/app_theme.dart
  กำหนดธีมสี ฟอนต์ และสไตล์พื้นฐาน (รวมถึง Light/Dark theme)
- lib/core/routes/app_routes.dart
  กำหนดชื่อเส้นทาง และการใช้งาน onGenerateRoute เพื่อ navigation ระหว่างหน้า
- lib/features/auth/login_page.dart
  หน้าเข้าสู่ระบบด้วยฟอร์ม Email/Password
- lib/features/auth/register_page.dart
  หน้าลงทะเบียนผู้ใช้ใหม่
- lib/features/auth/providers.dart
  Providers สำหรับ authentication และ validation
- lib/features/home/home_page.dart
  หน้าหลักสรุปภาพรวมของวัน งาน วิชา
- lib/features/subjects/subjects_page.dart
  หน้ารายการวิชาและการดำเนินการ CRUD
- lib/features/assignments/assignments_page.dart
  หน้าการบ้าน/งาน พร้อมกำหนด deadline และ notes
- lib/features/calendar/calendar_page.dart
  ปฏิทินและเหตุการณ์ที่เกี่ยวข้อง
- lib/features/settings/settings_page.dart
  ตั้งค่าแอป เช่น เปิด–ปิด Notifications
- lib/shared/widgets/app_navbar.dart
  Navbar ใช้สลับระหว่าง Home, Subjects, Assignments, Calendar และ Settings
- lib/shared/widgets/common_button.dart
  ปุ่มสไตล์มาตรฐานสำหรับแอป
- lib/shared/widgets/custom_textfield.dart
  TextField ที่มีสไตล์และ validation พื้นฐาน
- lib/shared/widgets/loading_indicator.dart
  ตัวบ่งชี้โหลด
- lib/models/user.dart, subject.dart, assignment.dart
  แบบจำลองข้อมูลสำหรับผู้ใช้งาน รายวิชา และงาน

## Usage / วิธีใช้งาน
- รันโปรเจกต์:
  - ติดตั้ง dependencies: `flutter pub get`
  - รัน: `flutter run`

## Contributing
- Placeholder: จะเพิ่มรายละเอียดการ contributing ต่อไป

## License
- Placeholder: จะระบุ License ในภายหลัง

## CI/CD
- Placeholder: จะระบุรายละเอียด CI/CD ในอนาคต

## Notes / หมายเหตุ
- README.md นี้ออกแบบเพื่อเป็นเอกสารเริ่มต้นสำหรับ DekD Planner UI และสามารถปรับปรุงได้ตลอดเวลา
