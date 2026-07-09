# Windows Installer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Replace ZIP archive with a proper EXE installer via Inno Setup for the Windows release.

**Architecture:** Inno Setup script compiles the Flutter Windows build output into a single EXE installer. CI workflow installs Inno Setup, runs the compiler, and uploads the EXE to the release.

**Tech Stack:** Inno Setup (`ISCC.exe`), Chocolatey, GitHub Actions

---

### Task 1: Create Inno Setup installer script

**Files:**
- Create: `windows/installer.iss`

- [ ] **Step 1: Create `windows/installer.iss`**

```ini
; MathCalcu Windows Installer
; Inno Setup Script — compile with ISCC.exe

#define MyAppName "MathCalcu"
#define MyAppPublisher "Shuash11"
#define MyAppURL "https://github.com/Shuash11/MathCalcu"
#define MyAppExeName "mathcalcu.exe"

#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
OutputDir=..\build\installer
OutputBaseFilename=MathCalcu-Setup-{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
DisableProgramGroupPage=yes
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent
```

- [ ] **Step 2: Commit**

```bash
git add windows/installer.iss
git commit -m "feat: add Inno Setup installer script for Windows builds"
```

---

### Task 2: Update CI workflow to build installer

**Files:**
- Modify: `.github/workflows/windows-build.yml`

- [ ] **Step 1: Read the current workflow file to confirm structure**

Already done — current workflow builds with `flutter build windows --release`, zips with `Compress-Archive`, uploads to release.

- [ ] **Step 2: Replace the Compress-Archive and Upload steps**

Change the workflow to:
1. Install Inno Setup via Chocolatey
2. Build the Flutter app (unchanged)
3. Compile the installer with `ISCC.exe`
4. Upload the `.exe` instead of `.zip`

```yaml
name: Build Windows Desktop

on:
  release:
    types: [created]
  workflow_dispatch:
    inputs:
      tag:
        description: 'Release tag (e.g. v1.0.2)'
        required: true

jobs:
  build-windows:
    runs-on: windows-latest
    env:
      FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true
    steps:
      - uses: actions/checkout@v4.2.2

      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          flutter-version: '3.41.6'

      - name: Install dependencies
        run: flutter pub get

      - name: Generate launcher icons
        run: dart run flutter_launcher_icons
        continue-on-error: true

      - name: Build Windows Release
        run: flutter build windows --release

      - name: Install Inno Setup
        shell: powershell
        run: choco install innosetup --no-progress --confirm

      - name: Compile Installer
        shell: powershell
        run: |
          $tag = "${{ github.event_name == 'release' && github.event.release.tag_name || github.event.inputs.tag }}"
          $version = $tag -replace '^v', ''
          & "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" windows\installer.iss /DMyAppVersion=$version

      - name: Determine tag
        id: tag
        shell: powershell
        run: |
          if ("${{ github.event_name }}" -eq "release") {
            echo "tag=${{ github.event.release.tag_name }}" >> $env:GITHUB_OUTPUT
          } else {
            echo "tag=${{ github.event.inputs.tag }}" >> $env:GITHUB_OUTPUT
          }

      - name: Upload to GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.tag.outputs.tag }}
          files: build\installer\MathCalcu-Setup-*.exe
          token: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/windows-build.yml
git commit -m "feat: replace ZIP with Inno Setup installer in Windows CI"
```
