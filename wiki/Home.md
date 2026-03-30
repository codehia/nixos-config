# NixOS Config

Multi-machine NixOS config using the dendritic pattern — features are defined once and
composed into hosts/users. No repeating the same thing per machine.

**Machines:** `personal` (desktop, AMD GPU, swayfx), `thinkpad` (laptop, swayfx + hyprland),
`workstation` (shared desktop, hyprland)

**Users:** `deus` (primary on personal/thinkpad), `soumya` (primary on workstation, secondary
on thinkpad)

---

## Pages

- [[Commands]] — just commands reference
- [[Architecture]] — how it works + folder structure
- [[Aspects]] — adding packages, aspects, and all aspect patterns
- [[Hosts]] — adding a new host
- [[Users]] — adding a new user
- [[Secrets]] — sops secrets and SSH keys
- [[Neovim]] — adding plugins, LSPs, and language tools
- [[Troubleshooting]] — known gotchas and fixes
