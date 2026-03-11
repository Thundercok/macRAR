# macRAR

**A lightweight, native macOS app for creating .rar archives.**  
Drop files in. Name your archive. Done.

---

## Overview

macRAR is a single-window macOS application built with SwiftUI that wraps the RAR CLI tool in a clean, minimal interface. It's designed for anyone who needs to produce `.rar` files on a Mac without touching the Terminal.

**Platform:** macOS 13 Ventura or later  
**Architecture:** Apple Silicon (arm64)  
**Version:** 1.0  
**Author:** Nigasaka Azumanga

---

## Requirements

| Tool | Purpose | Required |
|------|---------|---------|
| Xcode 15+ | Build the app | Yes |
| RAR CLI (`rar`) | Archive engine | Yes |
| Homebrew | Easiest way to install `rar` | Recommended |

---

## Build Instructions

### 1. Install the RAR binary

macRAR bundles the `rar` binary inside the app so end users need nothing installed. You only need it once, on your development machine, to copy it into the project.

```bash
# Install via Homebrew
brew install rar

# Verify it's the Apple Silicon build
file /opt/homebrew/bin/rar
# Expected: Mach-O 64-bit executable arm64

# Copy into the project (adjust path to where you cloned/unzipped this repo)
cp /opt/homebrew/bin/rar /path/to/macRAR/macRAR/rar
```

### 2. Open in Xcode

Double-click `macRAR.xcodeproj` to open the project.

### 3. Set your development team

In Xcode:
1. Select the **macRAR** project in the navigator
2. Select the **macRAR** target → **Signing & Capabilities**
3. Under **Signing**, choose your Apple ID team from the dropdown

### 4. Build and run

Press **⌘R** or click the ▶ Run button.

The app opens immediately — no further configuration needed.

---

## How to Use

1. **Drop** any files or folders onto the drop zone
2. **Name** your archive in the text field (auto-filled from the first dropped item)
3. Click **Create RAR**
4. The `.rar` file appears on your Desktop
5. Click **Reveal in Finder** to jump straight to it

---

## Distributing the App

### Export a distributable .app

1. In Xcode, select **Product → Archive**
2. Click **Distribute App**
3. Choose **Copy App**
4. Save the exported `macRAR.app` somewhere convenient

### Create an installer DMG

A build script is included. After exporting the `.app` to your Desktop:

```bash
# From the project root
chmod +x build-dmg.sh
./build-dmg.sh
```

This produces `macRAR-1.0.dmg` on your Desktop — a compressed, styled installer with a drag-to-Applications layout, ready to share.

### First launch on a new Mac

Since macRAR is not notarized, macOS Gatekeeper will block it on first open. The recipient needs to:

- Right-click the `.app` → **Open** → **Open** in the dialog

This only happens once. After that, it opens normally.

---

## Project Structure

```
macRAR/
├── macRAR.xcodeproj/        Xcode project file
├── macRAR/
│   ├── macRARApp.swift      App entry point, About menu integration
│   ├── ContentView.swift    Main window — drop zone, controls, RAR logic
│   ├── AboutView.swift      About sheet — credits, acknowledgements, legal
│   ├── Assets.xcassets/     App icon (all sizes) + accent colour
│   ├── macRAR.entitlements  App Sandbox disabled (required to spawn rar process)
│   └── rar                  RAR binary (replace placeholder with real binary)
├── build-dmg.sh             DMG packaging script
└── README.md                This file
```

---

## Acknowledgements

macRAR uses the **RAR** archiving engine developed by **Alexander Roshal** and distributed by **RARLAB**. RAR is proprietary software — all rights reserved by RARLAB.  
→ [https://www.rarlab.com](https://www.rarlab.com)

---

## Legal

macRAR is an independent application developed by Nigasaka Azumanga.  
It is not affiliated with, endorsed by, or sponsored by RARLAB or WinRAR GmbH.  
RAR is a registered trademark of RARLAB.

---

## License

© 2025 Nigasaka Azumanga. All rights reserved.

This software is provided for personal use. Redistribution in any form without  
explicit written permission from the author is not permitted.
