#!/usr/bin/env python3
"""Point every iTerm2 profile's non-ASCII font at Symbols Nerd Font Mono.

Prefer the GUI if iTerm2 is open -- it applies immediately and iTerm2 saves it:

    iTerm2 > Settings > Profiles > Text > "Use a different font for non-ASCII
    text" > Symbols Nerd Font Mono

This script is for doing it unattended. iTerm2 must be COMPLETELY QUIT: it
holds its prefs in memory and writes them back on exit, silently undoing any
change made underneath it. So run it from Terminal.app, not from iTerm2:

    python3 ~/.config/nvim/set-iterm-nerdfont.py

Leaves each profile's "Normal Font" untouched -- only glyphs that font lacks
come from the Nerd Font. Verify afterwards with `:checkhealth config`.
"""
import plistlib
import subprocess
import sys

DOMAIN = "com.googlecode.iterm2"
NON_ASCII_FONT = "SymbolsNFM 14"  # PostScript name of Symbols Nerd Font Mono


def iterm_running() -> bool:
    # `ps` rather than `pgrep -x iTerm2`: pgrep has returned no match while
    # iTerm2 was running, which let the old version of this script write prefs
    # that iTerm2 then overwrote on quit.
    out = subprocess.run(["ps", "-axo", "comm="], capture_output=True, text=True, check=True).stdout
    return any(line.endswith("/iTerm2") or line == "iTerm2" for line in out.splitlines())


if iterm_running():
    sys.exit("iTerm2 is running. Quit it completely (Cmd-Q) and re-run from Terminal.app,\n"
             "or set the font in iTerm2's GUI instead (see the top of this script).")

# Read and write through `defaults` (cfprefsd), never the plist file directly:
# cfprefsd caches prefs and can write its stale copy back over a direct edit.
exported = subprocess.run(["defaults", "export", DOMAIN, "-"], capture_output=True, check=True).stdout
data = plistlib.loads(exported)
profiles = data.get("New Bookmarks", [])
if not profiles:
    sys.exit("No iTerm2 profiles found. Launch iTerm2 once so it creates its prefs, quit it, then re-run.")

for prof in profiles:
    prof["Non Ascii Font"] = NON_ASCII_FONT
    prof["Use Non-ASCII Font"] = True
    print(f"updated profile {prof.get('Name')!r}: "
          f"Normal={prof.get('Normal Font')!r} NonASCII={NON_ASCII_FONT!r}")

subprocess.run(["defaults", "import", DOMAIN, "-"], input=plistlib.dumps(data), check=True)
print("\nDone. Launch iTerm2, then run :checkhealth config in nvim to confirm.")
