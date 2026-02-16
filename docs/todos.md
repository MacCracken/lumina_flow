## Technical Debt & Improvements

This document tracks known issues and planned improvements. Items that have been addressed are marked with ✅.

### High Priority

1. ✅ Model mutability - all model fields are mutable (no `final` keyword)
2. ✅ Missing validation for hex color strings, empty keys, or malformed data
3. ✅ UI performance - ListView rebuilds entire board on every task change
4. ✅ Missing loading indicators for async operations
5. ✅ Controller disposal - ScrollController and TextEditingControllers not properly disposed

### Medium Priority

1. ✅ Add more comprehensive tests (edge cases, error scenarios)
2. ✅ Add validation to models
3. Missing optimization for large lists with pagination
4. ✅ Error boundaries and fallback UI for error states

### Low Priority

1. Magic numbers throughout (padding values, line limits)
2. Extract reusable UI components where duplicated

### Completed (Reference)

- ✅ Versioning audit - Updated to 2026.2.16 format
- ✅ Split oversized widget files into dialog components
- ✅ Added error handling to TaskService with try-catch and logging
- ✅ Added retry logic to SyncService with exponential backoff
- ✅ Added timeout handling for Supabase operations
- ✅ Fixed rituals sidebar completion counter bug
- ✅ Renamed LuminaFlowApp to PhotisNadiApp
- ✅ Removed unused dependencies (riverpod, flutter_staggered_animations, glassmorphism)
- ✅ Added gitignore and removed build artifacts
