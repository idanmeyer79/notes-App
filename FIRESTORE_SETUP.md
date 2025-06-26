# Firestore Setup Guide

This guide explains how to set up Firebase Firestore for the Notes App.

## Required Indexes

The app requires a composite index for efficient querying of user-specific notes.

### Composite Index for Notes Collection

**Collection**: `notes`  
**Fields to index**:

- `userId` (Ascending)
- `createdAt` (Descending)

### How to Create the Index

#### Method 1: Automatic Creation (Recommended)

1. Click the link provided in the error message when you first run the app
2. This will take you directly to the Firebase Console with the index pre-configured
3. Click "Create Index" to create it

#### Method 2: Manual Creation

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Indexes**
4. Click **Create Index**
5. Configure the index:
   - **Collection ID**: `notes`
   - **Fields**:
     - Field: `userId`, Order: `Ascending`
     - Field: `createdAt`, Order: `Descending`
   - **Query scope**: Collection
6. Click **Create Index**

### Index Creation Time

- **Development mode**: Usually takes a few seconds to minutes
- **Production mode**: Can take up to 10-15 minutes

### Why This Index is Needed

The app queries notes with this pattern:

```dart
.where('userId', isEqualTo: userId)
.orderBy('createdAt', descending: true)
```

Firestore requires a composite index when combining `where` clauses with `orderBy` clauses to ensure efficient querying.

## Firestore Security Rules

Make sure your Firestore security rules allow authenticated users to access their own notes:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## Collection Structure

The `notes` collection will contain documents with this structure:

```json
{
  "id": "auto-generated",
  "title": "Note Title",
  "content": "Note content...",
  "userId": "user-firebase-uid",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "imageUrl": "https://example.com/image.jpg"
}
```

## Troubleshooting

### Index Still Building

If you see "Index is building" errors:

1. Wait a few minutes for the index to finish building
2. Check the Firebase Console → Firestore → Indexes to see the build status
3. The index will be automatically used once it's ready

### Permission Denied

If you see permission errors:

1. Check that your Firestore security rules are properly configured
2. Ensure the user is authenticated
3. Verify the user ID matches the note's userId field

### Query Performance

For better performance with large datasets:

1. Consider adding additional indexes for other query patterns
2. Use pagination for large result sets
3. Consider using `limit()` to restrict the number of results
