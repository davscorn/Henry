# MealCart

Plan the week's dinners → get one consolidated, aisle-sorted shopping list → tap to search each item at your store.

SwiftUI, iOS 17+, iPhone. No accounts, no backend, no third-party packages. Everything is stored on-device.

## What's in the MVP

| Tab | What it does |
| --- | --- |
| **Discover** | 15 built-in dinners. Search by meal or ingredient, filter by tag (Quick, Vegetarian, Family…). Tap ⊕ to add to this week, or open a meal for ingredients and steps. |
| **This Week** | Your planned dinners. Adjust servings per meal (amounts on the list scale with it), reorder, swipe to delete, clear the week. |
| **List** | Every ingredient merged across meals: `garlic` from 4 meals becomes one line, `1 cup + ½ cup` cheddar becomes `1½ cups`, tbsp roll up into cups, oz into lb. Grouped by aisle, shows which meals need each item. Check off as you shop, add extras, swipe **Have it** to move something to your pantry. 🔍 opens a store search for that item. Copy or share the list as text. |
| **Settings** | Preferred store (Aldi via Instacart, Aldi, Walmart, Target, Amazon Fresh), pantry staples kept off the list, feedback notes (your V2 list) with share, reset. |

## Build & run

1. Open `MealCart.xcodeproj` in Xcode 16+.
2. Pick an iPhone simulator, press **⌘R**.
3. Smoke test: Discover shows 15 meals → add 3 → List merges duplicates → 🔍 opens a store search in Safari.

Then follow `MealCart_TestFlight_Checklist` Phase 2 onward (signing team, Archive, upload).

Already set for TestFlight:
- Bundle ID `com.davidsandiego.mealcart` (change it in Signing & Capabilities if it's taken)
- Version 1.0, Build 1
- 1024×1024 app icon (no alpha channel)
- `ITSAppUsesNonExemptEncryption = NO`, so you shouldn't get the export-compliance question
- iPhone-only, portrait

CI (`.github/workflows/mealcart-ios.yml`) builds the app with `xcodebuild` on every push that touches `MealCart/`.

## Code map

```
MealCart/
  MealCartApp.swift          app entry
  Models/Meal.swift          Meal, Ingredient, Aisle, PlannedMeal, FeedbackNote
  Models/Units.swift         units, conversions, fraction formatting
  Data/MealLibrary.swift     the 15 meals (edit here to add your own)
  Logic/ListBuilder.swift    consolidation engine
  Logic/StoreSearch.swift    per-store search URLs
  State/AppModel.swift       app state + UserDefaults persistence
  Views/                     one file per screen
```

## Adding a meal

Add a `Meal(...)` to `MealLibrary.all`. Reuse existing ingredient names (`"yellow onion"`, `"garlic"`, `"shredded cheddar"`) so the list can merge them. Set `search:` when the name alone makes a bad store search, e.g. `"boneless skinless chicken breast"`.
