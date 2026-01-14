# Note Detail View Design

**Date:** 2026-01-14
**Feature:** Detail page for viewing and managing individual notes

---

## Overview

Add a dedicated detail view for each note that displays full content, allows tag editing, and provides delete functionality. Users navigate by tapping the entire note card.

---

## Requirements

- Tap note card → Navigate to detail view
- Display full content without line limits
- Display all images at larger size
- Edit tags (add/remove) - content and images immutable
- Delete note with confirmation
- Remove delete from timeline swipe actions

---

## Navigation Pattern

**Tap to Navigate**
- Entire NoteCell is tappable via NavigationLink
- Swipe actions (favorite/pin) remain on timeline
- Delete moves to detail view to prevent accidents

**Flow:**
```
TimelineView → NoteCell(tap) → DetailView
                              ↓
                         Delete → Pop back to Timeline
```

---

## DetailView Structure

### 1. Header Section
- Created date in full format
- Pinned/Favorite status indicators (if applicable)
- NavigationBar title: "Note Details"

### 2. Content Section
- Full note text (no line limit)
- All images in larger grid layout
- Each image tappable for full-screen viewing

### 3. Tags Section (editable)
- Tags displayed as removable chips
- Always-visible "×" button on each tag
- "+" button to add new tags
- Tags show color and use count
- Immediate updates (no edit mode toggle)

### 4. Actions Section
- Delete button in toolbar (destructive/red)
- Confirmation alert before deletion

---

## Tag Editing System

**Direct Interaction (No Edit Mode)**

- Tap "×" on tag → Remove from note, decrement useCount
- Tap "+" → Present tag picker or text field
- Select/create tag → Add to note, increment useCount
- Changes save immediately via SwiftData

**State:**
- `@Query private var allTags: [Tag]` for tag picker
- Update note.tags array directly
- Update tag.useCount accordingly

---

## Delete Flow

1. User taps Delete button
2. Alert: "Delete this note? This action cannot be undone."
3. Confirm → Execute delete
4. Cancel → Dismiss alert

**On Delete:**
```swift
// Decrement tag use counts
for tag in note.tags {
    tag.useCount -= 1
}

// Delete image files from disk
for noteImage in note.images {
    ImageManager.deleteImage(at: noteImage.imagePath)
}

// Delete note from SwiftData
modelContext.delete(note)

// Navigate back (automatic)
```

---

## File Changes

### Create: `myNote/Views/NoteDetailView.swift`
- NavigationStack with ScrollView
- Header with date and status
- Full content Text view
- Image grid with tap-to-zoom
- Tag management section
- Delete button with alert
- Image full-screen view (.sheet)

### Modify: `myNote/Views/TimelineView.swift`
- Wrap NoteCell in NavigationLink
- Remove trailing delete swipe action
- Keep leading favorite/pin swipe actions

### Modify: `myNote/Views/NoteCell.swift`
- Remove delete button from action bar
- Keep favorite/pin buttons
- Add NavigationLink wrapper (or let TimelineView handle it)

### Modify: `myNote/Utils/ImageManager.swift`
- Add `static func deleteImage(at path: String) throws`
- Use FileManager.removeItem with error handling
- Handle missing file errors gracefully

---

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| Tap entire card | Natural iOS interaction pattern |
| Tags-only editing | Content/images remain authentic to original thought |
| No edit mode | Simpler interaction, immediate feedback |
| Delete in detail view | Prevents accidental deletions from swipe |
| Alert confirmation | Safety check for destructive action |
| Remove delete from swipe | Cleaner, less error-prone timeline |

---

## Testing Checklist

- [ ] Tapping card navigates to detail view
- [ ] All content displays without truncation
- [ ] Images display at larger size
- [ ] Tapping image shows full-screen view
- [ ] Removing tag updates useCount
- [ ] Adding tag updates useCount
- [ ] Delete shows confirmation alert
- [ ] Delete removes note and images
- [ ] Delete returns to timeline
- [ ] Swipe actions still work on timeline
- [ ] No delete button in timeline swipe actions
