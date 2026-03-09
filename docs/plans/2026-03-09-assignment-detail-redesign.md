# Assignment Detail Page Redesign

**Date:** 2026-03-09  
**Goal:** Improve UX/UI clarity with better visual hierarchy, enhanced information display, and more accessible actions

## Problem Statement

Current issues with assignment detail page:
1. **ข้อมูลสำคัญไม่เด่นชัด** - Key information hard to see at a glance
2. **ปุ่ม Action ไม่ชัดเจน** - Action buttons (Complete, Edit, Delete) not prominent
3. **Notes Section อ่านยาก** - Notes difficult to read, especially long content
4. **ขาด Visual Hierarchy** - Page lacks clear visual structure

## Design Approach: Card-Based Layout

Chosen approach: **Card-Based Layout with Sections**

**Rationale:**
- Best for visual hierarchy
- Scalable for new content
- Balanced spacing (not too cramped, not too sparse)
- Easy to implement using existing card widgets
- Familiar pattern for users

## Visual Layout Structure

### Section 1: Hero Section (Highest Priority)
**Components:**
- **Title**: 26px, bold (keep existing)
- **Time Remaining Badge** (NEW):
  - > 7 days: "X days left" (green)
  - 1-7 days: "X days left" (yellow)
  - < 24 hours: "X hours left" (red)
  - Overdue: "Overdue by X days" (dark red)
- **Due Date**: Full format display (keep existing)

### Section 2: Quick Stats Row
**Components:**
- **Subject Badge**: Icon + subject name
- **Status Badge**: Current status with color coding
- **Priority Badge** (NEW): High/Medium/Low based on due date + status

### Section 3: Progress Card (NEW)
**Components:**
- **Progress Bar**: 0-100% visualization
- **Progress Text**: "X% Complete" or "Not Started"
- **Logic**: to_do=0%, in_progress=50%, completed=100%

### Section 4: Course Details Card (NEW)
**Components:**
- **Course Name**: Clear subject/course name
- **Additional Info** (if available from Canvas):
  - Instructor name
  - Course code
  - Submission type

### Section 5: Notes & Instructions Card (Enhanced)
**Improvements:**
- Better typography: increased line height, letter spacing
- Better formatting support:
  - Bullet points
  - Bold/italic text (from Canvas HTML)
  - Clearer left accent bar
- **Expand/Collapse** (NEW): Show "Read more/less" for notes > 200 characters

### Section 6: Floating Action Button (NEW)
**Components:**
- **Main FAB**: "+" or "actions" icon
- **Actions** (when tapped - bottom sheet or speed dial):
  - **Complete**: Green button (local assignments only)
  - **Edit**: Blue button (local assignments only)
  - **Delete**: Red button (local assignments only)

## Component Architecture

```
AssignmentsDetailPage
├── AssignmentDetailHeader (existing - keep)
├── SingleChildScrollView
│   ├── AssignmentDetailHeroSection (NEW)
│   │   ├── Title (Text)
│   │   ├── TimeRemainingBadge (NEW widget)
│   │   └── DueDateRow (existing pattern)
│   │
│   ├── AssignmentDetailQuickStatsRow (NEW)
│   │   ├── SubjectBadgeCard (modified StatCard)
│   │   ├── StatusBadgeCard (modified StatCard)
│   │   └── PriorityBadgeCard (NEW)
│   │
│   ├── AssignmentDetailProgressCard (NEW)
│   │   ├── ProgressHeader
│   │   ├── ProgressBar
│   │   └── ProgressText
│   │
│   ├── AssignmentDetailCourseCard (NEW)
│   │   ├── CourseName
│   │   └── AdditionalInfo (optional)
│   │
│   └── AssignmentDetailNotesCard (enhanced)
│       ├── NotesHeader
│       └── ExpandableNotesContent (NEW)
│
└── AssignmentDetailFAB (NEW)
    └── ActionBottomSheet (when tapped)
```

## Data Flow

```
AssignmentsFeedItem (input)
    ↓
AssignmentsDetailPage
    ↓
    ├→ Calculate time remaining
    ├→ Calculate priority (based on due_date + status)
    ├→ Calculate progress percentage (based on status)
    └→ Extract course details (from subject or Canvas data)
```

## New Helper Functions

### 1. `_calculateTimeRemaining(DateTime dueAt)`
**Returns:** `String`  
**Logic:**
- Calculate difference between now and due date
- Format as countdown:
  - If future: "X days left", "X hours left"
  - If past: "Overdue by X days"

### 2. `_calculatePriority(DateTime dueAt, String status)`
**Returns:** `String` ("High", "Medium", "Low")  
**Logic:**
- High: overdue OR due within 2 days
- Medium: due within 7 days
- Low: due after 7 days

### 3. `_calculateProgress(String status)`
**Returns:** `int` (0, 50, or 100)  
**Logic:**
- to_do = 0%
- in_progress = 50%
- completed = 100%

### 4. `_shouldCollapseNotes(String notesText)`
**Returns:** `bool`  
**Logic:**
- Return true if length > 200 characters

## Visual Hierarchy Principles

1. **Font Size & Weight**: Use size/weight to create hierarchy
2. **Spacing**: 24-28px between sections
3. **Background Colors**: White cards on cream background (keep existing colors)
4. **Icons & Colors**: Guide attention with meaningful visual cues

## Color Scheme

**Keep existing color palette:**
- Background: `AppColors.cFFF7F2EE` (cream/beige)
- Cards: `AppColors.surface` (white)
- Border: `AppColors.border`

**New accent colors:**
- Time remaining green: Success green
- Time remaining yellow: Warning yellow
- Time remaining red: Error red
- Priority badges: Use status-based colors

## Scope

**In Scope:**
- Redesign layout with card-based approach
- Add time remaining countdown
- Add priority badges
- Add progress indicator
- Add course details section
- Enhance notes section with expand/collapse
- Replace action buttons with FAB/bottom sheet
- Keep existing color scheme

**Out of Scope:**
- Database schema changes
- API changes
- Canvas integration changes
- Dark mode implementation
- New assignment features (attachments, subtasks, etc.)

## Error Handling

- If time remaining calculation fails, show "Due: [date]" fallback
- If priority calculation fails, show "Normal" badge
- If progress calculation fails, hide progress card
- If notes are empty, show "No notes or instructions" (existing behavior)
- If Canvas data is missing for course details, show subject name only

## Testing Checklist

- [ ] Hero section displays correctly with time remaining
- [ ] Time remaining colors change based on urgency
- [ ] Priority badges show correct values
- [ ] Progress bar displays and animates correctly
- [ ] Course details show when available
- [ ] Notes section expands/collapses correctly
- [ ] FAB appears and opens bottom sheet
- [ ] All actions work for local assignments
- [ ] Actions are hidden/disabled for Canvas assignments
- [ ] Page handles edge cases (empty notes, missing data)
- [ ] Responsive layout works on different screen sizes
- [ ] No performance regressions

## Migration Path

1. Create new widget files alongside existing ones
2. Update `assignments_detail.dart` to use new layout
3. Keep existing widgets as fallback during development
4. Remove old widgets after testing
5. No database or API changes required

## Success Metrics

- Users can quickly identify key information (time remaining, priority)
- Actions are more discoverable and accessible
- Long notes are easier to read
- Page feels more organized and professional
- No decrease in task completion rate
