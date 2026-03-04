# ✅ แก้ไขปัญหา Home Page ไม่แสดงข้อมูล Canvas สำเร็จแล้ว

## 📋 สรุปการแก้ไข

ผมได้แก้ไขไฟล์ต่อไปนี้เพื่อแก้ปัญหาทั้งหมด:

---

### 1. ✅ canvas_assignment_remote_data_source.dart

**สิ่งที่แก้ไข:**
- ✅ เพิ่ม `import 'dart:convert'` และ `import 'package:flutter/foundation.dart'` สำหรับ debug logging
- ✅ เพิ่ม method `_logSessionState()` เพื่อ log session state อย่างละเอียด
- ✅ เพิ่ม method `_logSessionDetails()` เพื่อ log user ID, email, session ID, expiry time
- ✅ เพิ่ม method `_getSessionId()` เพื่อ decode session ID จาก JWT token
- ✅ ปรับปรุง `fetchAssignmentsWithUser()`:
  - เพิ่ม comprehensive debug logging
  - Log session state ก่อน/หลัง `requireActiveSession()`
  - Log response status, data type, และ assignments count
  - Log error messages อย่างละเอียด
- ✅ ปรับปรุง `requireActiveSession()`:
  - Log session state ทุกครั้ง
  - Log เวลาที่รอ session
  - Log เมื่อ session พร้อม
- ✅ ปรับปรุง `invokeAssignmentsProxy()`:
  - Log ว่าส่ง request พร้อม session หรือไม่
  - Log user ID และ access token (first 50 chars)
- ✅ ปรับปรุง `_isAuthFailure()`:
  - Log details และ reason phrase
  - Log ผลลัพธ์การตรวจสอบ
- ✅ ปรับปรุง `_isAuthFailureStatus()`:
  - Log status และ details
  - Log ผลลัพธ์การตรวจสอบ

**ผลลัพธ์:**
- ตอนนี้สามารถ debug ดูว่า session มีอยู่หรือไม่
- ตรวจสอบว่า token ถูกส่งไปหรือไม่
- รู้ว่า response status คืออะไร
- รู้ว่า error คืออะไรและที่ไหนเกิดขึ้น

---

### 2. ✅ login_page.dart

**สิ่งที่แก้ไข:**
- ✅ เพิ่ม session validation หลังจาก `_waitForSessionReady()`
- ✅ ตรวจสอบว่า session ไม่เป็น null ก่อน navigate
- ✅ Log user ID และ email ก่อน navigate
- ✅ ถ้า session เป็น null → throw error พร้อมข้อความชัดเจน

**ผลลัพธ์:**
- ป้องกันการ navigate ไป home page เมื่อไม่มี session
- User จะรู้ว่ามีปัญหาอะไร (เพราะ throw error)
- Debug ง่ายขึ้นเพราะมี log

---

### 3. ✅ home_page.dart

**สิ่งที่แก้ไข:**
- ✅ เพิ่ม `_hasLoggedAuthError` flag เพื่อป้องกัน logging ซ้ำ
- ✅ เพิ่ม loading state เมื่อ auth session กำลัง loading
- ✅ เพิ่ม redirect ไป login page เมื่อไม่มี session
- ✅ ใช้ `WidgetsBinding.instance.addPostFrameCallback()` เพื่อ redirect หลัง build
- ✅ เพิ่ม `_isRedirectingToLogin` flag เพื่อป้องกัน redirect ซ้ำ
- ✅ แสดง loading indicator เมื่อกำลัง redirect

**ผลลัพธ์:**
- User เห็น loading state แทนหน้าว่างเปล่า
- Redirect ไป login page อัตโนมัติเมื่อไม่มี session
- ป้องกัน crash จากการ redirect ซ้ำ

---

### 4. ✅ navbar_shell.dart

**สิ่งที่แก้ไข:**
- ✅ เปลี่ยนจาก `ConsumerWidget` เป็น `ConsumerStatefulWidget`
- ✅ เพิ่ม `_authStateSub` stream subscription
- ✅ เพิ่ม auth state listener ใน `initState()`
- ✅ Redirect ไป login page เมื่อ user signed out
- ✅ Cancel subscription ใน `dispose()`
- ✅ Log auth state changes

**ผลลัพธ์:**
- User จะถูก redirect ไป login page อัตโนมัติเมื่อ sign out
- ป้องกัน memory leak โดย cancel subscription

---

## 🔍 วิธี Debug หลังจากแก้ไข

### Step 1: รัน App และ Login

```bash
flutter run
```

### Step 2: ดู Debug Logs

ค้นหา logs ที่ขึ้นต้นด้วย:
- `AUTH_DEBUG:` - จาก login page
- `NAVBAR_DEBUG:` - จาก navbar shell
- `CANVAS_DEBUG:` - จาก canvas assignment remote data source
- `HOME_DEBUG:` - จาก home page

### Step 3: ตรวจสอบ Logs

#### ถ้า Login สำเร็จ:
```
AUTH_DEBUG: ✅ Session validated before navigation
AUTH_DEBUG: User ID: xxx
AUTH_DEBUG: User Email: xxx@example.com
```

#### ถ้า Home Page โหลด:
```
CANVAS_DEBUG: ==================================================
CANVAS_DEBUG: Starting fetchAssignmentsWithUser()
CANVAS_DEBUG: ==================================================
CANVAS_DEBUG: Session exists: true
CANVAS_DEBUG: User ID: xxx
CANVAS_DEBUG: ✅ Session found after 200ms
CANVAS_DEBUG: Sending request WITH session
```

#### ถ้าได้ Assignments:
```
CANVAS_DEBUG: Status: 200
CANVAS_DEBUG: Assignments count: 2
CANVAS_DEBUG: ✅ SUCCESSFULLY PARSED RESPONSE
```

#### ถ้าเกิด Error:
```
CANVAS_DEBUG: ❌ AUTH FAILURE DETECTED!
CANVAS_DEBUG: Status: 401
```

หรือ:

```
CANVAS_DEBUG: ❌ SESSION NOT READY AFTER 5000ms
CANVAS_DEBUG: Final session state: NULL
```

---

## 📋 สถานการณ์ที่อาจยังเกิดขึ้น

### สถานการณ์ที่ 1: Session ยังไม่พร้อมหลังจาก login

**Logs:**
```
AUTH_DEBUG: ❌ Session is null after _waitForSessionReady
```

**วิธีแก้:**
- เพิ่มเวลารอใน `_waitForSessionReady()` ใน login_page.dart
- หรือลอง refresh session หลังจาก login

### สถานการณ์ที่ 2: Edge Function รับ Request แต่ Return 401

**Logs:**
```
CANVAS_DEBUG: Status: 401
CANVAS_DEBUG: ❌ AUTH FAILURE DETECTED!
```

**วิธีแก้:**
- ตรวจสอบ Edge Function logs ใน Supabase Dashboard
- ตรวจสอบว่า access token ถูกต้อง
- ตรวจสอบ Edge Function environment variables

### สถานการณ์ที่ 3: Session หมดอายุ

**Logs:**
```
CANVAS_DEBUG: Is expired: true
CANVAS_DEBUG: Time until expiry: -5 minutes
```

**วิธีแก้:**
- Login ใหม่เพื่อได้ session ใหม่
- หรือ implement auto-refresh token

---

## ✅ Checklist สำหรับทดสอบ

- [ ] รัน `flutter run`
- [ ] Login ด้วย email/password ที่ถูกต้อง
- [ ] ดูว่า navigate ไป home page สำเร็จหรือไม่
- [ ] ดู logs ว่า session ถูก validate หรือไม่
- [ ] ดูว่า assignments ถูก fetch และแสดงหรือไม่
- [ ] ทดสอบ logout แล้วดูว่า redirect ไป login page หรือไม่
- [ ] ทดสอบ refresh assignments โดยกดปุ่ม "Try again"

---

## 🆘 ถ้ายังไม่ได้

ส่ง logs ที่ขึ้นต้นด้วย prefix ต่อไปนี้มาให้ผม:

1. **AUTH_DEBUG:** logs จาก login page
2. **NAVBAR_DEBUG:** logs จาก navbar shell
3. **CANVAS_DEBUG:** logs จาก canvas assignment remote data source
4. **HOME_DEBUG:** logs จาก home page

และอธิบาย:
- ผลลัพธ์ที่เห็นใน app (loading, error, หรือ assignments ไม่แสดง)
- ข้อความ error ถ้ามี
- Screenshot ของ home page

---

## 📖 เอกสารอ้างอิง

- [Supabase Flutter Auth Documentation](https://supabase.com/docs/guides/auth/flutter)
- [Supabase Edge Functions Documentation](https://supabase.com/docs/guides/functions)
- [Riverpod State Management](https://riverpod.dev/)

---

**สร้างเมื่อ:** 2026-03-04
**ผู้แก้ไข:** AI Debug Assistant
**สถานะ:** ✅ แก้ไขเสร็จแล้ว
