# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration built on the **LazyVim** framework with **lazy.nvim** as the plugin manager. It is currently a near-stock LazyVim starter template with minimal customization — the config files (`options.lua`, `keymaps.lua`, `autocmds.lua`) are empty and rely on LazyVim defaults. No LazyVim extras are enabled.

## Architecture

**Bootstrap flow:** `init.lua` → `lua/config/lazy.lua` (clones lazy.nvim if missing, loads LazyVim + user plugins)

**Plugin specs** are loaded from `lua/plugins/`. Each `.lua` file in that directory is auto-loaded by lazy.nvim. The existing `example.lua` is a reference file that short-circuits with `if true then return {} end` — it does not load any plugins.

**Customization points** (all auto-loaded by LazyVim):
- `lua/config/options.lua` — `vim.opt` / `vim.g` settings
- `lua/config/keymaps.lua` — `vim.keymap.set()` bindings
- `lua/config/autocmds.lua` — `vim.api.nvim_create_autocmd()` definitions

**To add a plugin:** Create a new file in `lua/plugins/` returning a lazy.nvim spec table.

**To override a LazyVim plugin:** Use the same plugin URL in a spec with `opts`, `enabled`, or `keys` to merge/override.

**To enable a LazyVim extra:** Add `{ import = "lazyvim.plugins.extras.<category>.<name>" }` in a plugin spec, or use `:LazyExtras` interactively.

## Code Style

Lua formatting is handled by **stylua** with the project config in `stylua.toml`:
- 2-space indentation (spaces, not tabs)
- 120-character line width

Format Lua files: `stylua lua/`

## Key Tools in the Stack

- **LSP:** nvim-lspconfig + mason.nvim (auto-install servers)
- **Completion:** blink.cmp
- **Formatting:** conform.nvim
- **Linting:** nvim-lint
- **Fuzzy finder:** telescope.nvim
- **Treesitter:** nvim-treesitter (syntax, textobjects)
- **Color scheme:** tokyonight (default)
