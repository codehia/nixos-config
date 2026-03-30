# Avahi — Reference

> Config: inline in `modules/hosts/personal/default.nix` and `modules/hosts/thinkpad/default.nix`
> (To be extracted to `modules/aspects/avahi.nix`)

---

## What is Avahi?

Avahi is the Linux implementation of **mDNS/Zeroconf/DNS-SD** — a suite of protocols
that enable zero-configuration networking on a local network segment.

Three things it provides:
1. **mDNS** (Multicast DNS): resolves `hostname.local` names without a DNS server
2. **DNS-SD** (DNS Service Discovery): announces and discovers services on the LAN
3. **Zeroconf**: automatic IP address assignment on link-local when no DHCP is available

---

## How mDNS Works

- Uses multicast UDP on port 5353, address `224.0.0.251`
- TTL=1 — packets cannot cross routers (strictly link-local)
- Each host announces itself and responds to queries for its `hostname.local` name
- NixOS integrates via `nss-mdns` NSS module — inserts `mdns4_minimal [NOTFOUND=return]`
  into `/etc/nsswitch.conf` so `getent hosts mydevice.local` works

---

## DNS-SD — Service Discovery

Avahi announces services over DNS-SD records, discoverable by other LAN devices:

| Service | DNS-SD type | Discoverable by |
|---------|-------------|-----------------|
| Network printer | `_ipp._tcp.local` | CUPS, macOS, iOS |
| AirPrint | `_ipp._tcp.local` | AirPrint clients |
| Samba shares | `_smb._tcp.local` | GNOME Files, Windows |
| SSH | `_ssh._tcp.local` | SSH browsers |
| AirPlay/RAOP | `_raop._tcp.local` | PipeWire, Shairport |
| Chromecast | `_googlecast._tcp.local` | Cast apps |

---

## Our Current Config

```nix
services.avahi = {
  enable = true;
  nssmdns4 = true;   # inserts mdns4_minimal into nsswitch.conf
  nssmdns6 = true;   # IPv6 mDNS (may cause timeouts — see notes)
  openFirewall = true;
};
```

**workstation**: Avahi NOT enabled (oversight — should be added).

---

## NixOS Options

| Option | Description |
|--------|-------------|
| `services.avahi.enable` | Enable avahi-daemon |
| `services.avahi.nssmdns4` | IPv4 mDNS via nss-mdns (`mdns4_minimal`) |
| `services.avahi.nssmdns6` | IPv6 mDNS via nss-mdns (`mdns6_minimal`) |
| `services.avahi.openFirewall` | Opens UDP 5353 in firewall |
| `services.avahi.publish.enable` | Allow this host to publish services |
| `services.avahi.publish.addresses` | Announce host IP addresses |
| `services.avahi.publish.workstation` | Announce as a workstation |
| `services.avahi.publish.userServices` | Let user services publish |
| `services.avahi.ipv4` | Enable IPv4 (default true) |
| `services.avahi.ipv6` | Enable IPv6 (default false) |

---

## Recommended Config

```nix
services.avahi = {
  enable = true;
  nssmdns4 = true;
  # nssmdns6 = false;  # drop IPv6 mDNS — causes 5-second timeouts on typical networks
  openFirewall = true;
  publish = {
    enable = true;
    addresses = true;    # announce your IP(s) on LAN
    workstation = true;  # announce as a workstation
  };
};
```

### Why drop `nssmdns6`?

IPv6 mDNS (`mdns6_minimal`) causes 5-second resolution timeouts on networks without IPv6
mDNS infrastructure. Unless you have a full dual-stack LAN setup, it provides no benefit
and degrades DNS performance for every failed `.local` lookup.
(Reference: NixOS/nixpkgs #291108)

### Why add `publish`?

Without publish, your host resolves `.local` names but doesn't announce its own. Other
devices won't find your machine at `hostname.local`. Enable publish to make your host
discoverable on the LAN.

---

## Planned Refactor

Extract to a shared aspect:

```nix
# modules/aspects/avahi.nix
den.aspects.avahi = {
  nixos.services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
};
```

Then add `den.aspects.avahi` to all three host includes and remove the inline blocks.

---

## References

- [Avahi — NixOS Wiki](https://wiki.nixos.org/wiki/Avahi)
- [avahi-daemon slow DNS — NixOS/nixpkgs #291108](https://github.com/NixOS/nixpkgs/issues/291108)
- See also: [[Avahi-and-Tailscale]]
