#!/usr/bin/env python3
"""posh-tui - Unsloth Model Profile Manager TUI with Mouse Support

A terminal UI for managing model profiles, settings, and launching Unsloth
with saved configurations. Features native mouse support via Textual.

Project: https://github.com/yourusername/posh-tui
"""

import json
import os
import subprocess
import sys
from pathlib import Path

try:
    from textual.app import App, ComposeResult
    from textual.containers import Container, Vertical, Horizontal
    from textual.widgets import (
        Button, Header, Footer, DataTable, Input, Select, 
        Static, Tab, Tabs, TabPane, Checkbox, Label, TextArea
    )
    from textual.binding import Binding
    from textual.events import Click
except ImportError:
    print("Installing textual...")
    subprocess.run([sys.executable, "-m", "pip", "install", "textual", "-q"])
    from textual.app import App, ComposeResult
    from textual.containers import Container, Vertical, Horizontal
    from textual.widgets import (
        Button, Header, Footer, DataTable, Input, Select,
        Static, Tab, Tabs, TabPane, Checkbox, Label, TextArea
    )
    from textual.binding import Binding
    from textual.events import Click

# Profile storage
PROFILES_FILE = Path.home() / ".unsloth" / "profiles.json"

DEFAULT_PROFILE = {
    "name": "default",
    "model": "esatapedico--Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NM-DAU-NVFP4-GGUF",
    "temperature": 0.7,
    "top_p": 0.80,
    "top_k": 20,
    "presence_penalty": 1.5,
    "repetition_penalty": 1.0,
    "context_length": 16384,
    "kv_cache_type": "q8_0",
    "gpu_layers": 999,
    "parallel": 1,
    "flash_attention": True,
    "batch_size": 2048,
    "ubatch_size": 512,
    "reasoning_effort": "medium",
    "port": 8888,
    "description": ""
}


def load_profiles():
    """Load profiles from JSON file."""
    if PROFILES_FILE.exists():
        try:
            with open(PROFILES_FILE, "r") as f:
                return json.load(f)
        except json.JSONDecodeError:
            return {}
    return {}


def save_profiles(profiles):
    """Save profiles to JSON file."""
    PROFILES_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(PROFILES_FILE, "w") as f:
        json.dump(profiles, f, indent=2)


def build_unsloth_command(profile):
    """Build the unsloth run command from profile."""
    cmd = ["unsloth", "run", "--model", profile["model"]]
    cmd.extend(["--temperature", str(profile["temperature"])])
    cmd.extend(["--top-p", str(profile["top_p"])])
    cmd.extend(["--top-k", str(profile["top_k"])])
    cmd.extend(["--presence-penalty", str(profile["presence_penalty"])])
    cmd.extend(["--context-length", str(profile["context_length"])])
    cmd.extend(["--kv-cache-type", profile["kv_cache_type"]])
    cmd.extend(["--ngl", str(profile["gpu_layers"])])
    cmd.extend(["--parallel", str(profile["parallel"])])
    if profile["flash_attention"]:
        cmd.extend(["--flash-attn", "on"])
    cmd.extend(["--batch-size", str(profile["batch_size"])])
    cmd.extend(["--ubatch-size", str(profile["ubatch_size"])])
    cmd.extend(["--reasoning-effort", profile["reasoning_effort"]])
    cmd.extend(["--port", str(profile["port"])])
    cmd.append("--yes")
    return cmd


class ProfileManagerApp(App):
    """Unsloth Profile Manager TUI."""
    
    CSS = """
    Header { color: #00ff00; background: #000000; }
    Footer { color: #00ff00; background: #000000; }
    .profile-name { color: #00aaff; text-style: bold; }
    .status { color: #00ff00; }
    Button { margin: 1 0; }
    """
    
    BINDINGS = [
        Binding("q", "quit", "Quit"),
        Binding("n", "new_profile", "New Profile"),
        Binding("e", "edit_profile", "Edit Profile"),
        Binding("r", "run_profile", "Run Profile"),
        Binding("d", "delete_profile", "Delete Profile"),
    ]
    
    def __init__(self):
        super().__init__()
        self.profiles = load_profiles()
        self.selected_profile = None
    
    def compose(self) -> ComposeResult:
        yield Header()
        
        # Main layout
        with Container():
            # Profile list
            with Vertical():
                yield Static("Profiles:", id="profile-header")
                yield DataTable(id="profiles-table")
            
            # Profile details
            with Vertical():
                yield Static("Profile Details:", id="details-header")
                yield Static("Select a profile to view details", id="details")
            
            # Action buttons
            with Horizontal():
                yield Button("New", id="btn-new")
                yield Button("Edit", id="btn-edit")
                yield Button("Run", id="btn-run")
                yield Button("Delete", id="btn-delete")
                yield Button("Export", id="btn-export")
        
        yield Footer()
    
    def on_mount(self):
        self.refresh_profile_table()
    
    def refresh_profile_table(self):
        """Refresh the profiles table."""
        table = self.query_one("#profiles-table", DataTable)
        table.clear()
        table.add_columns("Name", "Model", "Temp", "Context")
        
        for name, profile in self.profiles.items():
            model_short = profile["model"][:30] + "..." if len(profile["model"]) > 30 else profile["model"]
            table.add_row(name, model_short, str(profile["temperature"]), str(profile["context_length"]))
    
    def on_data_table_row_selected(self, event):
        """Handle profile selection."""
        name = event.row_key
        self.selected_profile = name
        self.show_profile_details(name)
    
    def show_profile_details(self, name):
        """Show details for selected profile."""
        profile = self.profiles[name]
        details = self.query_one("#details", Static)
        
        lines = [f"[bold]{name}[/bold]"]
        for key, value in profile.items():
            if key != "name":
                lines.append(f"{key}: {value}")
        
        # Show API connection info prominently
        api_url = profile.get("api_endpoint", f"http://127.0.0.1:{profile['port']}/v1")
        lines.append("")
        lines.append(f"[bold cyan]API Endpoint:[/bold cyan] {api_url}")
        lines.append(f"[bold cyan]Connection String:[/bold cyan] OPENAI_BASE_URL={api_url}")
        
        details.update("\n".join(lines))
    
    def on_button_pressed(self, event):
        """Handle button clicks."""
        button_id = event.button.id
        
        if button_id == "btn-new":
            self.create_new_profile()
        elif button_id == "btn-edit":
            self.edit_selected_profile()
        elif button_id == "btn-run":
            self.run_selected_profile()
        elif button_id == "btn-delete":
            self.delete_selected_profile()
        elif button_id == "btn-export":
            self.export_selected_profile()
    
    def create_new_profile(self):
        """Create a new profile."""
        name = "coding"
        profile = DEFAULT_PROFILE.copy()
        profile["name"] = name
        self.profiles[name] = profile
        save_profiles(self.profiles)
        self.refresh_profile_table()
        self.notify(f"Profile '{name}' created", severity="info")
    
    def edit_selected_profile(self):
        """Edit selected profile."""
        if not self.selected_profile:
            self.notify("Select a profile first", severity="warning")
            return
        
        profile = self.profiles[self.selected_profile]
        # In a full implementation, this would open an edit dialog
        self.notify(f"Edit {self.selected_profile} (not implemented)", severity="info")
    
    def run_selected_profile(self):
        """Run selected profile."""
        if not self.selected_profile:
            self.notify("Select a profile first", severity="warning")
            return
        
        profile = self.profiles[self.selected_profile]
        cmd = build_unsloth_command(profile)
        
        self.notify(f"Running {self.selected_profile} on port {profile['port']}", severity="info")
        subprocess.Popen(cmd)
    
    def delete_selected_profile(self):
        """Delete selected profile."""
        if not self.selected_profile:
            self.notify("Select a profile first", severity="warning")
            return
        
        del self.profiles[self.selected_profile]
        save_profiles(self.profiles)
        self.selected_profile = None
        self.refresh_profile_table()
        self.notify("Profile deleted", severity="info")
    
    def export_selected_profile(self):
        """Export selected profile to script."""
        if not self.selected_profile:
            self.notify("Select a profile first", severity="warning")
            return
        
        profile = self.profiles[self.selected_profile]
        output_file = f"~/unsloth-{self.selected_profile}.sh"
        cmd = build_unsloth_command(profile)
        
        with open(output_file, "w") as f:
            f.write("#!/bin/bash\n")
            f.write(f"# Unsloth profile: {self.selected_profile}\n\n")
            f.write(" ".join(cmd) + "\n")
        
        os.chmod(output_file, 0o755)
        self.notify(f"Exported to {output_file}", severity="info")

    def action_new_profile(self):
        self.create_new_profile()

    def action_edit_profile(self):
        self.edit_selected_profile()

    def action_run_profile(self):
        self.run_selected_profile()

    def action_delete_profile(self):
        self.delete_selected_profile()


if __name__ == "__main__":
    app = ProfileManagerApp()
    app.run()

