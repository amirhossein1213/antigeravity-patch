# Google Antigravity Proxy & Geo-Restriction Patch 🚀

> **Comprehensive, 1-Click Solution to bypass Google Antigravity authentication blocks, HTTP 403 Forbidden errors, and regional sanctions (Iran, corporate firewalls, restricted networks).**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.9--smart-green.svg)](CHANGELOG.md)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-lightgrey.svg)](#requirements)
[![GitHub Repo](https://img.shields.io/badge/GitHub-amirhossein1213%2Fantigeravity--patch-blue?logo=github)](https://github.com/amirhossein1213/antigeravity-patch)

**English** | [فارسی](README-FA.md) | **[📖 Interactive Visual Web Guide (guide.html)](guide.html)**

---

## Table of Contents

- [Overview & The Problem](#overview--the-problem)
- [How It Works (4-Layer Proxy Tunneling)](#how-it-works-4-layer-proxy-tunneling)
- [Key Features in v1.9 Smart](#key-features-in-v19-smart)
- [Quick Start (1-Click Install)](#quick-start-1-click-install)
  - [Option A: 1-Click Batch Installer (Recommended)](#option-a-1-click-batch-installer-recommended)
  - [Option B: Native Windows GUI Window (No Terminal)](#option-b-native-windows-gui-window-no-terminal)
  - [Option C: Visual HTML Guide in Browser](#option-c-visual-html-guide-in-browser)
- [Supported Proxy Tools & Auto-Detected Ports](#supported-proxy-tools--auto-detected-ports)
- [Tools & Scripts in This Repository](#tools--scripts-in-this-repository)
- [Signing In to Google (OAuth Workflow)](#signing-in-to-google-oauth-workflow)
- [After Antigravity Updates](#after-antigravity-updates)
- [Uninstallation](#uninstallation)
- [Troubleshooting & FAQ](#troubleshooting--faq)
- [Security & Transparency](#security--transparency)
- [Author & Maintenance](#author--maintenance)
- [License](#license)

---

## Overview & The Problem

[Google Antigravity](https://antigravity.google/) is Google's AI-first code assistant and IDE environment built on the VS Code core. Using Antigravity requires logging into a Google Account and connecting to Google Cloud backend APIs (`*.googleapis.com`, `accounts.google.com`, `cloudcode.googleapis.com`).

**Connection is blocked in restricted regions (such as Iran) and enterprise proxies:**
1. **HTTP 403 Forbidden Geo-Blocking**: Google blocks connections originating from sanctioned IP addresses when authenticating or generating code.
2. **Subprocesses Bypass System Proxy**: Background processes spawned by the IDE (`language_server.exe`, `node.exe`) bypass default Windows network settings unless explicitly hooked, causing:
   ```text
   failed to make code assist backend request
   Authentication failed: unable to reach accounts.google.com
   language_server.exe: connection refused
   ```
3. **OAuth Redirect Failure**: If the proxy/TUN improperly hijacks `127.0.0.1`, browser callbacks from Google Sign-In fail to reach the local IDE callback server.

---

## How It Works (4-Layer Proxy Tunneling)

This patch intercepts and tunnels all Antigravity network traffic across 4 layers simultaneously:

```
┌─────────────────────────────────┐
│       Google Antigravity        │
│  (IDE, Node.js, LanguageServer) │
└────────────────┬────────────────┘
                 │
                 ▼
 ┌───────────────────────────────┐      ┌─────────────────────────────┐
 │  version.dll Hook Injection   │      │ Windows Environment Vars    │
 │  (Winsock & WinHTTP Hooks)    │ ───▶ │   HTTP_PROXY, HTTPS_PROXY   │
 └───────────────┬───────────────┘      └──────────────┬──────────────┘
                 │                                     │
                 ▼                                     ▼
 ┌───────────────────────────────┐      ┌─────────────────────────────┐
 │ Internal VS Code Settings     │      │ Custom Desktop Shortcut     │
 │ (http.proxy, proxySupport)    │ ───▶ │ (--proxy-server flag)       │
 └───────────────┬───────────────┘      └──────────────┬──────────────┘
                 │                                     │
                 └──────────────────┬──────────────────┘
                                    │
                                    ▼
                         ┌────────────────────┐
                         │ Local HTTP Proxy   │ (Clash Verge / v2rayN)
                         │  127.0.0.1:PORT    │
                         └──────────┬─────────┘
                                    │
                                    ▼
                         ┌────────────────────┐
                         │   Google Servers   │ (Google OAuth & Gemini AI)
                         │  (Status: 200 OK)  │
                         └────────────────────┘
```

1. **DLL Proxy Injection**: `version.dll` loads side-by-side with `Antigravity.exe` and `language_server.exe`, intercepting Winsock/WinHTTP connections.
2. **VS Code Settings**: Configures `http.proxy` and `http.proxySupport: override` in user data directories.
3. **System Environment**: Configures user-level `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY=localhost,127.0.0.1`.
4. **Desktop Launchers**: Creates shortcuts with explicit `--proxy-server` arguments.

---

## Key Features in v1.9 Smart

* 🔍 **Auto Proxy Port Detection**: Automatically scans active local proxy ports (`7897`, `7890`, `10809`, `2080`, etc.) and tests real HTTP reachability to Google before applying.
* 📦 **Dual Edition Support**: Detects and patches both **Google Antigravity IDE** and **Google Antigravity 2.x**.
* 🖥️ **Native Windows GUI**: Includes `Iran-Patch-GUI.bat` with a modern Windows Forms UI (100% RTL and Persian font support).
* 🩺 **6-Point Health Check**: Includes `Verify-Connection.bat` to test proxy port, DLL presence, config health, and Google endpoint connectivity.
* 🖥️ **Windows Terminal Compatible**: Automatically launches with `wt.exe` when available for crisp font rendering.
* 📖 **Standalone Visual Web Guide**: Includes `guide.html` with an interactive terminal simulator and FAQs.

---

## Quick Start (1-Click Install)

### Prerequisite:
Ensure your local VPN or proxy client is running (**Clash Verge**, **v2rayN**, **Clash**, **Sing-box**, etc.).

### Option A: 1-Click Batch Installer (Recommended)
1. Double-click **`Install-Iran-Patch.bat`**.
2. The installer automatically detects your active proxy (e.g. port `7897` for Clash Verge or `10809` for v2rayN):
   ```text
   [OK] Active proxy detected: Clash Verge / Mihomo on port 7897
   Use port 7897? (Press Enter to confirm)
   ```
3. Press **Enter**.
4. The patch applies across all editions and creates dedicated shortcuts on your Desktop.

### Option B: Native Windows GUI Window (No Terminal)
If you prefer a clean graphic window:
1. Double-click **`Iran-Patch-GUI.bat`**.
2. Click **⚡ Install & Activate Patch**.
3. A success dialog appears immediately.

### Option C: Visual HTML Guide in Browser
Open **`guide.html`** in any web browser to view the step-by-step interactive walkthrough.

---

## Supported Proxy Tools & Auto-Detected Ports

| Proxy Tool | Default Port | Auto-Detect & Tested |
|:---|:---:|:---:|
| **Clash Verge / Mihomo** | `7897` | Supported (Tested HTTP 200) |
| **Clash for Windows / Meta** | `7890` | Supported (Tested HTTP 200) |
| **v2rayN / Xray Core (HTTP)** | `10809` | Supported (Tested HTTP 200) |
| **Sing-box / NekoBox** | `2080` | Supported (Tested HTTP 200) |
| **Shadowsocks (HTTP)** | `1080` | Supported (Tested HTTP 200) |
| Enterprise / Custom Proxy | Custom | Can enter custom port |

---

## Tools & Scripts in This Repository

* **`Install-Iran-Patch.bat`**: 1-click installer with automatic port detection.
* **`Iran-Patch-GUI.bat`**: Native Windows GUI utility.
* **`Verify-Connection.bat`**: 6-point connectivity and health diagnostic tool.
* **`Uninstall-Iran-Patch.bat`**: Complete clean uninstaller.
* **`guide.html`**: Interactive Persian visual guide with terminal simulator.
* **`Push-To-GitHub.bat`**: 1-click helper to push and sync updates to your GitHub repository.

---

## Signing In to Google (OAuth Workflow)

1. Keep your proxy active.
2. Launch Antigravity from the newly created Desktop shortcut:
   * **`Antigravity IDE (Iran Patch)`** or **`Antigravity 2 (Iran Patch)`**
3. Click the blue **Sign in** button in the lower corner or chat panel.
4. Your default browser opens to the Google Accounts page without 403 Forbidden errors.
5. Authorize your account; Antigravity immediately unlocks full AI chat and autocompletion features.

---

## After Antigravity Updates

When Google pushes an update to Antigravity, binary folders may be overwritten.
Simply double-click **`Install-Iran-Patch.bat`** again to re-apply the patch in 5 seconds.

---

## Uninstallation

To revert all system settings:
* Double-click **`Uninstall-Iran-Patch.bat`** (or click "Uninstall Patch" in the GUI window).
* All injected DLLs, proxy configuration files, environment variables, and shortcuts are cleanly removed.

---

## Author & Maintenance

* **Author & Maintainer**: [amirhossein1213](https://github.com/amirhossein1213)
* **Telegram**: [@amirgard](https://t.me/amirgard)
* **Email**: [amirhoseynerazavi@gmail.com](mailto:amirhoseynerazavi@gmail.com)
* **Repository**: [https://github.com/amirhossein1213/antigeravity-patch](https://github.com/amirhossein1213/antigeravity-patch)

Contributions, pull requests, and bug reports are welcome!

---

## License

This project is licensed under the [MIT License](LICENSE).
