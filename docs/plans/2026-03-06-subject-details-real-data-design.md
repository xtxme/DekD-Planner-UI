# Subject Details Real Data Design

**Date:** 2026-03-06

## Goal
Replace mocked assignment cards in Subject Details with real assignments for the selected subject, combining local assignments and Canvas assignments.

## Scope
- Keep existing UI layout/style for subject header, tabs, and assignment cards.
- Replace hardcoded `_allAssignments` with provider-driven data.
- Filter by selected subject from Subjects page.
- Show `Upcoming` and `Completed` tabs from real status.

## Data Flow
1. Read selected `SubjectRow` from `SubjectsDetailPage.subject`.
2. Read local assignments from `assignmentListProvider`.
3. Read canvas assignments from `canvasAssignmentsWithUserProvider`.
4. Map both to one view model list.
5. Filter by subject name (case-insensitive), then split tabs:
   - Upcoming: status != completed
   - Completed: status == completed

## Status Mapping
- Local `status` uses values from assignment table (`to_do`, `in_progress`, `late`, `completed`).
- Canvas items default to `in_progress` for upcoming list.

## Empty States
- Keep existing empty card behavior per tab.

## Risks
- Subject matching currently by name; if names diverge, some items can miss.
- Canvas does not provide completed status; all canvas tasks stay in upcoming.

## Validation
- Open Subjects page and tap a subject card.
- Confirm assignment cards reflect real data for that subject only.
- Switch `Upcoming`/`Completed` and confirm counts/contents.
