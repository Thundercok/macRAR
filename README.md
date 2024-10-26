# macRAR – Setup Guide

A tiny, native macOS app to create .rar files. Perfect for quick one-click archiving.

---

## Step 1 – Create the Xcode Project

1. Open **Xcode** → File → New → Project
2. Choose **macOS → App**
3. Fill in:
   - Product Name: `macRAR`
   - Interface: `SwiftUI`
   - Language: `Swift`
4. Save it somewhere you like

---

## Step 2 – Replace the default files

Delete the default `ContentView.swift` and `macRARApp.swift` that Xcode created,
then drag in the two `.swift` files from this folder.

---

## Step 3 – Download the `rar` binary (free)

1. Go to: https://www.rarlab.com/rar_add.htm
2. Download **RAR for macOS** (the `.tar.gz` file)
3. Extract it – you'll find a file simply called `rar`
4. In Xcode, drag this `rar` file into your project navigator
5. In the dialog that appears:
   - ✅ Check "Copy items if needed"
   - ✅ Check "Add to target: macRAR"
6. Select the `rar` file in the project navigator → in the right panel
   under **Identity and Type**, confirm Target Membership is ticked

---

## Step 4 – Add the file to Bundle Resources

1. Click your project in the navigator (blue icon at top)
2. Select the **macRAR** target → **Build Phases**
3. Expand **Copy Bundle Resources**
4. Click **+** and add the `rar` file if it's not already there

---

## Step 5 – Fix permissions on the binary

The `rar` binary needs to be executable. Add a **Run Script** build phase:

1. In **Build Phases**, click **+** → New Run Script Phase
2. Paste this script:

```bash
chmod +x "$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/MacOS/rar"
```

Drag this phase to run **before** "Copy Bundle Resources".

---

## Step 6 – Disable App Sandbox (optional for local use)

Since this app runs a bundled binary, the sandbox can block it.
For personal use (not App Store):

1. Open `macRAR.entitlements`
2. Set `App Sandbox` → `NO`

---

## Step 7 – Build and Run

Press **Cmd+R** in Xcode. The app window will appear.

---

## How to use it

1. Drag any files or folders into the drop zone
2. Type a name for the archive (default: `archive`)
3. Click **Create RAR**
4. The `.rar` file appears on the **Desktop** automatically 🎉

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "rar binary not found" | Make sure `rar` is in Copy Bundle Resources (Step 4) |
| "Permission denied" | Check the Run Script phase (Step 5) |
| App won't open | Right-click → Open to bypass Gatekeeper the first time |

---

## To share with your girlfriend

After building in Xcode:
- Go to **Product → Archive → Distribute App → Copy App**
- This gives you a `.app` file you can copy to her Mac and run directly
