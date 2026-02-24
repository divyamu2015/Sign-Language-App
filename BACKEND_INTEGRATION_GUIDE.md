# Backend Integration & Reversion Guide

## 🚀 The Simplified Reversion Method (Recommended)
I have created a central toggle to make switching back to your backend as easy as possible.

**File**: `lib/config/dev_config.dart`
**Action**: Change `static const bool useDemoMode = true;` to `false`.

If you do this, I have updated the code to automatically:
1. Show the **Login Page** instead of skipping.
2. Disable hardcoded **Fallback Data**.
3. Use real **User Sessions**.

---

## Manual Reversion (If you prefer cleaning up the code)
If you want to completely remove the demo logic from your codebase, follow these steps:

---

## 1. Re-enable Login
**File**: `lib/screens/introduction_screen.dart`

**What to do**:
- Remove `import 'home_screen.dart';`
- Add `import '../authentication_screen/login_screen/login_view/login_page.dart';`
- Change `_goToLogin()` function:
```dart
void _goToLogin() {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
```

---

## 2. Remove Fallback Data

### Home Screen
**File**: `lib/screens/home_screen.dart`
**Location**: `_fetchCategories()` catch block.
**Action**: Delete the block that sets `_categories = [...]` and keep only `_isLoading = false`.

### Learning Path
**File**: `lib/screens/learning_path_screen.dart`
**Location**: `_fetchLessons()` catch block.
**Action**: Delete the block that sets `_lessons = [...]` and keep only `_isLoading = false`.

### Practice Home
**File**: `lib/screens/pratice_screen/practice_home.dart`
**Location**: `getCategory()` catch block.
**Action**: Delete the fallback `data = [...]` assignment.

### Profile Management
**File**: `lib/screens/profile_manage.dart`
**Location**: `fetchUserProfile()` catch block.
**Action**: Delete the hardcoded assignments for `name`, `email`, etc.

### Quiz Screen
**File**: `lib/screens/quiz_screen/quiz_level.dart`
**Location**: `_loadQuestions()` and `_submitAnswers()`.
**Action**: 
- Remove the `userId = 1;` fallback.
- In `_loadQuestions()` catch block, remove the hardcoded `questions` list.
- In `_submitAnswers()` catch block, remove the `_showResultDialog` mock call and restore `ScaffoldMessenger` error display.

---

## 3. Update API Links
**File**: `lib/uri_links/links.dart`
**Action**: Ensure `baseUri` is pointing to your active backend server or dev tunnel.

---

## 4. Final Checklist
1. [ ] Ensure `SharedPreferences` or your `Bloc` is correctly storing the `user_id` after a real login.
2. [ ] Verify images are loading via `Image.network` using the correct `baseUri`.
3. [ ] Test the full flow: Login -> Home -> Category -> Path -> Quiz.
