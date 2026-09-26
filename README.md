<img width="128" height="128" alt="icon" src="https://github.com/Neko-hey/ClipHistory/blob/main/src/icon.png?raw=true"/>

# ClipHistory

ClipHistory is a lightweight clipboard history manager for macOS

## Key Features

* Automatically saves and manages clipboard history
* Lightweight and simple design
* Press ⌘ + B to display the menu

<img width="512" height="512" alt="sample" src="https://github.com/Neko-hey/ClipHistory/blob/main/image/sample.png?raw=true"/>

## Installation

1. Download the latest `ClipHistory.dmg` from the [Releases](https://github.com/Neko-hey/ClipHistory/releases) page
2. Open the downloaded `.dmg` file and drag `ClipHistory.app` into your `/Applications` folder

### Updating

When updating from a previous version, run the following command in Terminal to stop any running instances before installing the new version:

```bash
killall ClipHistory 2>/dev/null || true
```

### If a Warning Appears on First Launch

If macOS security features (quarantine attribute) prevent the app from opening, run the following command in Terminal to clear the attribute:

```bash
sudo xattr -cr /Applications/ClipHistory.app
```

## License

This project is distributed and provided under the terms specified in the [LICENSE](https://github.com/Neko-hey/ClipHistory/tree/main?tab=MIT-1-ov-file) file
