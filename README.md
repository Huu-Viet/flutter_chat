# Flutter Chat

A production-ready real-time messaging and calling application built with Flutter, following Clean Architecture principles.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Code Generation](#code-generation)
- [Localization](#localization)

---

## Features

**Messaging**
- One-on-one and group conversations
- Rich message types: text, image, video, audio, file, sticker, contact card, poll
- Message reactions, reply, forward, revoke, delete (for me), pin & jump-to-message
- Typing indicators, seen/delivered read receipts
- Link detection and inline preview

**Calling**
- Voice and video calls (one-on-one and group) powered by LiveKit SFU
- Native incoming call UI via CallKit (iOS) / ConnectionService (Android)
- Picture-in-picture local video, grid layout for group calls
- Ringing/missed/busy state handling with chat message injection

**Social**
- Friend system: send, accept, reject, cancel requests
- Block / unblock users
- Real-time friend request notifications in chat
- Stranger interaction controls (privacy settings)

**Groups**
- Create groups, invite via QR / link
- Member management, role-based permissions
- Group settings: notification mute, posting restrictions, allow-member-messages toggle

**Media**
- Multi-image / video picker and upload
- In-app audio recording and playback
- File download and open (OpenFileX)
- NSFW detection on outgoing images (on-device TFLite model)

**Security & Privacy**
- Keycloak JWT authentication with silent token refresh
- Session revocation via socket event
- Privacy settings: stranger message & call toggle
- Secure SQLite local cache (Drift)

---

## Architecture

The project follows **Clean Architecture** with a strict 3-layer separation:

```
┌────────────────────────────────────────────────────────┐
│                  Presentation Layer                     │
│  Flutter Widgets · BLoC (events/states) · Riverpod UI  │
│  providers · GoRouter navigation                        │
└───────────────────────┬────────────────────────────────┘
                        │  calls use cases
┌───────────────────────▼────────────────────────────────┐
│                   Domain Layer                          │
│  Entities · Use Cases · Repository interfaces           │
│  (pure Dart, zero Flutter / framework imports)          │
└───────────────────────┬────────────────────────────────┘
                        │  implements repositories
┌───────────────────────▼────────────────────────────────┐
│                    Data Layer                           │
│  DTOs · Mappers · Repository impls                      │
│  Remote: REST (Dio) · Socket.IO                         │
│  Local:  Drift SQLite                                   │
└────────────────────────────────────────────────────────┘
```

### State Management

| Scope | Tool | Usage |
|---|---|---|
| Feature business logic | **BLoC** | Chat messages, call lifecycle, outgoing call |
| Cross-feature / global state | **Riverpod** | Auth, friendship status, active calls, theme |
| Dependency injection | Riverpod `Provider` | All use-case and repository providers |

### Real-time Events

A singleton `RealtimeGatewayService` manages two persistent Socket.IO namespaces (`/chat`, `/call`). Incoming events are emitted to a broadcast `Stream<RealtimeGatewayEvent>`. Individual pages/subscribers listen to the stream and dispatch BLoC events or invalidate Riverpod providers.

```
Socket.IO  ──►  RealtimeGatewayService.events (broadcast stream)
                        │
          ┌─────────────┼──────────────┐
          ▼             ▼              ▼
    ChatPage      CallAppEvent    Other subscribers
    (listener)    Subscriber      (typing, notifications…)
```

### Offline-first Local Cache

Drift (type-safe SQLite) stores conversations, messages, pin messages, users, and friendship status. All watch-based use cases return `Stream` from Drift so the UI reacts to local DB changes automatically.

---

## Project Structure

```
lib/
├── app/                        # App bootstrap, router, providers
│   ├── router.dart
│   └── app_providers.dart
│
├── application/                # App-level cross-feature services
│   ├── notification/           # FCM + local notification handling
│   └── realtime/               # Socket event subscribers (call, chat…)
│
├── core/                       # Shared infrastructure
│   ├── database/               # Drift AppDatabase definition
│   ├── network/                # Dio client, RealtimeGatewayService
│   ├── errors/                 # Failure types
│   ├── theme/                  # Material 3 theme
│   └── widgets/                # Shared UI components
│
├── features/                   # Domain-bounded feature modules
│   ├── auth/                   # Keycloak login, token refresh
│   ├── chat/                   # Messaging (conversations + messages)
│   ├── call/                   # Call lifecycle, LiveKit integration
│   ├── friendship/             # Friend requests, block/unblock
│   ├── group_manager/          # Group creation & settings
│   ├── upload_media/           # S3-based media upload
│   └── nsfw_detector/          # On-device NSFW image classification
│
├── presentation/               # Flutter UI layer
│   ├── auth/
│   ├── chat/                   # ChatPage, GroupManagementPage, blocs
│   ├── call/                   # InCallPage, blocs
│   ├── contact/
│   ├── home/
│   └── profile/
│
└── l10n/                       # ARB localization files (vi, en)
```

Each feature module has the sub-structure:

```
features/<name>/
├── data/
│   ├── datasource/             # Remote (API) and local (DAO) data sources
│   ├── dtos/                   # JSON-serializable transfer objects
│   ├── mappers/                # DTO ↔ Entity mappers
│   └── repositories/           # Repository implementations
└── domain/
    ├── entities/               # Pure domain models
    ├── repositories/           # Abstract repository contracts
    └── usecases/               # Single-responsibility use cases
```

---

## Tech Stack

### Core
| Category | Library | Version |
|---|---|---|
| UI Framework | Flutter | SDK ^3.9 |
| Language | Dart | ^3.9 |

### State Management & DI
| Library | Role |
|---|---|
| `flutter_bloc` + `bloc` | Business logic components (BLoC pattern) |
| `flutter_riverpod` + `riverpod` | Global state, DI container |

### Navigation
| Library | Role |
|---|---|
| `go_router` | Declarative routing with deep-link support |
| `app_links` | Deep link / universal link handling |

### Networking
| Library | Role |
|---|---|
| `dio` | HTTP client (interceptors, token refresh) |
| `socket_io_client` | Real-time events over Socket.IO |
| `flutter_dotenv` | Environment variable loader |

### Local Persistence
| Library | Role |
|---|---|
| `drift` + `drift_flutter` | Type-safe SQLite ORM with stream support |
| `shared_preferences` | Key-value storage (settings, tokens) |

### Media
| Library | Role |
|---|---|
| `image_picker` | Camera / gallery picker |
| `file_picker` | Document / file picker |
| `video_player` | In-app video playback |
| `audioplayers` | Audio message playback |
| `record` | In-app audio recording |
| `ffmpeg_kit_flutter_new` | Media transcoding |
| `cached_network_image` | Network image caching |
| `open_filex` | Open downloaded files with native apps |

### Real-time Communication
| Library | Role |
|---|---|
| `livekit_client` | LiveKit SFU — voice & video rooms |
| `flutter_webrtc` | WebRTC bindings |
| `flutter_callkit_incoming` | Native CallKit / ConnectionService UI |

### Firebase
| Library | Role |
|---|---|
| `firebase_messaging` | FCM push notifications |
| `firebase_auth` | Auth utilities |
| `firebase_database` | Real-time DB (supplemental) |
| `cloud_firestore` | Firestore (supplemental) |

### Serialization & Code Generation
| Library | Role |
|---|---|
| `json_annotation` + `json_serializable` | JSON serialization |
| `freezed` + `freezed_annotation` | Immutable union types |
| `drift_dev` | Drift schema & query codegen |
| `build_runner` | Code generation runner |

### Functional Programming
| Library | Role |
|---|---|
| `dartz` | `Either<Failure, T>` result types, functional utilities |

### Other
| Library | Role |
|---|---|
| `equatable` | Value equality for domain entities |
| `emoji_picker_flutter` | Emoji keyboard |
| `mobile_scanner` | QR code scanner |
| `qr_flutter` | QR code generator |
| `nsfw_detector_flutter` | On-device TFLite NSFW image classification |
| `connectivity_plus` | Network connectivity monitoring |
| `permission_handler` | Runtime permission requests |
| `uuid` | UUID generation |
| `crypto` | SHA hashing utilities |
| `flutter_linkify` | Auto-link detection in text |
| `intl` | Internationalization & date formatting |

---

## Prerequisites

- Flutter SDK **≥ 3.9.0**
- Dart SDK **≥ 3.9.0**
- Android Studio / Xcode (for device/emulator)
- A running backend (REST API + Socket.IO + LiveKit SFU)
- Firebase project with `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

---

## Getting Started

```bash
# 1. Clone the repository
git clone <repo-url>
cd flutter_chat

# 2. Copy environment file
cp .env.example .env.local   # then fill in your values

# 3. Install dependencies
flutter pub get

# 4. Run code generation
dart run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run
```

---

## Environment Variables

Create a `.env.local` file at the root (see `.env.example`):

```dotenv
API_BASE_URL=https://api.your-domain.com
WS_BASE_URL=wss://ws.your-domain.com
KEYCLOAK_URL=https://auth.your-domain.com
KEYCLOAK_REALM=your-realm
KEYCLOAK_CLIENT_ID=flutter-app
LIVEKIT_URL=wss://livekit.your-domain.com
```

---

## Code Generation

This project uses `build_runner` for Drift schemas, JSON serialization, and Freezed unions. Re-run after modifying any annotated files:

```bash
# One-shot
dart run build_runner build --delete-conflicting-outputs

# Watch mode (development)
dart run build_runner watch --delete-conflicting-outputs
```

---

## Localization

ARB files are in `lib/l10n/`. The project supports **Vietnamese** (`vi`) and **English** (`en`).

```bash
# Regenerate after editing .arb files
flutter gen-l10n
```

Access strings via the generated `AppLocalizations`:

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.someKey);
```
