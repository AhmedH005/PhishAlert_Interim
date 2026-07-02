# Phish Alert — Interim Prototype

A phishing-awareness training app built in **Flutter**, targeting the **iPhone
simulator**. The user reads a realistic email or SMS, classifies it as **Phish**
or **Legit**, rates their confidence (1–5), and gets immediate feedback with the
suspicious cues highlighted in the message, an explanation, and a takeaway tip.
A short summary closes each session.

> **This is an interim development build — the project is still in progress.**
> It shows real, working progress at the interim stage: the core learning loop
> runs end to end, and the more advanced features are clearly labelled so the
> path to the final feature set is easy to follow. The current focus is the core
> loop, with the remaining features to be built over the next sprints.

## What works so far

- **Welcome screen** with the three planned practice modes (one enabled).
- **Level selection** grouped by difficulty tier (Easy, Medium).
- **Quiz:** message shown with sender/subject/body and channel, level, and
  difficulty tags; Phish/Legit choice; 1–5 confidence rating.
- **One-time hint** per question.
- **Feedback:** correct/incorrect result, your answer vs. the correct label, an
  explanation, the **suspicious cues highlighted in place** within the message
  text (for phishing examples), the cue list, and a takeaway tip.
- **Session summary:** score, accuracy, average confidence, and the raw
  over/under-confidence counts.
- **In-memory session tracking** (score, answers, confidence) — no login, no
  backend, on-device only, which is the right scope for this stage.

## Planned next (not yet built)

- **Random Practice** and **Review Mistakes** modes — shown on the welcome
  screen but disabled with a **"Planned"** label. `SessionTracker` has matching
  `// TODO(next sprint)` placeholder methods.
- **Confidence analytics view** — the summary shows the **raw** over/under
  counts only, with an explicit **"in development"** marker. The full
  visualisation and personalised tips are planned for a later sprint.
- **Difficulty tiers** are present but simple: the dataset currently reaches the
  `medium` tier only (the `hard` tier is defined in the model, ready to fill).
- **Content pack** is a 12-message starter set, with more planned for future
  development (the dataset will be expanded in later sprints).

## Project structure

```
lib/
  models/message_item.dart      # MessageItem + channel/difficulty/classification enums
  data/sample_messages.dart     # the 12-message interim dataset
  services/session_tracker.dart # ChangeNotifier: by-level loop, scoring, metrics
  screens/
    welcome_screen.dart
    level_selection_screen.dart
    quiz_screen.dart
    feedback_screen.dart
    summary_screen.dart
  main.dart
test/widget_test.dart           # core answer-submission + dataset + widget-flow tests
```

## Run

Requires the Flutter SDK on your `PATH` and Xcode with an iOS simulator.

```bash
flutter pub get
open -a Simulator          # boot an iPhone simulator
flutter run                # choose the iOS simulator when prompted
```

## Verify

```bash
flutter analyze
flutter test
```

Both are expected to pass clean. `flutter test` covers the core answer-
submission logic (scoring, over/under-confidence), the dataset shape, and a
widget test that drives the welcome → level → answer → feedback flow.
