# Tailscale — Reference

> Config: `modules/aspects/tailscale.nix`

---

## What is Tailscale?

Tailscale is a **WireGuard-based overlay network** that creates a private mesh network
(tailnet) across all your devices. Every node gets a stable IP in the `100.x.x.x` range
and a DNS name via MagicDNS.

---

## How It Works

- Each device runs the Tailscale client, which establishes encrypted WireGuard tunnels
- Nodes communicate directly (P2P) when possible, via relay servers (DERP) when not
- **MagicDNS**: each node gets a FQDN like `hostname.tailnet-name.ts.net`
- A built-in DNS resolver at `100.100.100.100` resolves tailnet names
- Works through NAT, across networks, from anywhere

---

## Our Config

```nix
# modules/aspects/tailscale.nix
den.aspects.tailscale = {
  nixos = { pkgs, ... }: {
    services.tailscale = {
      enable = true;
      package = pkgs.unstable.tailscale;   # always latest from unstable
      openFirewall = true;                  # opens UDP 41641 for WireGuard
    };
  };
};
```

Included on all three hosts (`personal`, `thinkpad`, `workstation`).

---

## NixOS Options

| Option | Description |
|--------|-------------|
| `services.tailscale.enable` | Enables tailscaled daemon |
| `services.tailscale.package` | Tailscale package (we use unstable) |
| `services.tailscale.openFirewall` | Opens UDP 41641 for WireGuard traffic |
| `services.tailscale.useRoutingFeatures` | `"client"` / `"server"` / `"both"` for subnet routing |
| `services.tailscale.authKeyFile` | Path to auth key file for headless auth |
| `services.tailscale.extraUpFlags` | Extra flags for `tailscale up` |

---

## MagicDNS

With MagicDNS enabled in the Tailscale admin panel:
- Each host gets: `<hostname>.tailnet-name.ts.net`
- Short names also resolve within the tailnet: `personal`, `thinkpad`, `workstation`
- DNS resolver: `100.100.100.100` (Tailscale's internal resolver)

### DNS Modes

| Mode | Behavior |
|------|----------|
| Override local DNS (off, default) | Only `*.ts.net` + tailnet search domain routes through Tailscale DNS |
| Override local DNS (on) | ALL DNS queries go through Tailscale, including your normal DNS |

Recommended: keep override **off**. Let systemd-resolved coordinate with Tailscale.

---

## Common Operations

```bash
# Initial auth (run once per machine)
sudo tailscale up

# Check status
tailscale status

# Get this device's IP
tailscale ip

# Ping another node
tailscale ping workstation

# SSH to another node (uses tailnet IP/name)
ssh deus@personal.tailnet.ts.net

# Use as exit node
sudo tailscale up --exit-node=personal
```

---

## DNS with systemd-resolved (Recommended)

Tailscale's recommended DNS setup on Linux uses `systemd-resolved` as intermediary:

```nix
# modules/aspects/system/resolved.nix (to be created)
services.resolved = {
  enable = true;
  dnssec = "allow-downgrade";
  domains = [ "~." ];
  fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
  extraConfig = ''
    MulticastDNS=resolve
  '';
};
```

Benefits:
- Fixes wakeup/resume DNS bug (Tailscale fails to restore `/etc/resolv.conf` on resume)
- Clean coordination between Tailscale, Avahi mDNS, and regular DNS
- `MulticastDNS=resolve` lets resolved handle `.local` queries without full avahi-daemon

---

## What Tailscale Does NOT Do

- **No mDNS/multicast** — cannot resolve `hostname.local` on LAN (GitHub issue #1013, open since 2020)
- **No link-local scope** — operates over the internet, not broadcast domain
- **No service discovery** (DNS-SD) — does not announce printers, SMB shares, etc.

These gaps are why **Avahi is still needed** alongside Tailscale. See `avahi-tailscale.md`.

---

## References

- [Tailscale MagicDNS](https://tailscale.com/docs/features/magicdns)
- [Configuring Linux DNS](https://tailscale.com/kb/1188/linux-dns)
- [NixOS Wiki — Tailscale](https://wiki.nixos.org/wiki/Tailscale)
- `notes/avahi-tailscale.md` — how Avahi and Tailscale work together
