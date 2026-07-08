# ReFine

**ReFine** is a modern, privacy-focused, and highly customizable Android Launcher designed to boost your daily productivity. Unlike standard launchers, ReFine combines a minimal layout with a full suite of integrated productivity widgets and tools, helping you stay organized, motivated, and focused without leaving your home screen.

---

## 🚀 Key Features

ReFine integrates all your daily essentials directly into the launcher interface:

*   **Custom Home & Launcher:** Minimalist layout that keeps your most-used apps at your fingertips and minimizes distractions.
*   **App Search & Locker:** Quick, system-wide application search with built-in app locker capabilities to secure sensitive applications.
*   **Integrated Dashboard:** A beautiful summary dashboard displaying your schedule, goals, and daily progress.
*   **Workout Tracker:** Track your routines, sets, reps, and workout consistency over time.
*   **Todo & Tasks:** Add, organize, and check off daily todos and task lists.
*   **Timetable Planner:** Plan and view your daily or weekly classes, meetings, and routines.
*   **Daily Journal:** Jot down quick notes, reflections, or daily logs securely.
*   **Motivation Engine:** Receive daily quotes and customizable motivation triggers to keep you moving forward.
*   **Birthday Tracker:** Keep track of friends' and family members' birthdays directly from your home screen widget.
*   **Onboarding & Personalization:** Sleek onboarding experience to set up your preferences, layout configuration, and widgets easily.

---

## 🛠️ Architecture & Tech Stack

*   **Frontend:** Built with [Flutter](https://flutter.dev/) for high-performance rendering and beautiful animations.
*   **State Management:** State management using clean Flutter providers (`motivation_provider.dart`, `system_settings_provider.dart`, etc.) to keep UI and business logic decoupled.
*   **Local Storage:** Fast and robust object-based local database for collection schemas (workouts, todos, journal entries, widget configurations).
*   **Clean Architecture:** Structured cleanly into feature layers:
    *   `lib/database`: Collection schemas and initialization.
    *   `lib/repositories`: Clean abstraction layer for data fetching and mutation.
    *   `lib/features`: Business logic (providers) and presentation layer (UI) separated by concern.

---

## ⚙️ Getting Started

### Prerequisites

*   Flutter SDK (v3.22.0 or higher recommended)
*   Android SDK & Emulator/Physical Device

### Installation

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/YaswantNattamai/reFine.git
    cd reFine
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run Code Generator (if database schemas change):**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the App:**
    ```bash
    flutter run
    ```

---

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for more details.
