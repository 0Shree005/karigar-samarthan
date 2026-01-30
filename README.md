# Karigar Samarthan (Flutter App)

A **voice‑first Android Flutter application** designed to help Indian artisans (karigars) easily create, manage, and market product listings with **minimal typing, reduced navigation complexity, and assistive AI guidance**.

This repository contains the **mobile layer** of the Karigar Samarthan system. The marketplace backend and seller dashboards are assumed to exist separately.

---

## 🧭 Project Goals

* Reduce literacy and typing requirements
* Enable voice‑first interaction flows
* Minimize navigation depth
* Provide guided, step‑by‑step product listing
* Serve as a scalable foundation for future AI‑assisted features

---

## 🛠 Tech Stack

* **Flutter** (Dart)
* **Material UI**
* **Provider** (state management)
* **GoRouter** (navigation)

---

## 📁 Project Structure

```text
lib/
 ├── components/        # Reusable UI components (ActionCard, VoiceButton, etc.)
 ├── pages/             # App screens (Home, Language Selection, Add Product Wizard)
 ├── theme.dart         # Centralized theme & colors
 ├── nav.dart           # App routing
 └── main.dart          # App entry point
```

---

## ▶️ Running the App (Local Setup)

### Prerequisites

* Flutter SDK installed
* Android Studio / Android SDK
* An Android emulator or physical device

### Steps

```bash
flutter pub get
flutter analyze
flutter run
```

---

## 👥 Team Collaboration Workflow

We follow a **branch‑based workflow** to keep `main` stable.

### Branches

* `main` → stable, demo‑ready builds only
* `feature/<feature-name>` → new features
* `fix/<issue-name>` → bug fixes

Example:

```bash
git checkout -b feature/voice-product-flow
```

---

## 🧪 Testing Expectations

Before pushing code:

```bash
flutter analyze
flutter test   # when tests exist
```

No code should be merged to `main` if:

* `flutter analyze` shows errors
* The app does not launch

---

## 🤝 Contributing Guidelines

Please read carefully before contributing.

### 1. Do NOT commit generated files

These are already handled by `.gitignore`:

* `build/`
* `.dart_tool/`
* `android/.gradle/`
* `ios/Pods/`

---

### 2. Adding a New Page

1. Create the page in `lib/pages/`
2. Register route in `nav.dart`
3. Keep widgets **small and reusable**
4. Prefer stateless widgets unless state is required

---

### 3. Coding Conventions

* lowerCamelCase for variables & methods
* UpperCamelCase for classes
* One widget per file (where possible)
* Keep UI logic separate from navigation logic

---

### 4. Commit Message Format

Use clear, scoped commits:

```text
feat: add voice‑guided product wizard
fix: resolve navigation crash on home page
refactor: simplify ActionCard layout
```

---

## 🔐 Security Notes

* No API keys or secrets in this repo
* No keystores (`.jks`) committed
* Future secrets must be injected via environment or CI

---

## 📌 Current Status

* Core navigation working
* Home page functional
* Voice‑first components scaffolded
* Additional pages under active development

---

## 📄 License

This project is currently intended for **academic / prototype use**.
Licensing will be finalized before production release.

---

## ✨ Maintainers
* Shree
* Subh
* Heather Herman Kaushik - project lead

For questions, raise a GitHub Issue or discuss with the project lead.
