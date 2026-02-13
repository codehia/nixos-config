# NixOS Configuration with Flakes

This project is a NixOS configuration managed with `nix flakes`. The main entry point is `flake.nix`, which defines the outputs for different hosts and home-manager configurations.

## Key Files

- `flake.nix`: The main entry point for the configuration. It defines the NixOS and home-manager outputs.
- `Justfile`: Contains common commands for managing the configuration. Use `just <command>` to run them.
- `hosts/common/`: This directory contains the bulk of the configuration that is shared across all hosts. Most of your changes will likely be in here.
- `hosts/<hostname>/`: Each host has its own directory for specific hardware and system configuration.

## Developer Workflow

The main workflow is to edit the configuration files and then apply them using the commands in the `Justfile`.

- To apply changes to the current system, run:
  ```bash
  just install
  ```
- To update all flake inputs:
  ```bash
  just up
  ```
- To see all available commands, check the `Justfile`.

## How to Edit the Configuration

- **Application Configuration**: Most application configurations are located in `hosts/common/home/`. For example, neovim's configuration is in `hosts/common/home/nvim/`.
- **System Configuration**: Host-specific system configurations, like hardware settings, are in `hosts/<hostname>/`.
- **Shared Configuration**: Shared system-wide configurations are in `hosts/common/nixos/`.

When making changes, it's best to find the relevant module in the `hosts` directory and edit it. After making changes, apply them with `just install`.
