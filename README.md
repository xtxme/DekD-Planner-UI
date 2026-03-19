# DekD Planner

คู่มือสำหรับผู้ประเมิน Android APK ของโปรเจกต์ DekD Planner

## ภาพรวมโปรเจกต์

DekD Planner เป็นแอป Flutter สำหรับช่วยจัดการการเรียน โดยมีฟังก์ชันหลักดังนี้

- สมัครสมาชิกและเข้าสู่ระบบ
- ดูรายวิชาและรายละเอียดของแต่ละวิชา
- ดูงานที่ได้รับมอบหมาย
- จัดการข้อมูลงานและการแจ้งเตือน

ชื่อแอปบน Android คือ `DekD Planner` และ package name ปัจจุบันคือ `com.xtxme.dekdplanner`

## Repository และไฟล์ที่ใช้ส่ง

- Repository: `https://github.com/xtxme/DekD-Planner-UI.git`
- ไฟล์ APK สำหรับส่ง: `build/app/outputs/flutter-apk/app-release.apk`

หากผู้ประเมินได้รับ repository แต่ยังไม่ได้รับไฟล์ APK ให้ใช้ไฟล์ตาม path ข้างต้นหลังจากผู้ส่ง build แบบ release แล้ว

## วิธีติดตั้งและเปิดใช้งานบน Android

1. นำไฟล์ `app-release.apk` ไปไว้ในโทรศัพท์ Android
2. เปิดไฟล์ APK บนอุปกรณ์
3. หากระบบถามสิทธิ์ ให้อนุญาตการติดตั้งจากไฟล์ภายนอก
4. กดติดตั้งแอป
5. เปิดแอป `DekD Planner`

## ข้อมูลสำหรับผู้ประเมิน

กรุณากรอกข้อมูลส่วนนี้ก่อนส่งงานจริง

- อีเมลสำหรับทดสอบ: `tt.icy013@gmail.com`
- รหัสผ่านสำหรับทดสอบ: `[12345679]`
- หมายเหตุเพิ่มเติม เช่น role, seed data, หรือขั้นตอนเตรียมบัญชี: `[กรอกก่อนส่ง]`

หากแอปต้องใช้บัญชีที่มีข้อมูลตัวอย่างอยู่แล้ว ผู้ส่งควรตรวจให้แน่ใจว่าบัญชีนี้ login ได้จริงก่อนส่ง APK

## ลำดับการทดสอบที่แนะนำ

1. ติดตั้ง APK และเปิดแอป
2. เข้าสู่ระบบด้วยบัญชีที่เตรียมไว้
3. ตรวจว่าแอปสามารถโหลดข้อมูลจาก backend ได้ตามปกติ
4. ตรวจหน้า subjects ว่าสามารถแสดงรายวิชาได้
5. ตรวจหน้า assignments ว่าสามารถแสดงงานที่เกี่ยวข้องได้
6. หากมีการใช้งาน notification ให้ยอมรับสิทธิ์ที่ Android ขอ แล้วตรวจการทำงานตามโจทย์

## หมายเหตุเรื่อง Backend และ Environment

แอปนี้อ่านค่าจาก `.env` ตอน build และค่าดังกล่าวจะถูก bundle เข้าไปในตัวแอป ดังนั้น APK ที่ส่งต้องถูก build ด้วยค่าจริงที่ใช้งานได้

ค่าที่จำเป็นมีดังนี้

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `CANVAS_BASE_URL`
- `CANVAS_TOKEN`

ข้อสำคัญ:

- backend ที่ใช้ประเมินต้องเข้าถึงได้จากโทรศัพท์จริง
- ไม่ควรใช้ service ที่เปิดได้เฉพาะ `localhost` หรือ `127.0.0.1`
- ถ้า backend ยังไม่พร้อม แอปอาจติดตั้งได้แต่ใช้งานจริงไม่ได้

ตัวอย่างไฟล์ environment template ดูได้ที่ [.env.example](/Users/icy/flutter/DekD-Planner/DekD-Planner-UI/.env.example)

## ข้อจำกัดที่ควรทราบ

- release APK ปัจจุบันอาจยังใช้ debug signing หากยังไม่ได้ตั้งค่า signing key สำหรับ production
- การ build release ต้องใช้คำสั่ง `flutter build apk --release --no-tree-shake-icons`
- เหตุผลที่ต้องใช้ `--no-tree-shake-icons` คือโปรเจกต์นี้มีการ reconstruct บาง Material icons จาก stored codepoints
- หากการประเมินครอบคลุม notification ผู้ประเมินต้องกดยอมรับ permission บนอุปกรณ์ Android

## ข้อมูลสำหรับผู้ส่งงาน

ก่อนส่งจริง ควรตรวจรายการต่อไปนี้

- มีไฟล์ `build/app/outputs/flutter-apk/app-release.apk`
- อัปเดตบัญชีทดสอบใน README แล้ว
- backend ที่ใช้ประเมินยัง online และเข้าถึงได้จริง
- `.env.example` สะท้อน key ที่จำเป็นครบ

## หมายเหตุสำหรับผู้พัฒนา

หากต้องการ build APK ใหม่ ให้ใช้คำสั่งนี้

```bash
flutter pub get
flutter build apk --release --no-tree-shake-icons
```

หากต้องการรายละเอียดการส่งงานเพิ่มเติม ดูได้ที่ [docs/submission/android-apk-submission.md](/Users/icy/flutter/DekD-Planner/DekD-Planner-UI/docs/submission/android-apk-submission.md)
