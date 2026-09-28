# 🎙️ VocalLens — Flutter Text & Image to Voice AI Studio

[![Flutter](https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.4-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-blue)](https://flutter.dev/multi-platform)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/Repository-GitHub-black?logo=github)](https://github.com/mibrahimmustafa/Flutter_text_image_to_voice)

**VocalLens** is a modern, high-performance, cross-platform Flutter application that transforms images (via OCR) and raw text into natural, expressive speech. Built with an acoustic engine featuring distinct **male and female personas**, full bilingual support for **English and Arabic (العربية)** with Right-to-Left (RTL) layout, interactive **Speed Scroll control up to 5.0x**, real-time audio visualization, and multi-device OCR fallback.

---

## 🌟 Key Features

### 📸 1. Multi-Source Photo OCR
- **Device Camera & Photo Gallery:** Capture documents, book pages, receipts, or signs on mobile.
- **Desktop & Web File Picker:** Drag-and-drop or browse high-resolution images (`PNG`, `JPG`, `WEBP`).
- **Interactive Preset Demo Carousel:** Pre-configured English and Arabic demo images for one-tap instant testing.
- **Cross-Platform OCR Architecture:**
  - **Android & iOS:** On-device low-latency inference via Google ML Kit Text Recognition.
  - **Web & Desktop:** Cloud OCR REST integration fallback with universal byte abstraction.

### 🗣️ 2. Male & Female Voice Personas
- **Distinct Acoustic Profiles:** Solves the common web speech synthesis issue where all voices sound identical by combining dynamic pitch modulation, calibrated speech rates, voice name/gender pattern matching, and an asynchronous utterance reset cycle.
- **Bilingual Personas:** 7 tuned English personas and 5 dedicated Arabic personas.
- **Device Voice Explorer:** Built-in modal dialog to inspect, search, and preview every native TTS voice installed on the user's operating system (filtered by All, Men, and Women).

### 🌍 3. Full Arabic & English Bilingual Support
- **One-Tap Language Switcher (`[EN | عربي]`):** Seamlessly toggle between English and Arabic UI states.
- **Dynamic RTL / LTR Directionality:** Complete interface layout flipping including padding, cards, and icon alignment for Arabic.
- **Smart Arabic Text Auto-Detection:** Automatically detects Arabic characters (`[\u0600-\u06FF]`) in input text and activates appropriate Arabic synthesis engines.

### ⚡ 4. High-Performance Speed Scroll (0.25x – 5.0x)
- **Ultra-Wide Range:** Speeds from `0.25x` (slow study mode) up to `5.0x` (ultra-fast listening).
- **Horizontal Preset Dial:** Quick-tap pills (`0.25x`, `0.5x`, `0.75x`, `1.0x`, `1.25x`, `1.5x`, `2.0x`, `2.5x`, `3.0x`, `3.5x`, `4.0x`, `5.0x`).
- **95-Step Continuous Slider:** Fine-grained speed tuning with real-time audio rate updates.

### 🌊 5. Dynamic Audio Wave Visualizer & Sticky Player
- **Procedural Audio Waves:** Animated canvas reacting to speech playback states (playing, paused, stopped).
- **Persistent Player Bar:** Floating bottom audio dock providing quick play/pause, voice persona badge, active speed indicator, and tune drawer.

---

## 🎭 Voice Personas Catalog

### 🇬🇧 English Personas
| Persona | Gender | Pitch | Rate | Profile Description |
|:---|:---:|:---:|:---:|:---|
| **Alexander** 👨 | Male | `0.70` | `0.48` | Deep baritone, authoritative narrator |
| **Marcus** 👨 | Male | `0.88` | `0.50` | Warm storyteller, conversational & balanced |
| **Elijah** 👨 | Male | `1.02` | `0.54` | Energetic presenter, clear and articulate |
| **Victoria** 👩 | Female | `1.42` | `0.50` | Warm, elegant, and melodious |
| **Emma** 👩 | Female | `1.58` | `0.52` | Bright, cheerful, and upbeat |
| **Sophia** 👩 | Female | `1.30` | `0.46` | Gentle, soothing, and calm |
| **Titan-9** 🤖 | Neutral | `0.50` | `0.62` | Futuristic cybernetic AI synthesizer |

### 🇸🇦 Arabic Personas (الأصوات العربية)
| Persona | Gender | Pitch | Rate | Profile Description |
|:---|:---:|:---:|:---:|:---|
| **طارق (Tariq)** 👨 | Male | `0.72` | `0.48` | صوت رجالي عميق ووقور، مثالي للأخبار والمقالات |
| **عمر (Omar)** 👨 | Male | `0.90` | `0.50` | راوٍ عربي هادئ وودود |
| **فاطمة (Fatima)** 👩 | Female | `1.38` | `0.50` | صوت نسائي فصيح ودافئ، مخارج حروف واضحة |
| **مريم (Mariam)** 👩 | Female | `1.55` | `0.52` | صوت نسائي نضر ومشرق |
| **المعالج الذكي (Titan AR)** 🤖 | Neutral | `0.50` | `0.60` | معالج ذكاء اصطناعي صوتي مستقبلي |

---

## 🏛️ System Architecture

Detailed architecture specifications are maintained in [`architecture.json`](architecture.json).

```
lib/
├── main.dart                          # App entry point, theme setup, & initialization
├── models/
│   ├── voice_persona.dart             # Acoustic voice definitions (pitch, rate, gender, names)
│   ├── app_strings.dart               # Complete English/Arabic bilingual dictionary
│   ├── preset_demo_photo.dart         # English & Arabic demo cards and OCR texts
│   └── speech_history_item.dart       # Conversion audit records & playback tracking
├── services/
│   ├── tts_service.dart               # TTS Singleton, async voice polling, reset engine
│   ├── ocr_service.dart               # Conditional OCR export dispatcher
│   ├── ocr_service_interface.dart     # Unified OCR interface
│   ├── ocr_service_io.dart            # Native ML Kit OCR implementation (Mobile/Desktop)
│   └── ocr_service_web.dart           # Cloud OCR Space implementation (Web)
├── screens/
│   ├── home_screen.dart               # Main studio scaffold, language toggle, sticky player
│   ├── photo_ocr_tab.dart             # Camera/gallery capture, demo carousel, OCR result card
│   └── text_input_tab.dart            # Rich text editor, quick preset pills, word counter
└── widgets/
    ├── voice_player_bar.dart          # Sticky bottom playback bar with speed pill
    ├── speed_scroll_selector.dart     # 0.25x-5.0x horizontal preset dial & continuous slider
    ├── audio_visualizer.dart          # Real-time procedural voice wave animation
    ├── voice_persona_card.dart        # Voice selector card with male/female badges & preview
    ├── preset_photo_carousel.dart     # Sample images carousel for one-tap OCR testing
    ├── system_voice_browser_dialog.dart # Native OS voice inspector with Men/Women tabs
    ├── voice_control_sliders.dart     # Fine-tuning sliders for Pitch, Rate, and Volume
    └── history_bottom_sheet.dart      # Audit history sheet for replaying past audio
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK:** `^3.47.0` (or higher)
- **Dart SDK:** `^3.13.0`
- An IDE with Flutter plugins ([VS Code](https://code.visualstudio.com/), [Android Studio](https://developer.android.com/studio), or [Antigravity](https://antigravity.google))

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mibrahimmustafa/Flutter_text_image_to_voice.git
   cd Flutter_text_image_to_voice
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify analyzer status:**
   ```bash
   flutter analyze
   ```

4. **Run automated test suite:**
   ```bash
   flutter test
   ```

---

## 📱 Running on Different Platforms

### 🌐 Web (Google Chrome / Edge)
```bash
flutter run -d chrome
```
*Note: Audio synthesis uses the browser's Web Speech API. VocalLens automatically polls for voice availability on startup.*

### 📱 Android
```bash
flutter run -d android
```

### 🍏 iOS (macOS required)
```bash
flutter run -d ios
```

### 💻 Windows Desktop
```bash
flutter run -d windows
```

### 📦 Building for Production
```bash
# Build Web Application
flutter build web --release

# Build Android APK / App Bundle
flutter build apk --release
flutter build appbundle --release

# Build Windows Executable
flutter build windows --release
```

---

## 📦 Key Dependencies

| Package | Version | Purpose |
|:---|:---:|:---|
| [`flutter_tts`](https://pub.dev/packages/flutter_tts) | `^4.2.5` | Native Text-To-Speech engine bridge across all platforms |
| [`image_picker`](https://pub.dev/packages/image_picker) | `^1.2.3` | Mobile camera and photo gallery image selection |
| [`file_picker`](https://pub.dev/packages/file_picker) | `^13.1.0` | Desktop and Web universal file selection |
| [`google_mlkit_text_recognition`](https://pub.dev/packages/google_mlkit_text_recognition) | `^0.17.1` | High-speed on-device ML Kit OCR for mobile |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | `^9.0.0` | Modern typography (Plus Jakarta Sans & Cairo) |
| [`http`](https://pub.dev/packages/http) | `^1.6.0` | Cloud OCR Space REST fallback integration |
| [`path_provider`](https://pub.dev/packages/path_provider) | `^2.1.6` | Native filesystem directory resolution |

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
