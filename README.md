# posh-tui

A polished terminal UI for managing Unsloth model profiles with native mouse support.

## Features

- Profile management (create, edit, delete, export)
- Native mouse support via Textual
- Keyboard shortcuts
- Model settings configuration
- One-click Unsloth launch with saved profiles

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/main/install.sh | bash
```

## Usage

```bash
posh-tui
```

## Keyboard Shortcuts

- `q` - Quit
- `n` - New profile
- `e` - Edit profile
- `r` - Run profile
- `d` - Delete profile

## Profiles

Profiles are stored in `~/.unsloth/profiles.json`.

## Agent Handoff Notes

### Current State

- TUI built with Textual (Python)
- Mouse support working
- Profile CRUD operations implemented
- GitHub repo: https://github.com/daveposh/posh-tui
- Install script: `install.sh` (downloads files directly, no git clone)

### Known Issues

1. **pip not found on some systems**: The install script tries to install `textual` via pip, but some systems (like Arch Linux) may not have pip installed by default. The script currently falls back to installing pip via get-pip.py, which may fail on some systems.

2. **GitHub branch confusion**: The repo has both `main` and `master` branches. The default branch is `master`, but the latest code is on `main`. This caused confusion with the install script URL.

### Next Steps

1. **Fix pip installation**: Consider using `pipx` or a virtual environment for installing dependencies. Alternatively, check for `pip3` first and use that if available.

2. **Clean up branches**: Delete the `master` branch and set `main` as the default branch in GitHub settings.

3. **Add more profile settings**: Currently, the TUI supports basic settings. Consider adding support for more Unsloth run options.

4. **Add profile templates**: Provide pre-built profiles for common use cases (e.g., "coding", "chat", "reasoning").

5. **Improve error handling**: Add better error messages when Unsloth fails to start or when profile settings are invalid.

### Testing

Test the install script on different systems:
- Ubuntu/Debian
- Arch Linux
- macOS
- Windows (WSL)

### Dependencies

- Python 3.8+
- Textual (TUI framework)
- Unsloth (for running models)

### File Structure

```
posh-tui/
├── posh_tui.py          # Main TUI application
├── install.sh           # Install script
├── README.md            # This file
├── pyproject.toml       # Python project config
└── .git/                # Git repository
```
