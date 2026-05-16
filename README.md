# LazyVim Setup

Opinionated LazyVim template focused on fast navigation, low-friction search, and practical Git workflows.

This configuration keeps both Snacks Explorer and Telescope File Browser because they solve different problems well:

- Snacks Explorer for fast tree navigation.
- Telescope for fuzzy workflows, code discovery, and contextual search.

## Design Goals

- Keep startup clean and visually stable.
- Prioritize keyboard-driven workflows.
- Reduce context switching between search, Git, and terminal tasks.
- Keep defaults predictable while adding practical power tools.

## Core Stack

- Base: LazyVim
- Theme: Catppuccin (mocha) with transparent background
- Search and picker UI: Telescope (+ file_browser, fzf-native, ui-select)
- File explorer: Snacks
- Terminal workflow: ToggleTerm (purpose-specific terminals)
- Git UX: Gitsigns + Diffview
- Project-wide search/replace: Spectre
- Comments: Comment.nvim
- Text editing: nvim-surround

## Notable Customizations

### Visual and UI

- Transparent Catppuccin setup applied early to avoid delayed background transitions.
- Float and popup backgrounds are transparent for visual consistency.
- Clean statusline/UI defaults with strict signcolumn and cursorline.

### Telescope Enhancements

- Extensions enabled:
 	- file_browser
 	- ui-select
 	- fzf-native (auto-enabled when make is available)
- Practical defaults:
 	- Smart path display.
 	- Ignore patterns for heavy directories (.git, node_modules, dist, build, target, .cache).
 	- Hidden files included in search while excluding .git internals.
 	- Centered layout with top prompt and ascending sorting.
- Picker workflow mappings:
 	- Ctrl+j / Ctrl+k to move selection.
 	- Ctrl+q to send results to quickfix.

### Terminal Workflow (ToggleTerm)

Purpose-specific floating terminals to reduce command-history clashes:

- <leader>tt: generic terminal
- <leader>tr: run terminal
- <leader>ty: tests terminal
- <leader>tm: misc terminal

Behavior:

- Starts in insert mode.
- Preserves terminal mode across toggles.
- Closes automatically when process exits.

### Git Workflow

Gitsigns is configured for action-first usage:

- Hunk navigation: [h and ]h
- Stage/reset hunk and buffer operations
- Inline blame is disabled by default to reduce noise
- <leader>gb toggles inline blame
- <leader>gL and <leader>gB show focused blame info

Diffview provides quick visual review flows:

- <leader>gd: open diff view
- <leader>gh: file history
- <leader>gH: branch history
- <leader>gq: close diff view

### Search and Refactor

Spectre is configured for project and scoped replacement:

- <leader>sr: open search and replace panel
- <leader>sw: search current word (normal) or selection (visual)
- <leader>sf: search inside current file

### Text Editing (Surround)

- ys + motion + char: add surround
- yss: add surround to current line
- ds + char: delete surround
- cs + old + new: change surround
- S (visual): surround selection
- <leader>aa: prompt surround for current word or selection
- <leader>aA: prompt surround for current line
- <leader>ad: prompt delete surround target
- <leader>ar: prompt change surround target and replacement
- <leader>aq / <leader>aQ: double or single quotes
- <leader>ap / <leader>ab / <leader>aB / <leader>al / <leader>ak: parentheses, brackets, braces, angle brackets, backticks
- <leader>at / <leader>af / <leader>ai: tag, function call, custom delimiters
- <leader>ax*: direct delete shortcuts by surround type
- <leader>ac*: direct change-to shortcuts by surround type

### Autocommands for Productivity

- Highlight text on yank.
- Restore cursor position when reopening files.
- Auto-create missing parent directories before save.
- Close utility buffers with q (help, qf, man, lspinfo, checkhealth, and similar).

## Keymap Reference

### Search and Find

- <leader>ff: find files
- <leader>fr: live grep
- <leader>f/: fuzzy find in current buffer
- <leader>f.: resume last picker
- <leader>fW: grep word under cursor
- <leader>fe: Telescope file browser
- <leader>fo: recent files
- <leader>fw: diagnostics
- <leader>fT: TODO/FIXME/HACK/NOTE/XXX search

### Explorer

- <leader>e: Snacks explorer

### LSP and Code

- <leader>ca: code actions
- <leader>cf: format (normal/visual)
- <leader>ck: hover
- <leader>cg: definition
- <leader>cI: implementation
- <leader>cT: type definition
- <leader>ce: line diagnostics

### Around / Surround Helpers

- <leader>aa: add surround with prompt
- <leader>aA: add surround to current line with prompt
- <leader>ad: delete surround with prompt
- <leader>ar: replace surround with prompt
- <leader>aR: replace surround linewise
- <leader>aq: surround with double quotes
- <leader>aQ: surround with single quotes
- <leader>ap: surround with parentheses
- <leader>ab: surround with brackets
- <leader>aB: surround with braces
- <leader>al: surround with angle brackets
- <leader>ak: surround with backticks
- <leader>at: surround with tag
- <leader>af: surround with function call
- <leader>ai: surround with custom delimiters
- <leader>axq / <leader>axp / <leader>axb / <leader>axB / <leader>axl: delete quote, parens, brackets, braces, angle brackets
- <leader>axt / <leader>axf: delete tag or function call surround
- <leader>acq / <leader>acQ / <leader>ack: change nearest quote surround to double quotes, single quotes, backticks
- <leader>acp / <leader>acb / <leader>acB / <leader>acl: change nearest standard surround to parens, brackets, braces, angle brackets
- <leader>act / <leader>acf: change chosen surround to tag or function call

### Window Management

- ss / sv: split horizontal / vertical
- sh / sj / sk / sl: navigate splits
- Alt+h / Alt+j / Alt+k / Alt+l: resize splits

## Useful Commands

- :Lazy sync
- :Lazy check
- :Telescope
- :DiffviewOpen
- :DiffviewFileHistory
- :LspInfo
- :checkhealth

## Why This Setup Works

- Dual navigation model (Snacks + Telescope) matches real-world context switching.
- Purpose-specific terminals keep run/test/misc histories isolated.
- Search stack is optimized for both codebases and dotfiles.
- Git tooling supports both quick hunk edits and deep history reviews.
- Small automation details (autocmds) remove repetitive friction during long sessions.
