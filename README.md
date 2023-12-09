# Bulk MSI Uninstaller

Uninstall multiple corrupted programs with the script.

Small modification of [MicrosoftProgram Install and Uninstall](https://support.microsoft.com/en-au/topic/fix-problems-that-block-programs-from-being-installed-or-removed-cca7d1b6-65a9-3d98-426b-e9f927e1eb4d)

# Install

1. `git clone https://github.com/sequencerr/bulk-uninstall-msi.git` In your desired directory
2. `cd bulk-uninstall-msi`

# Usage

1. Open terminal with administrator privileges, run `"PowerShell"` shell (Use `Win+S` and search for it).
2. Firstly run `.\list.ps1` (add argument `-a` for unfiltered list)
3. JSON File `.\msiprogs.json` will be created.
4. Modify it and **leave only programs you wish to remove(!)**
5. Then run `cat -Raw .\msiprogs.json | .\remove.ps1`
6. Wait...
