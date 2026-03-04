# 🔍 วิเคราะห์รายละเอียดปัญหา Home Page ไม่แสดงข้อมูล Canvas
**สร้างเมื่อ:** 2026-03-04 19:50
**สถานะ:** ✅ Debug logs พร้อมแล้ว - ต้องรัน app เพื่อดูผลลัพธ์

---

## 📋 สรุปสถานการณ์ (SUMMARY)

### ✅ สิ่งที่ทำงานได้:
1. **Supabase Edge Function ทำงานปกติ** - curl สำเร็จ และได้ HTTP 200 พร้อมข้อมูล assignments
2. **Debug logging ถูก add แล้ว** - มี CANVAS_DEBUG logs ครบถ้วนใน canvas_assignment_remote_data_source.dart
3. **Session validation ถูก add แล้ว** - login_page.dart มีการตรวจสอบ session ก่อน navigate
4. **Loading states ถูก add แล้ว** - home_page.dart มี loading state เมื่อ auth session loading

### ❌ สิ่งที่อาจเป็นปัญหา:
1. **Supabase Flutter SDK อาจไม่ส่ง Authorization header ในบางกรณี**
2. **Session อาจยังไม่พร้อม หรือไม่ valid**
3. **Edge Function ต้องการ Bearer token ที่ถูกต้อง**

---

## 🔍 รายละเอียดการตรวจสอบ (DETAILED INVESTIGATION)

### 1. Supabase Edge Function Analysis

**ไฟล์:** `supabase/functions/canvas-assignments-proxy/index.ts`

**Logic ที่สำคัญ:**

#### ✅ Authorization Header Validation (บรรทัด 52-62)
```typescript
const authHeader = req.headers.get('authorization');

if (!authHeader || !authHeader.startsWith('Bearer ')) {
  return new Response(
    JSON.stringify({ error: "Missing or invalid authorization header" }),
    { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
  );
}
```

**วิเคราะห์:**
- Edge Function ตรวจสอบ authorization header อย่างเข้มงวด
- ต้องเป็น format `Authorization: Bearer <token>`
- ถ้าไม่มีหรือไม่ถูกต้องจะ return **401 Unauthorized**

#### ✅ User Authentication (บรรทัด 78-100)
```typescript
const supabase = createClient(
  supabaseUrl,
  supabaseAnonKey,
  {
    global: {
      headers: { Authorization: authHeader }  // ใช้ Authorization header จาก request
    }
  }
);

const { data: { user }, error: authError } = await supabase.auth.getUser();

if (authError || !user) {
  console.error('Auth error:', authError);
  return new Response(
    JSON.stringify({ error: "Invalid or expired token" }),
    { status: 401, ... }
  );
}
```

**วิเคราะห์:**
- Edge Function ใช้ Supabase client เพื่อ validate token
- ถ้า token ไม่ valid จะ return **401 Unauthorized**
- ถ้า token valid จะไปต่อที่ Canvas API

---

### 2. Flutter App Data Flow Analysis

#### Flow ทั้งหมด:
```
Login Success
  ↓
_saveSession() & _waitForSessionReady()
  ↓
Validate session != null
  ↓
Navigate to NavbarShell (HomePage)
  ↓
HomePage build() → ref.watch(homeCanvasAssignmentSectionsProvider)
  ↓
canvasAssignmentsWithUserProvider → fetchAssignmentsWithUser()
  ↓
requireActiveSession() → รอ session 50 รอบ (5000ms)
  ↓
invokeAssignmentsProxy() → _client.functions.invoke('canvas-assignments-proxy')
  ↓
Supabase SDK ส่ง request ไป Edge Function
  ↓
Edge Function ตรวจสอบ Authorization header
  ↓
???
```

---

### 3. Supabase Function Invoke Analysis

**ไฟล์:** `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`

**Method ที่เรียก Edge Function (บรรทัด 232-249):**
```dart
Future<FunctionResponse> invokeAssignmentsProxy() {
  debugPrint('CANVAS_DEBUG: invokeAssignmentsProxy() - calling Supabase Edge Function');

  final session = _client.auth.currentSession;
  if (session != null) {
    debugPrint('CANVAS_DEBUG: Sending request WITH session');
    debugPrint('CANVAS_DEBUG: User ID: ${session.user.id}');
    debugPrint('CANVAS_DEBUG: Access token (first 50 chars): ${session.accessToken.substring(0, 50)}...');
  } else {
    debugPrint('CANVAS_DEBUG: ⚠️  SENDING REQUEST WITHOUT SESSION!');
  }

  return _client.functions.invoke('canvas-assignments-proxy');
}
```

**วิเคราะห์:**
- ✅ มี debug log ที่ดู session state
- ✅ มี log access token preview
- ⚠️ **ใช้ `_client.functions.invoke()` - Supabase SDK จัดการ auth header อัตโนมัติ**

---

## 🚨 ปัญหาที่อาจเกิดขึ้น (POTENTIAL ISSUES)

### สาเหตุที่ 1: Supabase SDK ไม่ส่ง Authorization header

**ลักษณะ:**
- Supabase Flutter SDK อาจไม่ส่ง Authorization header ในการ invoke function
- Edge Function จะได้ `authHeader = null` หรือไม่ขึ้นต้นด้วย `Bearer `
- Edge Function จะ return 401

**เช็คจาก debug logs:**
```
CANVAS_DEBUG: ⚠️  SENDING REQUEST WITHOUT SESSION!
```
**หรือ:**
```
CANVAS_DEBUG: Sending request WITH session
CANVAS_DEBUG: Status: 401
CANVAS_DEBUG: ❌ AUTH FAILURE DETECTED!
```

**Edge Function logs จะแสดง:**
```
Error: Missing or invalid authorization header
```

---

### สาเหตุที่ 2: Session ยังไม่พร้อม

**ลักษณะ:**
- Session อาจใช้เวลาในการ propagate หลังจาก login
- แม้มี `_waitForSessionReady()` แต่อาจยังไม่เพียงพอ
- หรือ session ถูก invalidate ระหว่าง login และ home page load

**เช็คจาก debug logs:**
```
CANVAS_DEBUG: ❌ SESSION NOT READY AFTER 5000ms
CANVAS_DEBUG: Final session state: NULL
```

---

### สาเหตุที่ 3: Token ไม่ valid หรือหมดอายุ

**ลักษณะ:**
- Token อาจหมดอายุ (exp check)
- Token อาจถูก revoke
- Token อาจไม่ถูกสร้างจาก Supabase

**เช็คจาก debug logs:**
```
CANVAS_DEBUG: Is expired: true
CANVAS_DEBUG: ❌ AUTH FAILURE DETECTED!
```

**Edge Function logs จะแสดง:**
```
Auth error: Invalid or expired token
```

---

### สาเหตุที่ 4: Network / CORS Issues

**ลักษณะ:**
- Request ไม่ถึง Edge Function
- CORS บล็อก request
- Firewall หรือ proxy บล็อก

**เช็คจาก debug logs:**
```
CANVAS_DEBUG: ❌ UNEXPECTED ERROR
CANVAS_DEBUG: Error: NetworkException / SocketException
```

---

## 📊 ตารางการวินิจฉัย (DIAGNOSTIC TABLE)

| Log Pattern | ปัญหา | วิธีแก้ |
|-----------|--------|-----------|
| `SENDING REQUEST WITHOUT SESSION` | Session เป็น NULL | เพิ่มเวลาใน _waitForSessionReady() หรือตรวจสอบ login flow |
| `SESSION NOT READY AFTER 5000ms` | Session ไม่พร้อม | เพิ่มรอนานขึ้น หรือใช้ refresh token |
| `Is expired: true` | Token หมดอายุ | Login ใหม่ หรือ implement refresh token |
| `Status: 401` + `AUTH FAILURE` | Edge Function ตรวจสอบ token แล้วพบว่าไม่ valid | ตรวจสอบว่า Supabase SDK ส่ง Authorization header |
| `NetworkException` | Network issue | ตรวจสอบ internet connection, firewall |
| `CANVAS_DEBUG: ✅ SUCCESSFULLY PARSED RESPONSE` | ✅ ทำงานได้! | ปัญหาเสร็จสมบูรณ์ |

---

## 🧪 ขั้นตอนการ Debug (DEBUGGING STEPS)

### Step 1: รัน Flutter App และ Login

```bash
flutter run
```

### Step 2: Login ด้วย email/password

ค้นหา logs ใน terminal:
```
AUTH_DEBUG: ===== LOGIN SESSION =====
AUTH_DEBUG: USER_ID=xxx
AUTH_DEBUG: SESSION_ID=xxx
AUTH_DEBUG: ACCESS_TOKEN=eyJhbGci...
AUTH_DEBUG: ✅ Session validated before navigation
AUTH_DEBUG: User ID: xxx
```

### Step 3: เข้า Home Page

ค้นหา logs ใน terminal:
```
CANVAS_DEBUG: ==================================================
CANVAS_DEBUG: Starting fetchAssignmentsWithUser()
CANVAS_DEBUG: ==================================================
CANVAS_DEBUG: BEFORE requireActiveSession
CANVAS_DEBUG: Session exists: true/false
CANVAS_DEBUG: User ID: xxx
CANVAS_DEBUG: Session ID: xxx
CANVAS_DEBUG: Expires At: xxx
CANVAS_DEBUG: Time until expiry: X minutes
CANVAS_DEBUG: Is expired: true/false
CANVAS_DEBUG: AFTER requireActiveSession
CANVAS_DEBUG: Calling invokeAssignmentsProxy()...
CANVAS_DEBUG: Sending request WITH session / WITHOUT SESSION
CANVAS_DEBUG: Status: 200/401/500
```

---

## 📋 สิ่งที่ต้องตรวจสอบ (CHECKLIST)

### 1. ตรวจสอบ Debug Logs
- [ ] มี `AUTH_DEBUG:` logs จาก login
- [ ] มี `CANVAS_DEBUG:` logs จาก home page
- [ ] Session state เป็น true หรือ false
- [ ] Token ถูก log หรือไม่
- [ ] Response status จาก Edge Function คืออะไร

### 2. ตรวจสอบ Edge Function Logs
- [ ] เข้า Supabase Dashboard → Edge Functions → canvas-assignments-proxy
- [ ] ดู logs ล่าสุด
- [ ] หา error messages
- [ ] ดูว่าได้ request หรือไม่

### 3. ตรวจสอบ Network
- [ ] มี internet connection
- [ ] ไม่มี firewall หรือ proxy บล็อก
- [ ] สามารถเข้า Supabase URL ได้

---

## 🔧 วิธีแก้ปัญหาที่เป็นไปได้ (POTENTIAL FIXES)

### Fix 1: ตรวจสอบว่า Supabase SDK ส่ง Authorization header

**ไฟล์:** `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`

```dart
Future<FunctionResponse> invokeAssignmentsProxy() async {
  debugPrint('CANVAS_DEBUG: invokeAssignmentsProxy() - calling Supabase Edge Function');

  final session = _client.auth.currentSession;

  // ✅ Debug: แสดง session state
  if (session != null) {
    debugPrint('CANVAS_DEBUG: ✅ Session exists');
    debugPrint('CANVAS_DEBUG: User ID: ${session.user.id}');
    debugPrint('CANVAS_DEBUG: Access token length: ${session.accessToken.length}');
    debugPrint('CANVAS_DEBUG: Access token preview: ${session.accessToken.substring(0, 50)}...');
  } else {
    debugPrint('CANVAS_DEBUG: ❌ Session is NULL');
  }

  // ✅ ลอง invoke function
  try {
    final response = await _client.functions.invoke('canvas-assignments-proxy');

    debugPrint('CANVAS_DEBUG: ✅ Function invoked successfully');
    debugPrint('CANVAS_DEBUG: Status: ${response.status}');

    return response;
  } catch (e) {
    debugPrint('CANVAS_DEBUG: ❌ Function invoke failed: $e');
    rethrow;
  }
}
```

---

### Fix 2: ส่ง Authorization header ด้วยตัวเอง (หาก SDK ไม่ส่ง)

**ไฟล์:** `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`

⚠️ **แก้ไข:** Supabase Flutter SDK 2.x จะส่ง Authorization header อัตโนมัติ แต่ถ้าไม่ทำงานสามารถลอง:

```dart
Future<FunctionResponse> invokeAssignmentsProxy() {
  debugPrint('CANVAS_DEBUG: invokeAssignmentsProxy()');

  // ✅ Supabase SDK จะส่ง Authorization header อัตโนมัติ
  // ถ้ายังไม่ทำงาน ลองส่ง headers parameter:
  return _client.functions.invoke(
    'canvas-assignments-proxy',
    headers: {
      // Supabase SDK จะ override อันนี้ แต่ใส่ไว้เผื่อไว้
      'X-Custom-Header': 'test',
    },
  );
}
```

---

### Fix 3: เพิ่มเวลาในการรอ Session

**ไฟล์:** `lib/features/auth/login_page.dart`

แก้ `_waitForSessionReady()`:

```dart
Future<void> _waitForSessionReady() async {
  final client = Supabase.instance.client;
  // ✅ เพิ่มจาก 50 เป็น 100 รอบ (10 วินาที)
  for (var i = 0; i < 100; i++) {
    if (client.auth.currentSession != null) {
      debugPrint('AUTH_DEBUG: session ready after ${i * 100}ms');
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  debugPrint('AUTH_DEBUG: session not ready after 10s, proceeding anyway');
}
```

และใน `canvas_assignment_remote_data_source.dart`:

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
      if (session != null) {
        _logSessionDetails(session);
      }
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

  debugPrint(
    'CANVAS_DEBUG: ❌ SESSION NOT READY AFTER 10000ms',
  );
  throw const CanvasSessionExpiredException();
}
```

---

### Fix 4: ตรวจสอบ Edge Function Environment Variables

**ไปที่:** Supabase Dashboard → Edge Functions → canvas-assignments-proxy → Environment Variables

ตรวจสอบว่ามี:
- [ ] `SUPABASE_URL`
- [ ] `SUPABASE_ANON_KEY`
- [ ] `CANVAS_BASE_URL`
- [ ] `CANVAS_TOKEN`

---

## 📋 ขั้นตอนถัดไป (NEXT STEPS)

### 1️⃣ รัน App และเก็บ Logs
```bash
flutter run > debug_output.log 2>&1
```

Login แล้วกด Enter ไป Home Page

### 2️⃣ ค้นหา Logs ที่สำคัญ
```bash
grep "AUTH_DEBUG:" debug_output.log > auth_logs.txt
grep "CANVAS_DEBUG:" debug_output.log > canvas_logs.txt
```

### 3️⃣ ส่ง Logs มาให้ฉันวิเคราะห์
- auth_logs.txt
- canvas_logs.txt
- Screenshot ของ Home Page (ถ้ามี error)

---

## 🆘 ถ้าต้องการความช่วยเหลือเพิ่มเติม

ส่งข้อมูลต่อไปนี้มา:
1. **Debug logs** ทั้งหมด (AUTH_DEBUG และ CANVAS_DEBUG)
2. **Screenshot** ของ Home Page
3. **Edge Function logs** จาก Supabase Dashboard (ถ้าเข้าได้)
4. **สถานะ:**
   - Login แล้วอยู่ที่ login page?
   - Login สำเร็จแต่ home page ว่างเปล่า?
   - Login สำเร็จแต่ home page แสดง error?
   - Login สำเร็จและ home page แสดง assignments?

---

## 📚 เอกสารอ้างอิง

- [Supabase Flutter Auth](https://supabase.com/docs/guides/auth/flutter)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Supabase Function Invoke](https://supabase.com/docs/reference/dart/invoking-functions)
- [Dart Debugging](https://dart.dev/tools/debugging)

---

**วันที่สร้าง:** 2026-03-04 19:50
**สถานะ:** ✅ Debug analysis complete - Waiting for debug logs from app
