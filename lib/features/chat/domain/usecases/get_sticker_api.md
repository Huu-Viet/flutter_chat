from weasyprint import HTML

# Content for the .md file optimized for GitHub Copilot / GPT-5.3 Codex
md_content = """# Sticker Feature Context for GitHub Copilot

This document provides the technical specifications and implementation logic for the Sticker feature in the Flutter OTT application. Use this context to generate models, services, and UI components.

---

## 1. Domain Entities (Dart Models)

### StickerPackage
- **id** (String): Unique identifier (e.g., `pck_sprite`).
- **name** (String): Display name for the package.
- **thumbnailUrl** (String): Preview icon for the tab bar.
- **isFree** (bool): Whether the package is free or paid.

### StickerItem
- **id** (String): Unique identifier for the individual sticker.
- **url** (String): The full WebP image URL from the CDN.

---

## 2. API Specifications

### [API 1] Get Sticker Packages
- **Purpose**: Fetch all available sticker sets to display in the keyboard tab bar.
- **Endpoint**: `GET /stickers/packages`
- **Response Type**: `List<StickerPackage>`
- **Behavior**: This list should be fetched once and cached in the application state.

### [API 2] Get Stickers in a Package
- **Purpose**: Fetch all individual stickers within a specific package.
- **Endpoint**: `GET /stickers/packages/:packageId/stickers`
- **Path Parameter**: `packageId` (e.g., `pck_sprite`).
- **Query Parameters**:
    - `limit`: default 50.
    - `offset`: default 0.
- **Response Type**: `List<StickerItem>`
- **Behavior**: Results should be cached locally (e.g., in a Map `cache[packageId]`) to prevent repeated API calls when switching tabs.

---
## 3. State Management
- Handle `Loading`, `Error`, and `Success` states for both APIs.
- Use a `Map<String, List<StickerItem>>` to store stickers for each package to ensure instant tab switching after the first load.
