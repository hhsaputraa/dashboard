# Login Screen Revamp Plan (Anti-AI Slop & High Performance)

## 1. Objectives
- **Modern & Premium Design (Anti-AI Slop)**: Overhaul the generic centered card login layout into a sophisticated split-screen responsive interface (Left: Enterprise Branding & Trust Showcase, Right: Clean Form Panel).
- **Lightweight & High Performance**: Zero heavy blurs (`BackdropFilter`) or continuous repaints that lag budget devices/web. Use native Flutter painting, hardware-accelerated transforms, desaturated Slate/Zinc backgrounds, and crisp red accenting (`#DC2626`).
- **High Maintainability & Readability**: Break monolithic `LoginScreen` into modular, self-contained widgets inside `lib/auth/presentation/widgets/`. Code must be clean, well-documented, and strictly typed.
- **Interactive UI & Accessibility**: Smooth focus states, password visibility toggle with tactile feedback, clear inline error alerts, server URL configuration modal trigger, and keyboard submission (Enter key).

## 2. Component Structure
```
lib/auth/presentation/
├── login_screen.dart              # Responsive Shell (LayoutBuilder / Split-Screen)
└── widgets/
    ├── login_brand_panel.dart     # Left branding side panel (Desktop/Tablet)
    ├── login_form.dart            # Pure form logic & input widgets
    ├── login_header.dart          # Form header with brand badge & titles
    └── login_server_config_button.dart # Server URL status & setup button
```

## 3. Design Engineering Spec
- **Color Palette**:
  - Background: Neutral Slate `#F8FAFC` & Dark Slate Panel `#0F172A`
  - Accent: Crimson Red `#DC2626` (BPR SUPRA Brand)
  - Text: Dark Charcoal `#0F172A` (Primary), Slate Gray `#64748B` (Secondary)
  - Borders: Crisp Neutral `#E2E8F0` / Focused `#DC2626`
- **Typography & Spacing**:
  - Left-aligned title with `FontWeight.w700` and tight letter spacing (`-0.5`).
  - Label above input fields with subtle uppercase caption style.
  - Tactile buttons with subtle press scale & hover feedback.

## 4. Verification Plan
- Static Analysis: Run `dart analyze` to ensure 0 errors & 0 warnings.
- Unit & Widget Tests: Run `flutter test` to ensure existing and new login widget tests pass.
- Verification of responsiveness & layout across desktop/tablet/mobile form factors.
