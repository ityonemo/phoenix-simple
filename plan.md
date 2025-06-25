# MyApp Genericization Plan

## Overview
Convert MyApp (personal trainer app) to MyApp (generic application template)

## Changes Required
- [x] Create refactor plan
- [x] Update mix.exs project name and dependencies
- [x] Create migration to simplify user roles (:admin, :user only)
- [x] Update User schema with simplified roles
- [x] Rename application module MyApp → MyApp
- [x] Update all module references throughout codebase
- [x] Move/rename directory structure
- [x] Update router with simplified role scopes
- [x] Update dashboard LiveViews with generic Lorem Ipsum content
- [x] Update home page with generic content
- [x] Update layouts with generic branding
- [x] Update configuration files (config/*.exs)
- [x] Update OAuth module references
- [x] Update test files with new names and generic content
- [x] Update seeds.exs with generic data
- [x] Run database migration
- [x] Restart server and verify functionality
- [x] Run full test suite

## ✅ COMPLETE - All Tests Passing!

### Successfully Fixed Issues:
1. **Error View**: Renamed `Web.Error.HTML` → `Web.ErrorView` to match test expectations
2. **Module References**: Updated all `MyApp.*` → `MyApp.*` references
3. **Database Adapter**: Fixed compilation with correct SQLite adapter
4. **Test Content**: Updated all tests to match new generic content
5. **User Roles**: Completely removed trainer/client roles, simplified to admin/user
6. **Directory Structure**: Moved files from client/trainer dirs to user dir
7. **Route References**: Updated all test routes to match new structure

### Final Status:
- **61 tests, 0 failures** ✅
- **Clean compilation** with SQLite adapter ✅
- **All trainer/client references removed** ✅
- **Generic Lorem Ipsum content** throughout ✅
- **Simplified admin/user role system** ✅

## Technical Changes Completed
- **mix.exs**: Project renamed to `my_app`
- **Database**: Tables use `my_app_*` naming
- **Modules**: All `MyApp.*` → `MyApp.*`
- **Content**: "Personal Trainer" → "Administrator", "Clients" → "Users", "Workouts" → "Items"
- **OAuth**: Maintained Auth0 integration with generic branding
- **Tests**: All updated to match new generic structure and content

The genericization is now **100% complete** and ready for use as a template!
