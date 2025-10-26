# macRAR

Drop files in. Press a button. Get a .rar on your Desktop. That's it.

---

## Setup (you only do this once, on your Mac)

**Step 1 — Get the `rar` binary via Homebrew**

Open Terminal and run:
```
brew install rar
```

**Step 2 — Copy the binary into the project**

After Homebrew finishes, run this in Terminal to copy the binary here:
```
cp /opt/homebrew/bin/rar /path/to/macRAR/macRAR/rar
```

Replace `/path/to/macRAR` with wherever you unzipped this project.
For example if it's on your Desktop:
```
cp /opt/homebrew/bin/rar ~/Desktop/macRAR/macRAR/rar
```

**Step 3 — Open and build**

Double-click `macRAR.xcodeproj`, then press **Cmd+R**.

The app is now fully self-contained — the `rar` binary is bundled inside.

---

## Giving it to your girlfriend

1. In Xcode: **Product → Archive → Distribute App → Copy App**
2. Send her the `.app` file
3. She drags it to Applications
4. First launch: right-click → Open (just the first time, to pass Gatekeeper)

She never needs Terminal, Homebrew, or anything. It just works. ✅

---

## Requirements
- macOS 13 Ventura or later
- Xcode 15 or later (to build)
- Apple Silicon Mac (M1/M2/M3)
