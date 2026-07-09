# Windows Installer — Inno Setup

## Goal
Replace the ZIP archive in the Windows release with a proper EXE installer built by Inno Setup.

## Requirements
- Single `.exe` installer file on the GitHub release (no ZIP)
- Desktop shortcut option (user chooses during install)
- Start Menu entry
- Uninstall via Add/Remove Programs
- Version number from release tag
- CI workflow compiles the installer automatically

## Installer Config
- App name: MathCalcu
- Publisher: Shuash11
- Default install dir: `{pf}\MathCalcu`
- Source: `build\windows\x64\runner\Release\*`
- Output: `MathCalcu-Setup-{version}.exe`
- License page: none (no license file)
- Desktop shortcut: optional (checkbox during install)
- Start Menu folder: MathCalcu

## CI Changes
- Add step to install Inno Setup via Chocolatey (`choco install innosetup`)
- Compile script with `ISCC.exe windows\installer.iss /DVersion={tag}`
- Upload `.exe` to release with `softprops/action-gh-release`
- Remove the `Compress-Archive` step

## Files
- `windows/installer.iss` — Inno Setup script (new)
- `.github/workflows/windows-build.yml` — replace ZIP with installer
