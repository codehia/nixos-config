# just is a command runner, Justfile is very similar to Makefile, but simpler.

# Always point nh at the flake in this directory, regardless of where it's cloned.
export NH_FLAKE := justfile_directory()

############################################################################
#
#  Nix commands related to the local machine
#
############################################################################

install:
	nh os switch

# Build and activate temporarily (no boot entry)
test:
	nh os test

# Build and set boot default without activating
boot:
	nh os boot

# Dry run — show what would change without applying
dry:
	nh os switch -n

# Apply with trace for debugging
debug:
	nh os switch -- --show-trace --verbose

write-flake:
	nix run ".#write-flake"

# Update all flake inputs and rebuild. To update without rebuilding: nix flake update
up:
	nh os switch -u

# Update a single flake input and rebuild: just upp i=home-manager
# To update without rebuilding: nix flake update <input>
upp:
	nh os switch -U $(i)

# Show generation history
history:
	nh os info

repl:
	nh os repl

# Garbage collect — remove old generations and unused store entries
clean:
	nh clean all
