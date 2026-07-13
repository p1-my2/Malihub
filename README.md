# MaliHub — Flutter Frontend

MaliHub is a cross-platform personal finance management application built with Flutter for Android and iOS. The frontend focuses on providing a clean, intuitive user experience through a consistent design system, custom-built visual components, and a complete user journey from onboarding to financial insights.

The application has been designed with scalability in mind, allowing the current mock data to be replaced with live backend services as development progresses.

---

## Design System

MaliHub uses a carefully selected colour palette centred around forest green (`#1F8A4C`), complemented by a darker forest shade for depth, muted gold to highlight achievements and completed savings goals, ink green for primary text, and brick red to indicate expenses.

A circular progress ring forms the application's signature visual element. Rather than being limited to a single screen, it is reused throughout the Budget, Savings, and Analytics modules to provide users with a consistent visual representation of financial progress.

The complete colour palette, typography, and theme definitions can be found in:

* `lib/theme/app_colors.dart`
* `lib/theme/app_text.dart`
* `lib/theme/app_theme.dart`

---

## Features

### User Interface

The application currently includes the following screens:

* Splash Screen
* Onboarding
* Login
* User Registration
* Dashboard
* Transactions
* Transaction Details
* Budget Planner
* Analytics and Insights
* Profile
* Notifications

Each screen has been designed to support a straightforward and intuitive user experience while maintaining a consistent visual style throughout the application.

### Navigation

Navigation is handled through a bottom navigation bar containing four primary sections:

* Home
* Transactions
* Insights
* Budget

Additional screens, including Profile and Notifications, are accessed directly from the Dashboard through the avatar and notification icons.


## Custom Widgets

To maintain consistency and reduce code duplication, several reusable widgets have been developed specifically for MaliHub.

These include:

* `ring_progress.dart` – reusable circular progress indicator used throughout the application.
* `donut_chart.dart` – custom multi-segment doughnut chart built using Flutter's `CustomPainter`.
* `malihub_logo.dart` – shared application logo used across multiple screens.
* `app_text_field.dart` – reusable text input component.
* `stat_tile.dart` – statistic summary cards.
* `malihub_bottom_nav.dart` – bottom navigation component used across the application's main screens.

---

## App Icon

The app icons are found in assests/icon. 
A high-resolution PNG versions for the app icon foreground and app icon(menu) are provided.

---

## Running the Application

Run the application on VS code by pressing F5 while on main.dart. You can select the device to run the app, e.g., chrome, edge, mobile phone (android or ios through usb debugging) or even virtual devices (emulators).
---

## Project Structure

```text
lib/
│
├── main.dart
├── theme/
│   ├── app_colors.dart
│   ├── app_text.dart
│   └── app_theme.dart
│
├── widgets/
│   ├── malihub_logo.dart
│   ├── ring_progress.dart
│   ├── donut_chart.dart
│   ├── app_text_field.dart
│   ├── stat_tile.dart
│   └── malihub_bottom_nav.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── forgot_password_screen.dart
│   ├── registration_screen.dart
│   ├── main_shell.dart
│   ├── dashboard_screen.dart
│   ├── transactions_screen.dart
│   ├── transaction_detail_screen.dart
│   ├── analytics_screen.dart
│   ├── budget_planner_screen.dart
│   ├── profile_screen.dart
│   └── notifications_screen.dart
│
└── app_icon/icon/the png files
```

---

## Backend Integration

The frontend is already inegrated with the Railway hosted Backend Service through the railway provided API. 

Several areas have been identified for discussion during backend integration:

* **Category Budgets** – The current interface assumes that a budget can contain multiple category allocations. The database design should confirm whether this relationship will be implemented as a single category per budget or through a separate join table.

* **Notifications** – Notification items currently display information only. Deep linking to related budgets or savings goals will depend on whether the notification model includes references such as `budget_id` or `goal_id` but this feature isn't fully operational for this MVP it is simply for presentation purposes since the MySQL deployment through railway limits the features.

* **Analytics** – The Analytics screen expects aggregated spending data, such as a category summary endpoint (for example, `GET /api/transactions/summary`). If this endpoint is not currently available, it will need to be added to the backend before live integration can be completed.

Once the API contracts have been finalised, the existing mock data can be replaced with live data retrieved from the backend.

---

## Future Development

Planned improvements to the frontend include:

* Live backend integration
* Improved analytics and reporting
* Push notifications
* Dark mode
* Performance optimisations
* Accessibility improvements
* Additional animations and user interface refinements
* Fully function "forget password" mechanism that sends change password emails to users

As development continues, the application will evolve from a prototype using mock data into a fully functional personal finance management system backed by the MaliHub REST API.
