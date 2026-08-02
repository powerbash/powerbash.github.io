---
name: powerbash
description: Install and configure powerbash, a powerline-style bash prompt in pure bash. Use when a user wants git branch state, path, or return code in their bash prompt, asks to set up or customize powerbash, or wants their prompt to stop being slow in a git repository.
license: MIT
---

# powerbash

powerbash is one bash script sourced into an interactive shell. It writes
segments straight into `PS1` — no daemon, no prompt framework, no patched font,
no root. Every setting is a `POWERBASH_*` environment variable; the `powerbash`
command sets them for the current shell, and `powerbash config save` persists
them.

Requires bash 3.2 or newer (including the `/bin/bash` macOS ships) and a UTF-8
locale for the `»`, `⇡`, `⇣`, `▶` glyphs. `tput` and `git` are optional —
without them the prompt degrades rather than breaking.

## Install

Always install into the user's own account. Never install as root; there is no
uninstaller for the system-wide path and it is discouraged.

Prefer Homebrew when it is available, because upgrades then come along with
`brew upgrade`:

```bash
brew install powerbash/powerbash/powerbash
pb="$(brew --prefix powerbash)/share/powerbash/powerbash.sh"
echo "source $pb" >> ~/.bashrc
```

Without Homebrew, use the install script. It downloads to
`~/.local/share/powerbash/`, then either links into `~/.bashrc.d/` if that
directory exists or appends a marked block to the startup file. Re-running it
upgrades in place:

```bash
curl -s https://get.powerbash.org | bash
```

By hand:

```bash
mkdir -p ~/.local/share/powerbash
curl -Ls https://download.powerbash.org/powerbash.sh \
  -o ~/.local/share/powerbash/powerbash.sh
echo 'source ~/.local/share/powerbash/powerbash.sh' >> ~/.bashrc
```

**Pick the right startup file.** On macOS, Terminal.app and iTerm2 start login
shells, which read `~/.bash_profile`, not `~/.bashrc`. On Fedora and RHEL the
stock `~/.bashrc` already loops over `~/.bashrc.d`, so dropping the script there
needs no `source` line at all.

Put the `source` line **near the end** of the startup file, so powerbash sees any
`PROMPT_COMMAND` other tools have set and can cooperate with it. Then
`exec bash` or open a new shell.

## Configure

Each subcommand changes the current shell only until saved. Tab completion knows
every subcommand and every value.

```bash
powerbash prompt on|off|system     # off = minimal '$ '; system = your old prompt
powerbash path off|full|working|parted|short|mini
powerbash path short add|subtract 5
powerbash git on|off
powerbash git skip /mnt/:/net/     # skip git under these path prefixes
powerbash git timeout 1            # give up on git after N seconds; 0 disables
powerbash user on|off
powerbash host on|off|auto         # auto = show only over ssh
powerbash jobs on|off
powerbash symbol on|off            # the $ / # symbol
powerbash rc on|off                # return code, shown only when non-zero
powerbash py virtualenv on|off|icon|short
powerbash term xterm-256color      # set TERM and recompute the palette
powerbash help|version|reload
```

The path modes render `/full/path/to/no/where` as: `full` unchanged, `working`
→ `where`, `parted` → `/full/.../no/where`, `short` → truncated to
`POWERBASH_PATH_SHORT_LENGTH` (20 by default), `mini` → `/f/p/t/n/where`. The
home directory is always `~`.

### Persisting

```bash
powerbash config save        # write ~/.config/powerbashrc
powerbash config load        # re-read it
powerbash config default     # delete it and reset
```

`~/.config/powerbashrc` is loaded at startup when present. It is a plain list of
`NAME=value` lines, and it is **parsed against an allowlist, never sourced** — a
hand-edited or tampered file cannot inject anything into the environment. Only
the variables below are ever written or read back.

### Environment variables

| Variable | Values | Default |
|---|---|---|
| `POWERBASH_USER` | `on`, `off` | `on` |
| `POWERBASH_HOST` | `on`, `off`, `auto` | `auto` |
| `POWERBASH_PATH` | `off`, `full`, `working`, `parted`, `mini`, `short` | `working` |
| `POWERBASH_PATH_SHORT_LENGTH` | positive integer | `20` |
| `POWERBASH_GIT` | `on`, `off` | `on` |
| `POWERBASH_GIT_SKIP_PATHS` | colon-separated path prefixes | `/mnt/` on WSL, else empty |
| `POWERBASH_GIT_TIMEOUT` | seconds; empty or `0` disables | empty |
| `POWERBASH_JOBS` | `on`, `off` | `on` |
| `POWERBASH_SYMBOL` | `on`, `off` | `on` |
| `POWERBASH_RC` | `on`, `off` | `on` |
| `POWERBASH_PY_VIRTUALENV` | `on`, `off`, `icon`, `short` | `on` |

Setting these directly in the startup file *before* the `source` line works too.

## Reading the prompt

`»branch` is the current branch, or a tag or short SHA when the head is
detached. `+` means uncommitted changes. `⇡n` / `⇣n` count commits ahead of and
behind the remote. The user segment turns yellow under `sudo` and over SSH. The
symbol is `#` and red for root. The return code appears only when non-zero.

Branch and directory names are escaped before they reach `PS1`, so a branch
named `$(rm -rf ~)` is displayed, not executed.

## Troubleshooting

**The prompt is slow in a git repo.** Usually WSL against `/mnt/c`, or a network
mount. Cheapest fix first:

```bash
powerbash git skip /mnt/     # no git lookup under these prefixes, free
powerbash git timeout 1      # run git, but give up after a second
powerbash git off            # drop the segment entirely
```

`git timeout` needs `timeout` from GNU coreutils; on macOS `brew install
coreutils` provides `gtimeout`, which powerbash finds on its own. Without
either, the command says so rather than silently doing nothing.

**No colors after SSH.** The terminal set a `TERM` the remote host has no
terminfo entry for — Ghostty sends `xterm-ghostty`, WezTerm sends `wezterm` —
so `tput` cannot resolve it. Name one the remote knows:

```bash
powerbash term xterm-256color
```

**The prompt never appears** after a system-wide install. Something assigned to
`PROMPT_COMMAND` instead of appending, discarding earlier hooks — GNOME
Terminal's `vte.sh` is the usual culprit. On bash 5.1+ powerbash uses an array
`PROMPT_COMMAND` and this resolves itself; on bash 5.0 and earlier (RHEL 8,
Ubuntu 20.04) the `z_` filename prefix that sorts powerbash last is what avoids
it. This is one of several reasons to prefer a per-user install.

**Glyphs render as boxes.** The locale is not UTF-8. Check `locale`; no font
change is needed.

## Uninstall

```bash
curl -s https://get.powerbash.org | bash -s -- uninstall   # install script
brew uninstall powerbash                                   # then drop the source line
rm ~/.local/share/powerbash/powerbash.sh                   # by hand; also the source line
rm ~/.config/powerbashrc                                   # saved settings, if wanted
```

Saved settings survive every upgrade and uninstall path unless removed
explicitly.

## Reference

- Documentation: https://powerbash.org/docs/
- Source and architecture notes: https://github.com/napalm255/powerbash
