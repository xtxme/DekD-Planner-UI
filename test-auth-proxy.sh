#!/bin/bash

# Test Script สำหรับทดสอบ Supabase Auth + Canvas Assignments Proxy
# วิธีใช้:
# 1. สร้าง user ใน Supabase Dashboard หรือใช้ auth API
# 2. Login ด้วย email/password
# 3. ใช้ access token ที่ได้เพื่อเรียก Edge Function

SUPABASE_URL="https://lhtffjttpachjjntvssj.supabase.co"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodGZmanR0cGFjaGpqbnR2c3NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MDE5ODMsImV4cCI6MjA4NjI3Nzk4M30.-8cgoEIRaRJ7_gbwEx5Yuha8MhG2jAr07ovQESY3LUA"

echo "========================================="
echo "Supabase Auth + Canvas Proxy Test"
echo "========================================="
echo ""

# ตัวเลือกที่ 1: Test โดยไม่ auth (ควรได้ 401)
echo "📌 Test 1: Request without auth (should return 401)"
echo "-------------------------------------------"
curl -s -i "${SUPABASE_URL}/functions/v1/canvas-assignments-proxy" \
  -H "apikey: ${ANON_KEY}" | grep -E "HTTP|{.*}"

echo ""
echo ""

# ตัวเลือกที่ 2: Login และได้ access token
echo "📌 Test 2: Login to get access token"
echo "-------------------------------------------"
read -p "Enter email: " EMAIL
read -sp "Enter password: " PASSWORD
echo ""

LOGIN_RESPONSE=$(curl -s -X POST "${SUPABASE_URL}/auth/v1/token?grant_type=password" \
  -H "apikey: ${ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"${EMAIL}\", \"password\": \"${PASSWORD}\"}")

ACCESS_TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Login failed!"
  echo "Response: $LOGIN_RESPONSE"
  exit 1
fi

echo "✅ Login successful!"
echo "Access token: ${ACCESS_TOKEN:0:50}..."
echo ""

# ตัวเลือกที่ 3: เรียก Edge Function ด้วย access token
echo "📌 Test 3: Call Edge Function with auth token"
echo "-------------------------------------------"
RESPONSE=$(curl -s "${SUPABASE_URL}/functions/v1/canvas-assignments-proxy" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "apikey: ${ANON_KEY}")

echo "Response:"
echo "$RESPONSE" | jq .

echo ""
echo "========================================="
echo "✅ Test completed!"
echo "========================================="
