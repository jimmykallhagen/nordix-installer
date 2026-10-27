---
name: dialog
description: Use this skill when working with the Linux 'dialog' utility, building bash menus, tui interfaces, inputboxes, or shell scripting layouts.
---

# Dialog Man-Page Reference:

---



# dialog – display dialog boxes from shell scripts

## NAME
`dialog` – display dialog boxes from shell scripts  

---

## SYNOPSIS
```text
dialog --clear
dialog --create-rc file
dialog --print-maxsize
dialog common-options box-options
```

---

## DESCRIPTION
`dialog` lets you present a variety of question dialogs or messages from a shell script.  
Supported box types:

`buildlist`, `calendar`, `checklist`, `dselect`, `editbox`, `form`, `fselect`,
`gauge`, `infobox`, `inputbox`, `inputmenu`, `menu`, `mixedform`,
`mixedgauge`, `msgbox`, `passwordbox`, `passwordform`, `pause`, `prgbox`,
`programbox`, `progressbox`, `radiolist`, `rangebox`, `tailbox`,
`tailboxbg`, `textbox`, `timebox`, `treeview`, `yesno`

You can chain dialog boxes:

- Use `--and-widget` to force progression unless *Esc* cancels.
- Append tokens for the next dialog box to create a chain.  
  Dialog stops chaining when a widget returns a non‑zero status (see **DIAGNOSTICS**).

Some widgets (e.g., `checklist`) write text to dialog’s **stdout** or **stderr**,
which can be redirected with `--output-fd`, `--stderr`, or `--stdout`.  
No text is written if *Cancel* (or *Esc*) is pressed; dialog exits immediately.

---

## OPTIONS

### General notes
- All options start with `--`.
- A standalone `--` escapes the next token (different from `getopt(1)`).
- Boolean options can be negated with `--no-…` (e.g., `--no-shadow` also accepts `--shadow`).

### Common options
| Option | Description |
|--------|-------------|
| `--ascii-lines` | Use ASCII “+” and “‑” for box borders. |
| `--aspect-ratio` | Width/height ratio when auto‑sizing (default 9). |
| `--backtitle string` | Backtitle displayed at the top of the backdrop. |
| `--begin y x` | Position upper‑left corner of the dialog (y, x). |
| `--cancel-label string` | Override “Cancel” button label. |
| `--clear` | Clear the widget screen, keeping only `screen_color`. |
| `--color-mode code` | Extend `--colors` to *programbox*, *tailbox*, *textbox* (code 2). |
| `--colors` | Interpret `\Z` sequences for color/attributes (0‑7, `b`/`B`, `r`/`R`, `u`/`U`). |
| `--column-separator string` | Split data for list widgets on this string and align into columns. |
| `--cr-wrap` | Treat embedded `\n` as screen newlines or wrap as needed. |
| `--create-rc file` | Dump a sample run‑time configuration file. |
| `--cursor-off-label` | Place cursor at end of button label instead of first character. |
| `--date-format format` | Format for `--calendar` date (strftime style). |
| `--defaultno` | Make the default button *No* (or *Cancel*). |
| `--default-button string` | Set default button (`ok`, `yes`, `cancel`, `no`, `help`, `extra`). |
| `--default-item string` | Set default item for `checklist`, `form`, `menu`. |
| `--erase-on-exit` | Clear screen and place cursor at lower‑left on exit. |
| `--exit-label string` | Override “Exit” button label. |
| `--extra-button` | Add an extra button between *OK* and *Cancel*. |
| `--extra-label string` | Override label of the extra button. |
| `--help` | Show help and exit. |
| `--help-button` | Show a help button for list widgets. |
| `--help-label string` | Override “Help” button label. |
| `--help-status` | After help, write checklist/radiolist/form info. |
| `--help-tags` | On help, write only the item’s tag. |
| `--hfile filename` | Show file when F1 is pressed. |
| `--hline string` | Center string at bottom of widget. |
| `--ignore` | Ignore unrecognized options. |
| `--input-fd fd` | Read keyboard input from file descriptor `fd`. |
| `--insecure` | Echo asterisks for password widgets (less secure). |
| `--iso-week` | ISO‑8601 week numbering for `--calendar`. |
| `--item-help` | Show a help column for checklist, radiolist, menu. |
| `--keep-tite` | Use initialization strings when running in xterm. |
| `--keep-window` | Preserve previous widget when chaining with `--and-widget`. |
| `--last-key` | Report last key pressed (curses key code). |
| `--max-input size` | Limit input strings to `size` (default 2048). |
| `--no-cancel` | Suppress “Cancel” button in checklist, inputbox, menu. |
| `--no-collapse` | Do not collapse whitespace (tabs → spaces, multiple spaces → single). |
| `--no-hot-list` | Disable hotkey highlighting for lists. |
| `--no-items` | Omit “item” column for list widgets (`checklist`, `inputmenu`, …). |
| `--no-kill` | Keep `tailboxbg` process alive, print its PID. |
| `--no-label string` | Override label of “No” buttons. |
| `--no-lines` | No lines around boxes (like `--ascii-lines`). |
| `--no-mouse` | Disable mouse support. |
| `--no-nl-expand` | Do not expand `\n` into real newlines. |
| `--no-ok` | Suppress “OK” button (Enter activates current button). |
| `--no-okSuppress` | Hide “OK” button entirely. |
| `--no-shadow` | Remove shadows from dialog boxes. |
| `--no-tags` | Hide tag column for list widgets. |
| `--ok-label string` | Override label of “OK” buttons. |
| `--output-fd fd` | Direct output to file descriptor `fd`. |
| `--separator string` | Override default output separator (newline/space). |
| `--print-maxsize` | Print dialog’s maximum screen size. |
| `--print-size` | Print size of each dialog when initialized. |
| `--print-text-only string[ height[ width]]` | Print a string as it would be wrapped in a message box. |
| `--print-text-size string[ height[ width]]` | Print size of a string as it would be wrapped. |
| `--print-version` | Print dialog version and exit. |
| `--quoted` | Quote output strings (useful for spaces or quotes). |
| `--reorder` | Use order of user selections instead of default order. |
| `--scrollbar` | Draw a scrollbar for scrollable widgets. |
| `--separate-output` | Output one result per line (no quoting). |
| `--separate-widget string` | Override default separator between multiple widgets. |
| `--single-quoted` | Use single‑quoting for checklist output. |
| `--size-err` | Check dialog size before use (obsolete). |
| `--sleep secs` | Sleep `secs` seconds after each widget. |
| `--stderr` | Direct output to *stderr* (default). |
| `--stdout` | Direct output to *stdout* (non‑portable). |
| `--tab-correct` | Convert tabs to spaces (unless `--no-collapse`). |
| `--tab-len n` | Set tab width when `--tab-correct` is used (default 8). |
| `--time-format format` | Format for `--timebox` time (strftime style). |
| `--timeout secs` | Exit after `secs` seconds without response. |
| `--title string` | Title displayed at top of dialog box. |
| `--trace filename` | Log parameters, keystrokes, etc. to `filename`. |
| `--week-start day` | Set first day of week for `--calendar` (0‑6, `locale`, or abbrev). |
| `--trim` | Trim leading blanks, literal newlines, repeated blanks. |

### Box options (common parameters)
All box types accept at least:

```
text   – caption or contents
height – dialog height
width  – dialog width
```

#### Example widgets
- **`--buildlist`**: two side‑by‑side lists; returns selected tags.
- **`--calendar`**: calendar with day/month/year; returns `day/month/year`.
- **`--checklist`**: checklist; returns tags of selected items.
- **`--dselect`**, **`--editbox`**, **`--form`**, **`--fselect`**, **`--gauge`**, **`--infobox`**, **`--inputbox`**, **`--inputmenu`**, **`--menu`**, **`--mixedform`**, **`--mixedgauge`**, **`--msgbox`**, **`--pause`**, **`--passwordbox`**, **`--passwordform`**, **`--prgbox`**, **`--programbox`**, **`--progressbox`**, **`--radiolist`**, **`--rangebox`**, **`--tailbox`**, **`--tailboxbg`**, **`--textbox`**, **`--timebox`**, **`--treeview`**, **`--yesno`**.

*(Full definitions are retained in the source; the table above lists the key parameters.)*

---

## DIAGNOSTICS (EXIT STATUS)

| Status | Meaning |
|--------|---------|
| `0` | **YES** or **OK** button pressed (`DIALOG_OK`). |
| `1` | **NO** or **Cancel** button pressed (`DIALOG_CANCEL`). |
| `2` | **Help** button pressed (`DIALOG_HELP`). |
| `3` | **Extra** button pressed (`DIALOG_EXTRA`). |
| `4` | **Help** with `--item-help` (`DIALOG_ITEM_HELP`). |
| `5` | **Timeout** (`DIALOG_TIMEOUT`). |
| `-1` | Errors (`DIALOG_ERROR`) or **Esc** (`DIALOG_ESC`). |

Environment variables can override the default mapping:

- `DIALOG_OK` (0) – `YES`/`OK` exit code
- `DIALOG_CANCEL` (1) – `NO`/`Cancel` exit code
- `DIALOG_HELP` (2) – **Help** exit code
- `DIALOG_EXTRA` (3) – **Extra** exit code
- `DIALOG_ERROR` (–1) – Error exit code
- `DIALOG_ESC` (255) – Esc exit code
- `DIALOG_TIMEOUT` (5) – Timeout exit code
- `DIALOG_ITEM_HELP` (4) – Help with `--item-help` code

---

## ENVIRONMENT

| Variable | Effect |
|----------|--------|
| `DIALOGOPTS` | Apply listed common options to each widget (escaped with quotes). |
| `DIALOGRC` | Name of the configuration file to use. |
| `DIALOG_…` (OK, CANCEL, ERROR, ESC, …) | Override default exit status as described above. |
| `DIALOG_TTY` | `1` forces old behavior of treating redirected stdout as `--stdout`. |

---

## FILES

- `$HOME/.dialogrc` – Default configuration file.

---

## PORTABILITY / COMPATIBILITY

- Works with X/Open Curses.  
- Known issues: HPUX `newterm` (affects `--input-fd`); NetBSD 5.1 curses (wide‑character support).

### Clones

| Implementation | Notes |
|----------------|-------|
| **Original dialog** (0.3‑0.9) | Maps deprecated options (`--beep-after` ignored, `--guage` → `--gauge`). |
| **Xdialog** | X‑based; many `dialog` options are ignored or mapped (e.g., `--separator` → `--separate-output`). |
| **Whiptail** | Debian replacement; fewer widgets, less compatible; maps several options (`--cancel-button` → `--cancel-label`, …). |

---

## BUILT‑IN KEY BINDINGS

Common built‑in keys (independent of widget):

| Key | Purpose |
|-----|---------|
| `Ctrl‑I` | Forward tab‑traversal. |
| `Ctrl‑L` | Repaint screen. |
| `Ctrl‑T` | Dump current screen to `--trace` file. |
| `Ctrl‑V` | Suppress special‑keys for next byte. |
| `DLGK_FIELD_NEXT` | Tab forward in a form. |
| `DLGK_FIELD_PREV` | Tab backward in a form. |
| `DLGK_HELPFILE` | Show help file (`--hfile`). |
| `KEY_BTAB` | Backward tab (e.g., with `--tailboxbg`). |

Widgets can have custom key bindings via the config file; see the `bindkey` command.

---

## EXAMPLES

See the `samples/` directory of the source for real‑world scripts demonstrating each widget type.

---

## AUTHORS

- Thomas E. Dickey – updates for 0.9b+  
- Kiran Cherupally – mixed form & mixed gauge  
- Tobias C. Rittweiler  
- Valery Reznic – form & progressbox  
- Yura Kalinichenko – pause widget adaptation  
- Original authors of dialog 0.3‑0.9 (Savio Lam, Stuart Herbert, Marc Ewing, Pasquale De Marco)

---
