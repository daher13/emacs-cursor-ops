# Cursor Ops for Emacs

**Cursor Ops** is an Emacs plugin that enhances cursor movement and text manipulation in the buffer, providing intelligent operations with words, special characters, and spaces for both navigation and deletion.

---

## Features

- **Advanced cursor movement**
  - `cursor-ops--forward-expr` — moves the cursor forward over sequences of alphanumeric characters, special characters, or spaces.
  - `cursor-ops--backward-expr` — moves the cursor backward over sequences of alphanumeric characters, special characters, or spaces.

- **Intelligent deletion**
  - `cursor-ops--forward-delete-expr` — deletes forward following the same sequence rules.
  - `cursor-ops--backward-delete-expr` — deletes backward following the same sequence rules.
  - `cursor-ops--delete-lines` — deletes entire lines or the active region if a selection exists, preserving column position.

- **Keyboard shortcuts**
  - `left-word` → intelligent backward navigation
  - `right-word` → intelligent forward navigation
  - `backward-kill-word` → intelligent backward deletion
  - `kill-word` → intelligent forward deletion
  - `C-S-<backspace>` → delete entire lines
  - `<home>` → move to the beginning of the text on the line (ignoring leading spaces)

---

## Installation

1. Save the file `cursor-ops.el` in a directory of your choice, for example:

```text
~/.emacs.d/plugins/cursor-ops.el
```

2. Add the directory to your load-path in init.el or .emacs:

```
(load-file (concat user-emacs-directory "plugins/cursor-ops.el"))
```

3. Load the plugin

(require 'cursor-ops)

---

## Usage

- Navigation: Use left-word (ctrl + <left>) and right-word (ctrl + <right>) to move intelligently between words, special characters, and spaces.
- Deletion: Use backward-kill-word (ctrl + <backspace>) and kill-word (ctrl + <delete>) to delete intelligently in the same segments as the movement.
- Delete entire lines: Press C-S-<backspace>.
- Go to beginning of line text: Press <home>.

## Motivation


The plugin was created to provide more natural movement and deletion in Emacs, taking into account sequences
of special characters, spaces, and alphanumeric words consistently — something that Emacs does not do by default.

## Contributing

Pull requests are welcome! For suggestions or issues, please open an issue in the repository.
