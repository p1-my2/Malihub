# Malihub — Flutter Frontend (v2)

A rebuilt, expanded version of the Malihub frontend: more screens than the
original wireframes, a distinct visual identity, and the wallet logo wired
in as the actual app icon.

## What's new vs. the original wireframes

**Design system.** A real palette instead of "green + white": forest green
(`#1F8A4C`), a deep forest for depth, a muted gold reserved for milestones
and goals reached, ink-green text instead of flat black, and a brick red
for expenses. One signature visual motif — a circular progress **ring** —
recurs across Budget, Savings, and Analytics so "Hub" reads as an actual
shape, not just a word in the name. See `lib/theme/app_colors.dart` and
`lib/theme/app_text.dart`.

**New screens, beyond the original five:**
- **Splash** — brief branded launch animation
- **Onboarding** — 3-slide first-run intro with custom-drawn illustrations
- **Forgot Password** — completes the link that was on the Login screen but didn't go anywhere
- **Profile** — a real settings screen (reached via the Dashboard avatar), replacing a bare logout dialog
- **Notifications** — budget alerts, goal milestones, spending tips (reached via the bell icon)
- **Transaction Detail** — tap any row in History to view/edit/delete
- **Analytics / Insights** — new bottom-nav tab: spending by category (hand-drawn donut chart) and a month-over-month comparison

**Refined screens:** Login, Registration, Dashboard, Transactions, Budget
Planner all carry the new palette, the ring motif, and a shared logo widget.

## App icon

The wallet mark from the Login screen's header badge is now the actual
Android launcher icon — see `android_app_icon/README.md` for exact install
steps into your existing project. Short version: copy the generated PNGs
into your `android/app/src/main/res/mipmap-*/` folders, set one color value,
`flutter clean`, rebuild. Full detail is in that README, including why a
launcher icon needs three PNGs per screen density instead of one (Android's
adaptive icon system) and what LDPlayer does when it caches the old icon.

Since you're on Windows, iOS icon setup isn't included — that needs Xcode
on a Mac. A flat 1024×1024 master PNG is included for whenever that becomes
relevant.

## Running it in VS Code

Same as before:
```
flutter pub get
flutter run
```
No new dependencies were added — the donut chart and rings are hand-drawn
with Flutter's `CustomPainter` rather than an external chart package, so
there's nothing extra to install.

## Project structure

```
lib/
  main.dart                        # Entry point — starts at Splash
  theme/
    app_colors.dart                # Palette
    app_text.dart                  # Type scale, spacing, shadows
    app_theme.dart                 # ThemeData
  widgets/
    malihub_logo.dart              # The brand mark (same design as the app icon)
    ring_progress.dart             # Signature ring — budgets, savings, category breakdown
    donut_chart.dart                # Multi-slice ring for Analytics
    app_text_field.dart
    stat_tile.dart
    malihub_bottom_nav.dart        # Now 4 tabs: Home, Transactions, Insights, Budget
  screens/
    splash_screen.dart
    onboarding_screen.dart
    login_screen.dart
    forgot_password_screen.dart
    registration_screen.dart
    main_shell.dart                 # Bottom-nav container
    dashboard_screen.dart
    transactions_screen.dart
    transaction_detail_screen.dart
    analytics_screen.dart
    budget_planner_screen.dart
    profile_screen.dart
    notifications_screen.dart
android_app_icon/                   # Generated launcher icon PNGs + install steps
```

## Backend integration — what to do when your team's endpoints are ready

Every screen with mock data has a `// TODO` comment naming the exact
endpoint it expects (method, path, request/response shape). Search for
`TODO` across `lib/` to find all of them. A few worth flagging specifically:

- **Category Budgets** (Budget Planner screen) assumes a budget can have
  many category allocations. That's the open design question on
  budget-category cardinality (one category vs. a join table) — the UI
  works either way, but confirm with the backend/database team before
  wiring it up for real.
- **Notifications** tapping doesn't deep-link anywhere yet — whether it
  should depends on the still-open `budget_id`/`goal_id` columns question
  on the notification table.
- **Analytics** expects a category-aggregation endpoint that doesn't exist
  yet in your current API surface (e.g. `GET /api/transactions/summary`) —
  worth raising with your backend dev since it's new, not in the original scope.

When you're ready to wire any of these up, bring me the actual endpoint
shapes your team settles on and we'll replace the mock data together.
