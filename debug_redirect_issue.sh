#!/bin/bash

# ================================================================
# 🐛 Debug Script - Home Page Redirect Loop Issue
# ================================================================

echo "=========================================="
echo "🔍 Starting Debug Session"
echo "=========================================="
echo ""
echo "📅 Date: $(date)"
echo "📁 Working Directory: $(pwd)"
echo ""
echo "=========================================="
echo "🚀 Running Flutter App"
echo "=========================================="
echo ""
echo "📋 Please follow these steps:"
echo "1. Wait for app to start"
echo "2. Login with your email/password"
echo "3. Press Enter after seeing Home Page OR being redirected to Login"
echo ""

# Create output directory
mkdir -p debug_logs

# Run flutter and capture logs
echo "📝 Capturing logs to debug_logs/flutter_output.txt..."
flutter run > debug_logs/flutter_output.txt 2>&1 &
FLUTTER_PID=$!

# Wait for user to press Enter
read -p "Press Enter after you see the issue (Home page or Login redirect)... "

echo ""
echo "=========================================="
echo "🛑 Stopping Flutter App"
echo "=========================================="
kill $FLUTTER_PID

echo ""
echo "=========================================="
echo "📋 Analyzing Logs"
echo "=========================================="

# Extract important logs
echo ""
echo "📄 AUTH_DEBUG Logs:"
echo "--------------------------------"
grep "AUTH_DEBUG:" debug_logs/flutter_output.txt || echo "No AUTH_DEBUG logs found"

echo ""
echo "📄 CANVAS_DEBUG Logs:"
echo "--------------------------------"
grep "CANVAS_DEBUG:" debug_logs/flutter_output.txt || echo "No CANVAS_DEBUG logs found"

echo ""
echo "📄 HOME_DEBUG Logs:"
echo "--------------------------------"
grep "HOME_DEBUG:" debug_logs/flutter_output.txt || echo "No HOME_DEBUG logs found"

echo ""
echo "=========================================="
echo "📄 Saving Debug Files"
echo "=========================================="

# Save individual log files
grep "AUTH_DEBUG:" debug_logs/flutter_output.txt > debug_logs/auth_logs.txt 2>/dev/null || echo "" > debug_logs/auth_logs.txt
grep "CANVAS_DEBUG:" debug_logs/flutter_output.txt > debug_logs/canvas_logs.txt 2>/dev/null || echo "" > debug_logs/canvas_logs.txt
grep "HOME_DEBUG:" debug_logs/flutter_output.txt > debug_logs/home_logs.txt 2>/dev/null || echo "" > debug_logs/home_logs.txt

echo "✅ Saved files:"
echo "  - debug_logs/flutter_output.txt (complete log)"
echo "  - debug_logs/auth_logs.txt (auth logs only)"
echo "  - debug_logs/canvas_logs.txt (canvas logs only)"
echo "  - debug_logs/home_logs.txt (home page logs only)"

echo ""
echo "=========================================="
echo "🔍 Key Issues Found"
echo "=========================================="

# Check for specific issues
if grep -q "❌ No session found, redirecting to login" debug_logs/flutter_output.txt; then
    echo "⚠️  ISSUE 1: Session was NULL when Home Page loaded"
fi

if grep -q "❌ SESSION NOT READY" debug_logs/flutter_output.txt; then
    echo "⚠️  ISSUE 2: Session was NOT READY (waited 5s)"
fi

if grep -q "❌ AUTH FAILURE DETECTED" debug_logs/flutter_output.txt; then
    echo "⚠️  ISSUE 3: Canvas Edge Function returned 401 (Authorization failure)"
fi

if grep -q "Is expired: true" debug_logs/flutter_output.txt; then
    echo "⚠️  ISSUE 4: Session token is EXPIRED"
fi

if grep -q "❌ CanvasSessionExpiredException caught" debug_logs/flutter_output.txt; then
    echo "⚠️  ISSUE 5: CanvasSessionExpiredException was thrown"
fi

if grep -q "Status: 401" debug_logs/flutter_output.txt; then
    echo "⚠️  ISSUE 6: Edge Function returned HTTP 401"
fi

if grep -q "Status: 200" debug_logs/flutter_output.txt; then
    echo "✅ SUCCESS: Edge Function returned HTTP 200 (data loaded successfully!)"
fi

echo ""
echo "=========================================="
echo "📋 Summary"
echo "=========================================="
echo ""
echo "📦 Next Steps:"
echo "1. Review the log files in debug_logs/ directory"
echo "2. Share the following files with developer:"
echo "   - debug_logs/home_logs.txt (most important)"
echo "   - debug_logs/canvas_logs.txt"
echo "   - debug_logs/auth_logs.txt"
echo "3. Describe what you saw on screen:"
echo "   - Did you see Home Page?"
echo "   - Did it redirect to Login immediately?"
echo "   - Did it show assignments?"
echo "   - Did it show an error?"
echo ""
echo "=========================================="
echo "✅ Debug Session Complete"
echo "=========================================="
