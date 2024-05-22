# Darwin Menu
Darwin menu is a Plasma applet that provides a menu system similar to that found on other operating systems. It allows users to access frequently used system settings and session controls.

Menu supports adding custom commands, which can be placed in separate sub-menu or in common list.

Applet also provides "Force Quit" app, which can be opened with global shortcut. (Default: "**⌘-⌥-⎋"**) 😊

Menu uses global theme, so will adapt to any Plasma style.
## Requirements
Plasma 6

## Install via KDE

1. Right Click Panel > Panel Options > Add Widgets
2. Get New Widgets > Download New Widgets
3. Search: "Darwin Menu"
4. Install

## Install via GitHub
Github package uses [Zren's scripts](https://github.com/Zren/plasma-applet-lib/tree/master) for installation and translation.

```
git clone https://github.com/latgardi/darwinmenu.git darwinmenu
cd darwinmenu
sh ./install
```

To update, run `git pull` then `sh ./install --restart`. Please note this script will restart `plasmashell` so you don't have to relog.

## Install Translations

Go to `~/.local/share/plasma/plasmoids/org.latgardi.darwinmenu/translate/` and run `sh ./build --restartplasma`.

## Screenshots

![](https://imgur.com/a/f9fzUU3)

## Translating

See the [package/translate](package/translate) folder for instructions on translating.

