# FAQ

## Terminal

### OSX: wrong colors in emacs

Make sure that in iterm2 preferences (`CMD-,`) the `TERM` is set to `xterm-256color` (not to `xterm-new`).

Other workaround: force `tmux` to use 256 colors (starting it with `tmux -2`).

## KVM

### /dev/kvm does not exist

If `kvm-ok` tells you that `/dev/kvm does not exist`: check in the BIOS if VT / virtualization is disabled.

This can also be verified by `dmesg` right after `kvm-ok`.

### User can't start kvm / cannot connect to /dev/kvm

`adduser $USER kvm`
