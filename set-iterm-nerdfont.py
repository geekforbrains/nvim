#!/usr/bin/env python3
"""Point iTerm2's non-ASCII font at Symbols Nerd Font Mono.

Run this with iTerm2 COMPLETELY QUIT (it rewrites its prefs on exit and will
otherwise clobber these changes). Run it from Terminal.app:

    python3 ~/.config/nvim/set-iterm-nerdfont.py

Leaves "Normal Font" (Monaco) untouched -- only the glyphs Monaco cannot
render are taken from the Nerd Font.
"""
import plistlib
import pathlib
import subprocess
import sys

NON_ASCII_FONT = "SymbolsNFM 14"  # PostScript name of Symbols Nerd Font Mono
PLIST = pathlib.Path.home() / "Library/Preferences/com.googlecode.iterm2.plist"

if subprocess.run(["pgrep", "-x", "iTerm2"], capture_output=True).returncode == 0:
    sys.exit("iTerm2 is running. Quit it completely (Cmd-Q), then re-run from Terminal.app.")

data = plistlib.loads(PLIST.read_bytes())
profiles = data.get("New Bookmarks", [])
if not profiles:
    sys.exit("No iTerm2 profiles found.")

for prof in profiles:
    prof["Non Ascii Font"] = NON_ASCII_FONT
    prof["Use Non-ASCII Font"] = True
    print(f"updated profile {prof.get('Name')!r}: "
          f"Normal={prof.get('Normal Font')!r} NonASCII={NON_ASCII_FONT!r}")

PLIST.write_bytes(plistlib.dumps(data))
subprocess.run(["defaults", "read", "com.googlecode.iterm2", "Non Ascii Font"],
               capture_output=True)
print("\nDone. Relaunch iTerm2.")
