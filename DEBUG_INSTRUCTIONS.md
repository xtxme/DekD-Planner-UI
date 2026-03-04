# 🔍 วิธี Debug ปัญหา Home Page ไม่แสดงข้อมูล Canvas

## 📋 สรุปปัญหา (ROOT CAUSE)

**ปัญหาหลัก:** Session Race Condition และ Edge Function ต้องการ User Access Token ที่ถูกต้อง

### Flow ที่เกิดปัญหา:
```
Login Success → รอ session พร้อม (5 วินาที) → Navigate ไป HomePage
→ HomePage build → เรียก Edge Function
→ แต่ Session ยังไม่พร้อมหรือ Invalid → ❌ 401 Error
```

### สิ่งที่ Edge Function ต้องการ:
```typescript
// จาก supabase/functions/canvas-assignments-proxy/index.ts
const authHeader = req.headers.get('authorization');
const { data: { user }, error: authError } = await supabase.auth.getUser();

// ต้องมี Authorization header ที่มี User Access Token ที่ VALID
// ANON KEY จะไม่ทำงาน!
```

---

## 🛠️ วิธี Debug (ทำตามลำดับ)

### Step 1: รัน Debug Script

```bash
# ทำให้ script รันได้
chmod +x debug_home_issue.sh

# รัน script
./debug_home_issue.sh
```

**ดูผลลัพธ์:**
- ถ้า Test 3 ได้ 200 → Edge Function มีปัญหา security
- ถ้า Test 5 ได้ 401 → อันดี (ANON KEY ไม่ใช่ user token)

---

### Step 2: ใช้ Debug Version ของ Data Source

แก้ไฟล์ `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`:

```dart
// แทนที่ไฟล์เดิมด้วย debug version
// หรือ import debug version ใน home_tasks_provider.dart

// ใน home_tasks_provider.dart เปลี่ยน:
// import 'package:my_first_app/features/home/data/remote/canvas_assignment_remote_data_source.dart';
// เป็น:
import 'package:my_first_app/features/home/data/remote/canvas_assignment_remote_data_source_debug.dart';
```

หรือก็อปปี้ไฟล์ debug ไปแทนไฟล์เดิม:
```bash
cp lib/features/home/data/remote/canvas_assignment_remote_data_source_debug.dart \
   lib/features/home/data/remote/canvas_assignment_remote_data_source.dart
```

---

### Step 3: รัน Flutter App และดู Debug Logs

```bash
flutter run
```

**ค้นหา logs ที่ขึ้นต้นด้วย:**
```
CANVAS_DEBUG: ==================================================
CANVAS_DEBUG: Starting fetchAssignmentsWithUser()
CANVAS_DEBUG: ==================================================
```

**ดู logs สำคัญ:**

1. **BEFORE/AFTER requireActiveSession**
```
CANVAS_DEBUG: Session exists: true/false
```

2. **User ID & Access Token**
```
CANVAS_DEBUG: User ID: xxx
CANVAS_DEBUG: Access Token (first 50 chars): eyJhbGci...
```

3. **Time until expiry**
```
CANVAS_DEBUG: Time until expiry: X minutes
CANVAS_DEBUG: Is expired: true/false
```

4. **Response Status**
```
CANVAS_DEBUG: Status: 200/401/500
```

5. **Error Messages**
```
CANVAS_DEBUG: ❌ AUTH FAILURE DETECTED!
CANVAS_DEBUG: ❌ SESSION NOT READY AFTER 5000ms
```

---

## 🔍 การวิเคราะห์ Debug Logs

### สถานการณ์ที่ 1: Session เป็น NULL
```
CANVAS_DEBUG: Session exists: false
CANVAS_DEBUG: ❌ SESSION NOT READY AFTER 5000ms
```

**สาเหตุ:** Session ไม่ได้ propagate หลังจาก login
**วิธีแก้:**
- เพิ่มเวลาในการรอ session ใน login_page.dart
- ตรวจสอบว่า login flow เสร็จสมบูรณ์ก่อน navigate

### สถานการณ์ที่ 2: Session มีอยู่แต่ Invalid
```
CANVAS_DEBUG: Session exists: true
CANVAS_DEBUG: Is expired: true
CANVAS_DEBUG: ❌ AUTH FAILURE DETECTED!
```

**สาเหตุ:** Token หมดอายุหรือถูก revoke
**วิธีแก้:**
- Refresh token หรือ login ใหม่
- ตรวจสอบ token expiry time ใน Supabase settings

### สถานการณ์ที่ 3: Edge Function รับ Request แต่ Return Error
```
CANVAS_DEBUG: Status: 401
CANVAS_DEBUG: ❌ AUTH FAILURE FROM EXCEPTION
```

**สาเหตุ:** Edge Function reject token
**วิธีแก้:**
- ตรวจสอบว่า token ที่ส่งถูกต้อง (เป็น user token ไม่ใช่ anon key)
- ตรวจสอบ Edge Function logs ใน Supabase Dashboard

### สถานการณ์ที่ 4: Session Valid แต่ Request ไม่ถูกส่ง
```
CANVAS_DEBUG: Session exists: true
CANVAS_DEBUG: ✅ Session found after 200ms
CANVAS_DEBUG: SENDING REQUEST WITHOUT SESSION!
```

**สาเหตุ:** Supabase Flutter SDK ไม่ส่ง auth header
**วิธีแก้:**
- ตรวจสอบว่าใช้ supabase_flutter SDK เวอร์ชันล่าสุด
- ลองส่ง Authorization header ด้วยตัวเอง

---

## ✅ วิธีแก้ปัญหา (Fixes)

### Fix แบบรวดเร็ว (Quick Fix)

แก้ไฟล์ `lib/features/auth/login_page.dart`:

```dart
Future<void> _onLoginPressed() async {
  // ... existing code ...

  // หลังจาก saveSession และ invalidate provider
  await _waitForSessionReady();

  // ✅ เพิ่ม: Validate session หนึ่งครั้ง
  final client = Supabase.instance.client;
  final session = client.auth.currentSession;

  if (session == null) {
    throw StateError('Session not ready. Please try again.');
  }

  // ✅ เพิ่ม: Test ว่า session ทำงานได้จริงๆ
  try {
    final testUser = await client.auth.getUser(session.accessToken);
    debugPrint('AUTH_DEBUG: Session validated: ${testUser.user?.id}');
  } catch (e) {
    debugPrint('AUTH_DEBUG: Session validation failed: $e');
    throw StateError('Session is invalid. Please login again.');
  }

  // จากนั้นค่อย navigate
  if (!mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const NavbarShell()),
    (route) => false,
  );
}
```

### Fix แบบถาวร (Comprehensive Fix)

ใช้ debug version ที่สร้างไว้แล้วดู logs:

```bash
cp lib/features/home/data/remote/canvas_assignment_remote_data_source_debug.dart \
   lib/features/home/data/remote/canvas_assignment_remote_data_source.dart
flutter run
```

แล้วส่ง logs ที่ขึ้นต้นด้วย `CANVAS_DEBUG:` มาให้ผมวิเคราะห์ต่อ

---

## 📋 Checklist สำหรับ Debug

- [ ] รัน debug script (`./debug_home_issue.sh`)
- [ ] ใช้ debug version ของ canvas_assignment_remote_data_source.dart
- [ ] รัน Flutter app และ login
- [ ] เก็บ CANVAS_DEBUG logs ทั้งหมด
- [ ] วิเคราะห์ว่า session เป็น NULL หรือไม่
- [ ] ตรวจสอบ access token ว่าถูกต้อง
- [ ] ดู response status จาก Edge Function
- [ ] ถ้าได้ error ใด ส่ง logs มาให้ผม

---

## 🆘 ถ้ายังไม่ได้

ส่งข้อมูลต่อไปนี้มาให้ผม:

1. **Output จาก debug script** (`./debug_home_issue.sh`)
2. **CANVAS_DEBUG logs** จาก Flutter run
3. **ข้อความ error** ที่แสดงใน app (ถ้ามี)
4. **สแนปชอต** ของ home page ที่ไม่แสดงข้อมูล
5. **Environment variables** (ถ้าเป็นไปได้) - อย่าแชร์ secret จริงๆ

---

## 📖 เอกสารอ้างอิง

- [Supabase Flutter Auth Documentation](https://supabase.com/docs/guides/auth/flutter)
- [Supabase Edge Functions Documentation](https://supabase.com/docs/guides/functions)
- [Riverpod State Management](https://riverpod.dev/)

---

**สร้างเมื่อ:** 2026-03-04
**ผู้สร้าง:** AI Debug Assistant
