#!/bin/bash

# Debug Script สำหรับ Home Page Canvas Data Loading Issue
# วิธีใช้: ./debug_home_issue.sh

echo "============================================================"
echo "🔍 Home Page Canvas Data Loading Debug Script"
echo "============================================================"
echo ""

SUPABASE_URL="https://lhtffjttpachjjntvssj.supabase.co"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodGZmanR0cGFjaGpqbnR2c3NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MDE5ODMsImV4cCI6MjA4NjI3Nzk4M30.-8cgoEIRaRJ7_gbwEx5Yuha8MhG2jAr07ovQESY3LUA"

echo "📌 Test 1: Test Edge Function WITHOUT auth (should return 401)"
echo "------------------------------------------------------------"
RESULT1=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "${SUPABASE_URL}/functions/v1/canvas-assignments-proxy" \
  -H "apikey: ${ANON_KEY}")

HTTP_STATUS1=$(echo "$RESULT1" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
BODY1=$(echo "$RESULT1" | sed '/HTTP_STATUS:/d')

echo "HTTP Status: $HTTP_STATUS1"
echo "Response:"
echo "$BODY1" | python3 -m json.tool 2>/dev/null || echo "$BODY1"
echo ""

if [ "$HTTP_STATUS1" -eq 401 ]; then
    echo "✅ Expected: 401 Unauthorized (no auth token)"
else
    echo "⚠️  Unexpected: Expected 401 but got $HTTP_STATUS1"
fi
echo ""

echo "📌 Test 2: Test Edge Function with INVALID Bearer token"
echo "------------------------------------------------------------"
RESULT2=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "${SUPABASE_URL}/functions/v1/canvas-assignments-proxy" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer invalid_token_12345")

HTTP_STATUS2=$(echo "$RESULT2" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
BODY2=$(echo "$RESULT2" | sed '/HTTP_STATUS:/d')

echo "HTTP Status: $HTTP_STATUS2"
echo "Response:"
echo "$BODY2" | python3 -m json.tool 2>/dev/null || echo "$BODY2"
echo ""

if [ "$HTTP_STATUS2" -eq 401 ]; then
    echo "✅ Expected: 401 Unauthorized (invalid token)"
else
    echo "⚠️  Unexpected: Expected 401 but got $HTTP_STATUS2"
fi
echo ""

echo "📌 Test 3: Test Edge Function with ANON KEY as Bearer (your original curl)"
echo "----------------------------------------------------------------------------"
RESULT3=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "${SUPABASE_URL}/functions/v1/canvas-assignments-proxy" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}")

HTTP_STATUS3=$(echo "$RESULT3" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
BODY3=$(echo "$RESULT3" | sed '/HTTP_STATUS:/d')

echo "HTTP Status: $HTTP_STATUS3"
echo "Response:"
echo "$BODY3" | python3 -m json.tool 2>/dev/null || echo "$BODY3"
echo ""

if [ "$HTTP_STATUS3" -eq 200 ]; then
    echo "✅ SUCCESS: Edge Function accepts ANON KEY as Bearer!"
    echo "   This means the Edge Function is not validating the user token properly."
    echo "   It should only work with a valid USER ACCESS TOKEN from login."
else
    echo "✅ Expected: 401 or 500 (invalid user token)"
fi
echo ""

echo "📌 Test 4: Check if we can decode the ANON KEY"
echo "------------------------------------------------------------"
# Decode JWT payload
PAYLOAD=$(echo "${ANON_KEY}" | cut -d. -f2)
if [ -n "$PAYLOAD" ]; then
    # Add padding if needed
    REMAINING=$((4 - ${#PAYLOAD} % 4))
    if [ $REMAINING -lt 4 ]; then
        PAYLOAD="${PAYLOAD}$(printf '=%.0s' $(seq 1 $REMAINING))"
    fi
    DECODED=$(echo "$PAYLOAD" | base64 -d 2>/dev/null)
    echo "ANON KEY JWT Payload:"
    echo "$DECODED" | python3 -m json.tool 2>/dev/null || echo "Failed to decode"
else
    echo "Failed to extract payload from ANON KEY"
fi
echo ""

echo "📌 Test 5: Check Supabase Auth Endpoint"
echo "------------------------------------------------------------"
RESULT5=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "${SUPABASE_URL}/auth/v1/user" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}")

HTTP_STATUS5=$(echo "$RESULT5" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
BODY5=$(echo "$RESULT5" | sed '/HTTP_STATUS:/d')

echo "HTTP Status: $HTTP_STATUS5"
echo "Response:"
echo "$BODY5" | python3 -m json.tool 2>/dev/null || echo "$BODY5"
echo ""

if [ "$HTTP_STATUS5" -eq 401 ]; then
    echo "✅ ANON KEY cannot be used as user token (expected)"
    echo "   This confirms that you need a real USER ACCESS TOKEN from login."
else
    echo "⚠️  Unexpected: ANON KEY seems to work as user token"
fi
echo ""

echo "============================================================"
echo "📊 Summary & Recommendations"
echo "============================================================"
echo ""
echo "🔍 Key Findings:"
echo "1. If Test 3 returns 200 → Edge Function has security issue"
echo "2. If all tests return 401 → Edge Function works correctly"
echo "3. Test 5 should return 401 → ANON KEY is not a user token"
echo ""
echo "🎯 Most Likely Issue:"
echo "   Your Flutter app is not sending a VALID USER ACCESS TOKEN"
echo "   when calling the Edge Function."
echo ""
echo "📋 Steps to Fix:"
echo "   1. Apply the debug version of canvas_assignment_remote_data_source.dart"
echo "   2. Run the Flutter app and check the CANVAS_DEBUG logs"
echo "   3. Verify that session.accessToken contains a real user token"
echo "   4. Check if the session is being properly propagated after login"
echo ""
echo "============================================================"
