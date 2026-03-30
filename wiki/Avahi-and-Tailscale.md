# Avahi + Tailscale — Combined Reference

> See also: [[Avahi]], [[Tailscale]]

---

## TL;DR

**Keep both. They solve different problems and do not conflict.**

| Concern | Use |
|---------|-----|
| SSH/sync between your own hosts | Tailscale (`hostname.ts.net`) |
| LAN device discovery (printer, NAS, phone) | Avahi (`hostname.local`) |
| Service announcements (AirPrint, SMB, Cast) | Avahi DNS-SD |
| Cross-network, through NAT | Tailscale only |
| Link-local only (same subnet) | Avahi only |

---

## What Each Does

### Avahi (mDNS/Zeroconf)
- Multicast UDP port 5353, link-local only (TTL=1, cannot cross routers)
- Resolves `hostname.local` via `nss-mdns` NSS module
- Announces/discovers services: printers, Samba, AirPlay, Chromecast, SSH
- Scope: **same network segment only**

### Tailscale MagicDNS
- WireGuard overlay, unicast DNS at `100.100.100.100`
- Each node: `hostname.tailnet-name.ts.net`
- Works **across all subnets, through NAT, anywhere**
- Does NOT support mDNS/multicast (GitHub issue open since 2020)

---

## Do They Conflict?

**At the network level: No.**
- Avahi: multicast `224.0.0.251:5353`
- Tailscale: unicast `100.100.100.100:53`
Different protocols, different ports, no socket contention.

**At the resolver level: Potentially, if misconfigured.**

The risk: Tailscale "Override local DNS" mode can cause `.local` queries to fall through
to a non-mDNS resolver, causing timeouts. Fix: use `systemd-resolved` as intermediary.

**Known NixOS issue (nixpkgs #291108):**
`nssmdns6 = true` (non-minimal IPv6 mDNS) causes 5-second timeouts on every failed lookup.
Always use `nssmdns4 = true` (minimal) and drop the IPv6 variant.

---

## Use Cases

### Avahi still needed (Tailscale can't help)
| Use Case | Why Tailscale can't |
|----------|-------------------|
| Network printers (CUPS/AirPrint) | `_ipp._tcp.local` is mDNS service discovery |
| GNOME Files / GVFS SMB browsing | Needs Avahi DNS-SD to find shares |
| Chromecast / Cast devices | mDNS discovery only |
| iOS device pairing (usbmuxd) | Avahi service announcement |
| AirPlay via PipeWire | `_raop._tcp` discovery |
| `.local` names for LAN devices (NAS, RPi) | Not on tailnet, only link-local |

### Tailscale makes Avahi redundant for your own hosts
| Use Case | Prefer |
|----------|--------|
| SSH between personal/thinkpad/workstation | `ssh deus@personal.tailnet.ts.net` |
| Syncthing between hosts | Stable Tailscale IPs, works across networks |
| Accessing services on your hosts remotely | Tailscale FQDN |

---

## Recommended Setup

### 1. Avahi — drop `nssmdns6`, add `publish`

```nix
services.avahi = {
  enable = true;
  nssmdns4 = true;      # IPv4 mDNS — works correctly
  # nssmdns6 = false;   # drop — causes 5s timeouts
  openFirewall = true;
  publish = {
    enable = true;
    addresses = true;
    workstation = true;
  };
};
```

### 2. systemd-resolved (Tailscale-recommended DNS coordinator)

```nix
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
- Tailscale integrates cleanly with resolved
- Fixes wakeup/resume DNS bug (Tailscale fails to restore `/etc/resolv.conf`)
- `MulticastDNS=resolve` coordinates `.local` resolution correctly

### 3. Tailscale — no changes needed

Current config (`pkgs.unstable.tailscale`, `openFirewall = true`) is correct.
Keep "Override local DNS" **off** in the admin panel.

---

## Current Status

| Host | Avahi | Tailscale | systemd-resolved |
|------|-------|-----------|-----------------|
| personal | ✓ (nssmdns4+6) | ✓ | ✗ |
| thinkpad | ✓ (nssmdns4+6) | ✓ | ✗ |
| workstation | ✗ | ✓ | ✗ |

**Gaps to fix:**
- Drop `nssmdns6` on personal + thinkpad
- Add `publish` block to personal + thinkpad
- Add Avahi to workstation
- Add systemd-resolved to all hosts
- Extract Avahi to `modules/aspects/avahi.nix`

---

## References

- [MagicDNS — Tailscale Docs](https://tailscale.com/docs/features/magicdns)
- [Configuring Linux DNS — Tailscale Docs](https://tailscale.com/kb/1188/linux-dns)
- [Support mDNS — tailscale/tailscale #1013](https://github.com/tailscale/tailscale/issues/1013)
- [avahi-daemon slow DNS — NixOS/nixpkgs #291108](https://github.com/NixOS/nixpkgs/issues/291108)
