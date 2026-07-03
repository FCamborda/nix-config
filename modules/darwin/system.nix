{ ... }:

{
  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.sound.beep.volume" = 0.0;
      "com.apple.sound.beep.feedback" = 0;
    };

    dock = {
      autohide = true;
      show-recents = false;
      launchanim = true;
      orientation = "bottom";
      tilesize = 48;
    };

    finder = {
      _FXShowPosixPathInTitle = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = false;
    };

    # Disable macOS's native edge-drag window tiling so it doesn't fight
    # with Rectangle's tiling shortcuts.
    WindowManager = {
      EnableTilingByEdgeDrag = false;
      EnableTopTilingByEdgeDrag = false;
    };
  };
}
