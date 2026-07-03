# FAQ

This guide is for developers who are new to Nix, Nix-Darwin, and this specific repository structure.

## Core Concepts

### What are the benefits of this setup?

*   **Declarative:** Your entire system configuration (apps, settings, dotfiles) is defined as code in these files.
*   **Reproducible:** Nix ensures you get the exact same package versions every time. This eliminates "it works on my machine" problems and makes setting up a new machine trivial.
*   **Atomic Upgrades & Rollbacks:** Changes are applied in a single, safe transaction. If something breaks, your system is untouched. You can also instantly roll back to any previous configuration.

### What is a "Flake"?

The `flake.nix` file is the entry point of the configuration. It locks the specific versions of all our dependencies (like `nixpkgs`, `home-manager`, etc.) in the `flake.lock` file. This is the key to ensuring that the configuration is perfectly reproducible, as it guarantees we're always using the exact same software versions.

### How do `imports` work? Do they overwrite settings?

No, they **merge**. This is a key feature of Nix. When you import multiple files that define the same option (like `home.packages`), Nix intelligently combines them.

For example, in our setup:
- `modules/core/packages.nix` defines packages available on all systems (including CI).
- `modules/interactive/packages.nix` defines developer tools for workstations.
- Platform-specific modules can add their own `home.packages` for OS-specific tools.

The final result is a single, combined list containing packages from **both** files. This allows you to neatly separate your configuration into logical parts without worrying about one file overwriting another.

## Daily Workflow

### How do I apply my changes?

After editing any `.nix` file, run the following command in the terminal:

```bash
nix-switch
```

This is an alias that runs the appropriate rebuild command for your system. It will build the new configuration and, if successful, activate it.

### How do I update all my programs?

To update all the dependencies (Nixpkgs, Home Manager, etc.) to their latest versions as defined in `flake.nix`, run:

```bash
nix flake update
```

This will update the `flake.lock` file. To apply these updates to your system, you must then run `nix-switch`.

## Installing Software: The Hierarchy

There are three primary ways to install software in this setup. You should always prefer the highest applicable method on this list.

### 1. Preferred: Home Manager Modules

For programs that have deep integration with Home Manager, this is the best method. It not only installs the program but also declaratively manages its configuration files. `git` is a perfect example.

Instead of adding `git` to a list of packages, we enable a module for it in `modules/core/home-manager.nix`:

```nix
# modules/core/home-manager.nix
programs.git = {
  enable = true;
  userName = fullName;
  userEmail = email;
  # ... other git config
};
```

This Nix code installs `git` and also generates the `~/.gitconfig` file from the settings you provide.

### 2. Good: Nix Packages (via `home.packages`)

For command-line tools or GUI apps available in Nixpkgs that don't have a dedicated Home Manager module, you add them to a `home.packages` list. Thanks to our modular setup, you have two places for this:

#### A. Cross-Platform Packages

For tools you want on **every** machine (macOS, Linux, etc.), add them to the appropriate module:
- `modules/core/packages.nix` - Tools needed everywhere, including CI runners
- `modules/interactive/packages.nix` - Developer tools for workstations only

```nix
# modules/core/packages.nix (available on CI too)
home.packages = with pkgs; [
  kubectl
  helm
];

# modules/interactive/packages.nix (workstations only)
home.packages = with pkgs; [
  ripgrep
  fd
];
```

#### B. Platform-Specific Packages

For tools only needed on one platform, add them to the platform's home-manager module.

**macOS example** - add to `modules/darwin/home-manager.nix`:

```nix
home.packages = with pkgs; [
  mas  # Mac App Store CLI (macOS only)
];
```

**NixOS example** - add to `modules/nixos/home-manager.nix`:

```nix
home.packages = with pkgs; [
  libnotify  # Desktop notifications (Linux only)
];
```

### 3. Last Resort: Homebrew Casks

For GUI applications that are not available in Nixpkgs, you can use Homebrew.

**Warning:** Packages installed via Homebrew are not managed by Nix's reproducible store. They may have their own versioning and automatic updates, which is outside the control of this Nix configuration. Use this method only when necessary.

```nix
# modules/darwin/brew.nix
homebrew.casks = [
  "visual-studio-code" # Add the new cask here
];
```

### How do I manage application settings (e.g., for Zed)?

Declaratively managing your application's configuration is a core feature of Home Manager. This ensures your settings are version-controlled and reproducible. There are two main ways to do this.

#### 1. Preferred: Using a Program's Dedicated Module

Many programs, like Zed, have dedicated options within their Home Manager module. This is the cleanest and most idiomatic method. The module knows exactly how to generate the configuration file in the right format.

For Zed, you can use the `userSettings` option. This takes a set of Nix attributes and automatically converts it into the required `settings.json`.

**Example:** To set your Zed theme and font size, you would edit `modules/interactive/home-manager.nix`:

```nix
# modules/interactive/home-manager.nix

programs.zed-editor = {
  enable = true;
  extensions = [ "nix" "toml" "elixir" ];
  userSettings = {
    theme = "One Dark";
    ui_font_size = 16;
    buffer_font_size = 16;
    "autosave" = "on_focus_change";
  };
};
```

After running `nix-switch`, Home Manager will generate the `~/.config/zed/settings.json` file with this content.

#### 2. Alternative: Linking a Static Config File

For applications that don't have a dedicated Home Manager module or if you have a very complex configuration file you want to manage directly, you can use `home.configFile`. This tells Home Manager to place a file from your Nix configuration into the correct location in your `~/.config` directory.

**Example:** Let's imagine you wanted to manage your Zed settings this way:

1.  **Create the file:** Make a new file, for example, at `modules/interactive/config/zed/settings.json` with your desired JSON content.

2.  **Link it in Nix:** In `modules/interactive/home-manager.nix`, you would write:

    ```nix
    # modules/interactive/home-manager.nix

    home.configFile."zed/settings.json" = {
      source = ./config/zed/settings.json;
    };
    ```

This tells Home Manager to copy your `settings.json` file into `~/.config/zed/settings.json`. While this works, you lose the ability to use Nix variables or logic to generate the file, so the first method is generally preferred when available.

## Project Structure

### Why are there `core`, `interactive`, `darwin`, and `nixos` directories?

This structure separates configuration by scope and platform:

*   `modules/core/`: Headless-safe modules included on **all** systems, including CI runners and servers. Git, neovim, kubectl, and helm live here.
*   `modules/interactive/`: Developer workstation enhancements. Shell customization (zsh, powerlevel10k), editors (Zed), and local dev tools (minikube) live here. **Not included on CI/servers.**
*   `modules/darwin/`: macOS-specific settings. Homebrew configurations (`brew.nix`) and macOS system defaults (`system.nix`) belong here.
*   `modules/nixos/`: NixOS-specific settings. Desktop environment, system services, and NixOS-only features live here.

### Where is Git installed? Where is my `.gitconfig`?

You won't find them in `/usr/bin` or your home directory as plain files.

*   **The Program:** `git` is installed deep inside the read-only `/nix/store`. Home Manager then creates a symbolic link to it in a directory that's added to your `PATH` (like `~/.nix-profile/bin`). This is how you can run `git` from your terminal.
*   **The Config File:** Your `.gitconfig` is also a symlink. Home Manager generates the actual file from your Nix settings and places it in the `/nix/store`, then symlinks it to `~/.gitconfig`. You should never edit this file directly; edit the Nix code instead and run `nix-switch`.
