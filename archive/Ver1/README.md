# QFM - QMenu Folder Manager

QFM (QMenu Folder Manager) is a client-side Garry's Mod addon that replaces the default Sandbox Q-menu tool/category list with a customizable folder and favorites management system.

## Features

* Custom tool folders
* Favorites support
* Folder pinning
* Folder renaming and editing
* Context menu integration
* Client-side data storage
* Development reload command

## Controls

### Folder Bar

* Left click **All**, **Favorites**, or a folder to filter the current Q-menu tab.
* Right click the QFM bar to open the global menu.

### Folder Management

* Right click a folder to:

  * Rename it
  * Pin/Unpin it
  * Edit its contents
  * Delete it

### Tool Management

* Right click a tool or category in the left Q-menu list to:

  * Add it to Favorites
  * Add it to a Folder

### Development

Reload the addon while the game is running:

```console
eblansky_qfm_reload
```

## Data Storage

Folder configuration is stored locally:

```text
garrysmod/data/eblansky_qfm/folders.json
```

## License

MIT License

Copyright (c) 2025 Ktouhludublon
