# 🚨 วิเคราะห์และแก้ไขปัญหา Redirect Loop
**สร้างเมื่อ:** 2026-03-04 20:15
**สถานะ:** ✅ Debug logging เพิ่มเติมแล้ว - พร้อมรัน app

---

## 🔍 สรุปปัญหา

### สิ่งที่เกิดขึ้น:
1. **App เข้า Home Page แล้วกลับไป Login เลย** (Redirect Loop)
2. **บางครั้งก็เข้าได้** (แสดงว่าไม่เสมอในทุกครั้ง)

### ปัญหาที่อาจเป็นไปได้:
1. **CanvasSessionExpiredException ถูก throw ทันที HomePage load**
2. **Session เป็น null หรือถูก invalidate ระหว่าง login และ home page load**
3. **Edge Function ส่ง 401 ทันที (Authorization header ไม่ถูกต้อง)**
4. **Race condition ระหว่าง session ready และ navigation**

---

## ✅ สิ่งที่แก้ไขแล้ว

### 1. home_page.dart - Debug Logging เพิ่มเติม

**เพิ่ม logs:**
```dart
debugPrint('HOME_DEBUG: ==================================================');
debugPrint('HOME_DEBUG: initState() called');
debugPrint('HOME_DEBUG: build() called');
debugPrint('HOME_DEBUG: authSession.hasValue = ${authSession.hasValue}');
debugPrint('HOME_DEBUG: authSession.value = ${authSession.value}');
debugPrint('HOME_DEBUG: authSession.isLoading = ${authSession.isLoading}');
debugPrint('HOME_DEBUG: assignmentsAsync state = ...');
```

**เพิ่มใน `_handleExpiredSession()`:**
```dart
debugPrint('HOME_DEBUG: _handleExpiredSession() called');
debugPrint('HOME_DEBUG: Signing out...');
debugPrint('HOME_DEBUG: Showing snack bar and navigating to login...');
```

### 2. canvas_assignment_remote_data_source.dart - Debug logging พร้อมแล้ว

✅ มี CANVAS_DEBUG logs ครบถ้วนแล้ว

### 3. login_page.dart - Debug logging พร้อมแล้ว

✅ มี AUTH_DEBUG logs ครบถ้วนแล้ว

---

## 🧪 วิธีรัน Debug Script

### Step 1: รัน Script
```bash
./debug_redirect_issue.sh
```

### Step 2: ทำตามคำแนะนำใน terminal
1. รอจนกว่า app start
2. Login ด้วย email/password
3. **กด Enter** เมื่อเห็น Home Page หรือถูก redirect ไป Login

### Step 3: อ่านผลลัพธ์
Script จะ:
- บันทึก logs ทั้งหมดไป `debug_logs/flutter_output.txt`
- แยก logs เป็น 3 ไฟล์:
  - `debug_logs/auth_logs.txt` (AUTH_DEBUG)
  - `debug_logs/canvas_logs.txt` (CANVAS_DEBUG)
  - `debug_logs/home_logs.txt` (HOME_DEBUG)
- วิเคราะห์ปัญหาอัตโนมัติ
- แสดงสรุปปัญหาที่เจอ

---

## 📋 สิ่งที่ต้องส่งมาหลังจากรัน

### 1. Logs จาก Terminal
คัดลอก logs ที่แสดงบน terminal เมื่อรัน `./debug_redirect_issue.sh`

หรือไปอ่านไฟล์:
- `debug_logs/home_logs.txt` (**สำคัญที่สุด**)
- `debug_logs/canvas_logs.txt`
- `debug_logs/auth_logs.txt`

### 2. อธิบายสิ่งที่เห็น
- เห็นหน้า Home Page ไหม?
- ถูก redirect ไป Login ทันทีไหม?
- แสดง error ไหม?
- แสดง assignments ไหม?

---

## 🎯 สิ่งที่จะรู้จาก Debug Logs

### สถานการณ์ที่ 1: Session เป็น NULL เมื่อ HomePage load
**Logs:**
```
HOME_DEBUG: build() called
HOME_DEBUG: authSession.hasValue = true
HOME_DEBUG: authSession.value = null
HOME_DEBUG: ❌ No session found, redirecting to login
```

**สาเหตุ:** Session ถูก invalidate หรือยังไม่พร้อม
**วิธีแก้:** เพิ่มเวลาในการรอ session ใน login_page.dart

---

### สถานการณ์ที่ 2: CanvasSessionExpiredException ถูก throw
**Logs:**
```
HOME_DEBUG: Assignment provider changed
HOME_DEBUG: Error in assignments: Your session expired
HOME_DEBUG: Error type: CanvasSessionExpiredException
HOME_DEBUG: ❌ CanvasSessionExpiredException caught!
HOME_DEBUG: _handleExpiredSession() called
HOME_DEBUG: ❌ No session found, redirecting to login
```

**สาเหตุ:** Edge Function ส่ง 401 หรือ session ไม่ valid
**วิธีแก้:** ตรวจสอบว่า Supabase SDK ส่ง Authorization header ถูกต้อง

---

### สถานการณ์ที่ 3: Edge Function ส่ง 401
**Logs:**
```
CANVAS_DEBUG: Starting fetchAssignmentsWithUser()
CANVAS_DEBUG: Session exists: true
CANVAS_DEBUG: Sending request WITH session
CANVAS_DEBUG: Status: 401
CANVAS_DEBUG: ❌ AUTH FAILURE DETECTED!
```

**สาเหตุ:** Authorization header ไม่ถูกส่งไป Edge Function หรือ token ไม่ valid
**วิธีแก้:** ตรวจสอบ Edge Function logs ใน Supabase Dashboard

---

### สถานการณ์ที่ 4: ✅ ทำงานได้
**Logs:**
```
CANVAS_DEBUG: Status: 200
CANVAS_DEBUG: Assignments: 2
CANVAS_DEBUG: ✅ SUCCESSFULLY PARSED RESPONSE
HOME_DEBUG: assignmentsAsync state = data
HOME_DEBUG: ✅ Session exists, showing home page
```

**ผลลัพธ์:** ✅ ปัญหาเสร็จสมบูรณ์! assignments แสดงแล้ว

---

## 🔧 วิธีแก้ปัญหาที่อาจเป็นไปได้ (แบบละเอียด)

### Fix 1: เพิ่มเวลาในการรอ Session (ถ้า session ไม่พร้อม)

**ไฟล์:** `lib/features/auth/login_page.dart`

แก้ `_waitForSessionReady()`:

```dart
Future<void> _waitForSessionReady() async {
  final client = Supabase.instance.client;

  debugPrint('AUTH_DEBUG: _waitForSessionReady() called');

  // ✅ เพิ่มจาก 50 เป็น 100 รอบ (10 วินาที)
  for (var i = 0; i < 100; i++) {
    if (client.auth.currentSession != null) {
      debugPrint('AUTH_DEBUG: ✅ Session ready after ${i * 100}ms');
      return;
    }

    if (i % 10 == 0 && i > 0) {
      debugPrint('AUTH_DEBUG: Still waiting... (${i * 100}ms elapsed)');
    }

    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  debugPrint('AUTH_DEBUG: ❌ Session not ready after 10s');
}
```

และแก้ `canvas_assignment_remote_data_source.dart`:

```dart
Future<void> requireActiveSession() async {
  debugPrint('CANVAS_DEBUG: requireActiveSession() - waiting for session...');

  // ✅ เพิ่มจาก 50 เป็น 100 รอบ (10 วินาที)
  for (var attempt = 0; attempt < 100; attempt++) {
    final session = _client.auth.currentSession;

    if (attempt == 0) {
      debugPrint(
        'CANVAS_DEBUG: Initial session state: ${session != null ? "EXISTS" : "NULL"}',
      );
    }

    if (session != null) {
      debugPrint(
        'CANVAS_DEBUG: ✅ Session found after ${attempt * _sessionPropagationDelay.inMilliseconds}ms',
      );
      return;
    }

    if (attempt % 10 == 0 && attempt > 0) {
      debugPrint(
        'CANVAS_DEBUG: Still waiting... (${attempt * _sessionPropagationDelay.inMilliseconds}ms elapsed)',
      );
    }

    await Future<void>.delayed(_sessionPropagationDelay);
  }

  debugPrint('CANVAS_DEBUG: ❌ SESSION NOT READY AFTER 10000ms');
  throw const CanvasSessionExpiredException();
}
```

---

### Fix 2: ตรวจสอบว่า Supabase SDK ส่ง Authorization Header

ถ้าได้ logs:
```
CANVAS_DEBUG: Status: 401
CANVAS_DEBUG: ❌ AUTH FAILURE DETECTED!
```

หมายว่า Edge Function ไม่ได้รับ Authorization header

**วิธีตรวจสอบ:**
1. เข้า Supabase Dashboard
2. ไปที่ Edge Functions → canvas-assignments-proxy
3. ดู logs ล่าสุด
4. ดูว่ามี request เข้ามาไหม
5. ดูว่า authHeader เป็น null หรือไม่

**ถ้า authHeader เป็น null:**
- อาจเป็นปัญหา Supabase Flutter SDK version
- ลองอัปเกรด `supabase_flutter`:
  ```bash
  flutter pub upgrade supabase_flutter
  ```

---

### Fix 3: ตรวจสอบ Environment Variables ใน Edge Function

**ไปที่:** Supabase Dashboard → Edge Functions → canvas-assignments-proxy → Environment Variables

ตรวจสอบว่ามี:
- ✅ `SUPABASE_URL`
- ✅ `SUPABASE_ANON_KEY`
- ✅ `CANVAS_BASE_URL`
- ✅ `CANVAS_TOKEN`

---

## 📋 ไฟล์ที่สร้างให้

| ไฟล์ | วัตถุประสงค์ |
|------|----------------|
| `debug_redirect_issue.sh` | Script สำหรับรัน app และเก็บ debug logs |
| `lib/features/home/home_page.dart` | Debug logging เพิ่มเติมแล้ว |
| `DETAILED_ANALYSIS.md` | วิเคราะห์ปัญหาอย่างละเอียด |

---

## 🎯 ขั้นตอนถัดไป

### ✅ Step 1: รัน Debug Script
```bash
./debug_redirect_issue.sh
```

### ✅ Step 2: Login
- ใช้ email/password ที่ถูกต้อง
- ดู logs ใน terminal

### ✅ Step 3: กด Enter
- เมื่อเห็น Home Page
- หรือเมื่อถูก redirect ไป Login

### ✅ Step 4: อ่านผลลัพธ์
- Script จะแสดงสรุปปัญหา
- ไปอ่านไฟล์ใน `debug_logs/` directory

### ✅ Step 5: ส่ง Logs มาให้ฉัน
- คัดลอก logs จาก terminal
- หรือคัดลอกจากไฟล์ `debug_logs/home_logs.txt`
- อธิบายสิ่งที่เห็นบนหน้าจอ

---

## 🆘 ถ้าต้องการความช่วยเหลือเพิ่มเติม

ส่งข้อมูลต่อไปนี้:
1. **Logs ทั้งหมด** จาก `debug_logs/home_logs.txt`
2. **Logs จาก** `debug_logs/canvas_logs.txt`
3. **Logs จาก** `debug_logs/auth_logs.txt`
4. **อธิบายสิ่งที่เห็น:**
   - เห็นหน้า Home Page ไหม?
   - ถูก redirect ไป Login ทันทีไหม?
   - แสดง error ไหม?
   - แสดง assignments ไหม?
5. **Screenshot** ของหน้าจอ (ถ้าได้)

---

**สร้างเมื่อ:** 2026-03-04 20:15
**สถานะ:** ✅ Debug logging เพิ่มเติมแล้ว - พร้อมรัน debug script
