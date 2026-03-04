#!/bin/bash

# Test Script สำหรับตรวจสอบการแก้ไขปัญหา Home Page
# วิธีใช้: ./test_fixes.sh

echo "============================================================"
echo "🧪 Test Script: Home Page Canvas Data Loading Fix"
echo "============================================================"
echo ""

SUPABASE_URL="https://lhtffjttpachjjntvssj.supabase.co"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodGZmanR0cGFjaGpqbnR2c3NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MDE5ODMsImV4cCI6MjA4NjI3Nzk4M30.-8cgoEIRaRJ7_gbwEx5Yuha8MhG2jAr07ovQESY3LUA"

echo "📌 Test 1: Check if Edge Function is deployed"
echo "------------------------------------------------------------"
RESULT1=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "${SUPABASE_URL}/functions/v1/canvas-assignments-proxy" \
  -H "apikey: ${ANON_KEY}")

HTTP_STATUS1=$(echo "$RESULT1" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)

echo "HTTP Status: $HTTP_STATUS1"
echo ""

if [ "$HTTP_STATUS1" -eq 404 ]; then
    echo "❌ Edge Function ไม่ถูก deploy!"
    echo "   ต้อง deploy: supabase functions deploy canvas-assignments-proxy"
else
    echo "✅ Edge Function ถูก deploy แล้ว"
fi
echo ""

echo "📌 Test 2: Test Edge Function without auth (should return 401)"
echo "------------------------------------------------------------"
RESULT2=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "${SUPABASE_URL}/functions/v1/canvas-assignments-proxy" \
  -H "apikey: ${ANON_KEY}")

HTTP_STATUS2=$(echo "$RESULT2" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
BODY2=$(echo "$RESULT2" | sed '/HTTP_STATUS:/d')

echo "HTTP Status: $HTTP_STATUS2"
echo "Response:"
echo "$BODY2" | python3 -m json.tool 2>/dev/null || echo "$BODY2"
echo ""

if [ "$HTTP_STATUS2" -eq 401 ]; then
    echo "✅ Expected: 401 Unauthorized (no auth token)"
else
    echo "⚠️  Unexpected: Expected 401 but got $HTTP_STATUS2"
fi
echo ""

echo "📌 Test 3: Check Flutter dependencies"
echo "------------------------------------------------------------"
echo "Checking pubspec.yaml for required dependencies..."
echo ""

if [ -f "pubspec.yaml" ]; then
    if grep -q "supabase_flutter:" pubspec.yaml; then
        echo "✅ supabase_flutter is installed"
    else
        echo "❌ supabase_flutter is NOT installed"
    fi

    if grep -q "flutter_riverpod:" pubspec.yaml; then
        echo "✅ flutter_riverpod is installed"
    else
        echo "❌ flutter_riverpod is NOT installed"
    fi

    if grep -q "intl:" pubspec.yaml; then
        echo "✅ intl is installed"
    else
        echo "❌ intl is NOT installed"
    fi
else
    echo "❌ pubspec.yaml not found"
fi
echo ""

echo "📌 Test 4: Check if modified files exist"
echo "------------------------------------------------------------"
FILES_TO_CHECK=(
    "lib/features/home/data/remote/canvas_assignment_remote_data_source.dart"
    "lib/features/auth/login_page.dart"
    "lib/features/home/home_page.dart"
    "lib/shared/widgets/navbar/navbar_shell.dart"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - NOT FOUND"
    fi
done
echo ""

echo "📌 Test 5: Check for debug logs in modified files"
echo "------------------------------------------------------------"
echo "Checking for CANVAS_DEBUG logs in canvas_assignment_remote_data_source.dart..."
echo ""

if grep -q "CANVAS_DEBUG" "lib/features/home/data/remote/canvas_assignment_remote_data_source.dart"; then
    CANVAS_COUNT=$(grep -c "CANVAS_DEBUG" "lib/features/home/data/remote/canvas_assignment_remote_data_source.dart")
    echo "✅ Found $CANVAS_COUNT CANVAS_DEBUG logs"
else
    echo "❌ No CANVAS_DEBUG logs found"
fi
echo ""

echo "Checking for AUTH_DEBUG logs in login_page.dart..."
echo ""

if grep -q "AUTH_DEBUG" "lib/features/auth/login_page.dart"; then
    AUTH_COUNT=$(grep -c "AUTH_DEBUG" "lib/features/auth/login_page.dart")
    echo "✅ Found $AUTH_COUNT AUTH_DEBUG logs"
else
    echo "❌ No AUTH_DEBUG logs found"
fi
echo ""

echo "Checking for HOME_DEBUG logs in home_page.dart..."
echo ""

if grep -q "HOME_DEBUG" "lib/features/home/home_page.dart"; then
    HOME_COUNT=$(grep -c "HOME_DEBUG" "lib/features/home/home_page.dart")
    echo "✅ Found $HOME_COUNT HOME_DEBUG logs"
else
    echo "❌ No HOME_DEBUG logs found"
fi
echo ""

echo "Checking for NAVBAR_DEBUG logs in navbar_shell.dart..."
echo ""

if grep -q "NAVBAR_DEBUG" "lib/shared/widgets/navbar/navbar_shell.dart"; then
    NAVBAR_COUNT=$(grep -c "NAVBAR_DEBUG" "lib/shared/widgets/navbar/navbar_shell.dart")
    echo "✅ Found $NAVBAR_COUNT NAVBAR_DEBUG logs"
else
    echo "❌ No NAVBAR_DEBUG logs found"
fi
echo ""

echo "📌 Test 6: Run Flutter format check"
echo "------------------------------------------------------------"
echo "Running: dart format ."
dart format . 2>&1 | head -20
echo ""

echo "============================================================"
echo "✅ Test Script Completed"
echo "============================================================"
echo ""
echo "📋 Next Steps:"
echo "1. รัน: flutter run"
echo "2. Login ด้วย email/password ที่ถูกต้อง"
echo "3. ดู debug logs ใน terminal"
echo "4. ตรวจสอบว่า assignments แสดงหรือไม่"
echo "5. ถ้ายังไม่ได้ ส่ง logs มาให้ผม"
echo ""
echo "============================================================"
