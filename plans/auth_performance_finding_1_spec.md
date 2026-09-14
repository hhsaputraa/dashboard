# Temuan 1: Zero-Network Native Login Background Implementation Plan

> **Goal:** Menggantikan pemanggilan gambar online eksternal (`Image.network(unsplash)`) pada layar Login dengan komponen dekorasi lokal geometris murni (*Zero-Network Canvas / Gradient Background*), sehingga 100% offline-ready, bebas network latency, menghemat memori GPU/RAM, dan tidak menyebabkan jank di perangkat low-end.

**Architecture:**
- Ubah `_LoginBackground` di `lib/feature/auth/presentation/login_screen.dart` dari `Image.network` menjadi kombinasi elegan:
  - Clean subtle linear background gradient (`#F8FAFC` -> `#FFFFFF`).
  - Elemen dekoratif geometris aksen perbankan (soft primary red glowing circular ambient blobs di pojok atas & bawah) menggunakan `RepaintBoundary` dan widget bawaan Flutter.
- Keuntungan:
  - **Zero Network Overhead**: Tidak ada request HTTP ke Unsplash.
  - **Zero Image Decode Latency**: Tidak ada waktu parsing bitmap 1080px.
  - **100% Offline Ready**: Tampilan login konsisten sempurna tanpa internet.
- Update tes terkait di `test/widget_test.dart` dan `test/auth/`.

**Tech Stack:** Flutter, Dart 3.13+, Material 3.

## Global Constraints
- Layer Isolation & Flutter AI Developer Experience Standards (`AGENTS.md`, `GEMINI.md`).
- Static Analysis: 0 errors, 0 warnings pada `dart analyze`.
- Test Suite: 100% pass pada `flutter test`.
- Hot reload via DTD MCP.
- Graphify graph update via `graphify update .`.

---

## Tasks

### Task 1: Replace `_LoginBackground` with High-Performance Offline Decorative Background
**Files:**
- Modify: `lib/feature/auth/presentation/login_screen.dart`

**Implementation Details:**
- Hapus URL `https://images.unsplash.com/...` dan `Image.network`.
- Implementasikan `_LoginBackground` menggunakan komposisi warna latar modern, soft radial blur/blobs aksen perbankan, dan isolasi dengan `RepaintBoundary`.

### Task 2: Validate Widget Tests & Performance
**Files:**
- Run: `test/widget_test.dart`
- Run: Full `flutter test`

### Task 3: Quality Gate & Knowledge Graph Update
- Verify with `dart analyze`.
- Update Graphify graph via `graphify update .`.
