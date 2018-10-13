{ pkgs, lib ? pkgs.stdenv.lib, ... }:
let unstable = import <unstable> {};
in {
  imports = [
    ./git.nix
    ./parcellite.nix
  ];

  programs = {
    home-manager = {
      enable = true;
      path = https://github.com/rycee/home-manager/archive/master.tar.gz;
    };

    browserpass = {
      enable = true;
      browsers = [ "firefox" "chromium" ];
    };

    firefox.enable = true;
    feh.enable = true;
    fzf.enable = true;
    htop.enable = true;
    info.enable = true;
    man.enable = true;

    ssh = {
      enable = true;
#      matchBlocks."xyz.de" = {
#        identityFile = "/home/xyz/.ssh/xyz...";
#x      };
    };

    vim.enable = true;
#    zathura.enable = true; # currently broken

    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        custom = "$HOME/.oh-my-zsh-custom";
        theme = "agnoster";
        plugins = [
          "cabal"
          "docker"
          "docker-compose"
          "docker-machine"
          "emacs"
          "fasd"
          "git"
          "httpie"
          "mvn"
          "nix"
          "pass"
          "tmux"
          "vagrant"
          "z"
          "zsh-autosuggestions"
        ];
      };
      
      shellAliases = {
        et = "te";
        cfg = ''git --git-dir="$HOME/.cfg/" --work-tree="$HOME"'';
      };
    };
  };

  home =  {
    keyboard = {
      layout = "de";
      variant = "nodeadkeys";
    };

    packages = with pkgs; let exe = haskell.lib.justStaticExecutables; in [
      ack
      arandr
      autojump
      alacritty
      ansible
      autorandr
      blackbox
      curl
      dep
      dmenu
      docker_compose
      docker-machine
      emacs26
      evince
      fasd
      fish
      fira-code
      gimp
      gnupg
      go
      gradle
#      (exe haskellPackages.matterhorn)
      (exe haskellPackages.nix-derivation)
      highlight
      htop
      httpie
      iftop
      iotop
      jq
      less
      links
      jetbrains.idea-ultimate
      jetbrains.goland
      kafkacat
      kubernetes
      mattermost-desktop
      maven
      nix-prefetch-github
      nettools
      openjdk8
      pass
      pinentry_gnome
      playerctl
      ripgrep
      skype
      slack
      source-code-pro
      st
      terminator
      terraform
      tig
      tmux
      unzip
      vagrant
      vscode
      xmind
      youtube-dl
      zsh
    ];

    sessionVariables = {
      EDITOR = "${pkgs.emacs}/bin/emacsclient -t";
      PAGER = "less";
      LESS = "-XR --quit-if-one-screen";
    };
  };

  services = {
    blueman-applet.enable = true;

    dunst = {
      enable = true;
        settings = {
          global = {
            alignment = "center";
            allow_markup = true;
            bounce_freq = 0;
            dmenu = "${pkgs.dmenu}/bin/dmenu -p dunst";
            follow = "keyboard";
            font = "Liberation Sans 12";
            format = "<b>%s</b>\n%b";
            geometry = "300x5-30+20";
            horizontal_padding = 8;
            idle_threshold = 120;
            ignore_newline = false;
            indicate_hidden = true;
            line_height = 0;
            markup = "full";
            monitor = 0;
            padding = 8;
            separator_color = "#585858";
            separator_height = 2;
            show_age_threshold = 60;
            sort = true;
            startup_notification = true;
            sticky_history = true;
            transparency = 40;
            word_wrap = true;
            icon_position = "left";
          };
          frame = {
            width = 1;
            color = "#383838";
          };
          shortcuts = {
            close = "ctrl+space";
            close_all = "ctrl+shift+space";
            history = "ctrl+grave";
            context = "ctrl+shift+period";
          };
          urgency_low = {
            background = "#383A3B";
            foreground = "#FFFFFF";
            timeout = 10;
          };
          urgency_normal = {
            background = "#181818";
            foreground = "#E3C7AF";
            timeout = 900;
          };
          urgency_critical = {
            background = "#FD5F00";
            foreground = "#282226";
            timeout = 0;
          };
      };
    };

    flameshot.enable = true;

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

    network-manager-applet.enable = true;
    pasystray.enable = true;

    screen-locker = {
      enable = true;
      lockCmd = "i3lock"; # i3lock from nix not working.
      inactiveInterval = 3;
    };

    udiskie = {
      enable = true;
      automount = false;
    };
  };
  
  xdg = {
    /*
      configFile."mimeapps.list".text =
        let mimeapps = {
          "Default Applications" = {
          "application/pdf" = "org.pwmt.zathura.desktop";
        };
      }; in lib.generators.toINI {} mimeapps;
    */ # zathura currently broken

    configFile."gnupg/gpg-agent.conf".text = ''
      enable-ssh-support
      default-cache-ttl 600
      max-cache-ttl 7200
      pinentry-program ${pkgs.pinentry_gnome}/bin/pinentry-gnome3
    '';

    dataFile."applications/emacsclient.desktop".text = ''
      [Desktop Entry]
      Name=Emacsclient
      GenericName=Text Editor
      Comment=Edit text
      MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
      Exec=${pkgs.emacs}/bin/emacsclient -c -a "" %F
      Icon=emacs
      Type=Application
      Terminal=false
      Categories=Development;TextEditor;
      StartupWMClass=Emacs
      Keywords=Text;Editor;
    '';
  };

  systemd.user.services = {
    emacs = {
      Unit = {
        Description = "Emacs: the extensible, self-documenting text editor";
      };
      Service = {
        Type = "forking";
        ExecStart = "${pkgs.emacs}/bin/emacs --daemon";
        ExecStop = "${pkgs.emacs}/bin/emacsclient --eval \"(kill-emacs)\"";
        Environment = ''
          SSH_AUTH_SOCK=%t/keyring/ssh PATH=${pkgs.emacs}/bin:${pkgs.git}/bin:${pkgs.fasd}/bin:/run/current-system/sw/bin
        '';
        Restart = "always";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  xsession = {
    enable = true;
    windowManager.i3 =
      let modifier = "Mod4";
          workspace_chat = "0: chat";
          workspace_terminal = "1: terminal";
          workspace_editor = "2: editor";
          workspace_ide = "3: ide";
          workspace_email = "8: email";
          workspace_browser = "9: browser";
      in {
      enable = true;
      config = {
        modifier = "${modifier}";
        assigns = {
          "0: chat" = [{ class = "Mattermost|Slack"; }];
          "1: terminal" = [{ class = "Gnome-terminal|.terminator-wrapped"; }];
          "9: browser" = [{ class = "Firefox|Chromium-browser"; }];
          "2: editor" = [{ class="Emacs|Code"; }];
          "3: ide" = [{ class="jetbrains-idea"; }];
        };

        keybindings =
          lib.mkOptionDefault {
            "${modifier}+Return" = "exec ${pkgs.terminator}/bin/terminator";
            "${modifier}+period" = "exec i3lock";
            "${modifier}+1" = "workspace ${workspace_terminal}";
            "${modifier}+2" = "workspace ${workspace_editor}";
            "${modifier}+3" = "workspace ${workspace_ide}";
            "${modifier}+8" = "workspace ${workspace_email}";
            "${modifier}+9" = "workspace ${workspace_browser}";
            "${modifier}+0" = "workspace ${workspace_chat}";
            "${modifier}+Shift+1" = "move container to workspace ${workspace_terminal}";
            "${modifier}+Shift+2" = "move container to workspace ${workspace_editor}";
            "${modifier}+Shift+3" = "move container to workspace ${workspace_ide}";
            "${modifier}+Shift+8" = "move container to workspace ${workspace_email}";
            "${modifier}+Shift+9" = "move container to workspace ${workspace_browser}";
            "${modifier}+Shift+0" = "move container to workspace ${workspace_chat}";
            "${modifier}+Control+Left" = "move workspace to output Left";
            "${modifier}+Control+Right" = "move workspace to output Right";
            "${modifier}+Control+Up" = "move workspace to output Up";
            "${modifier}+Control+Down" = "move workspace to output Down";
            "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86MonBrightnessUp" = "exec xbacklight -inc 10";
            "XF86MonBrightnessDown" = "exec xbacklight -dec 10";
            "XF86AudioPlay" = "exec playerctl play";
            "XF86AudioPause" = "exec playerctl pause";
            "XF86AudioNext" = "exec playerctl next";
            "XF86AudioPrev" = "exec playerctl previous";
          };

        window.commands = [
           { criteria = { class = "Gnome-terminal|.terminator-wrapped"; }; command = "focus"; }
           { criteria = { class = "Firefox|Chromium-browser"; }; command = "focus"; }
           { criteria = { class = "Emacs|Code"; }; command = "focus"; }
           { criteria = { class = "jetbrains-idea"; }; command = "focus"; }
        ];

        startup = [
          { command = "autorandr --change"; notification = false; }
          { command = "systemctl --user start hm-graphical-session.target"; notification = false; }
          { command = "xinput --set-prop \"ALP0012:00 044E:120C\" \"libinput Natural Scrolling Enabled\" 1"; notification = false; always = true; }
          { command = "xinput --set-prop \"ALP0012:00 044E:120C\" \"libinput Tapping Enabled\" 1"; notification = false; always = true; }
        ];
      };
    };
  };
}
