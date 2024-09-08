# New Mac Setup Script
Forked by: JJ Smiley  
Started: 9-8-24

Forked from: [YANMSS (Yet Another New Mac Setup Script)](https://github.com/mikeprivette/yanmss)  
Original Author: Mike Privette

This script installs essential tools and applications mostly using [Homebrew](https://brew.sh).  
If you don't know what Homebrew is, your life is about to change: https://brew.sh

## About

This setup script is designed for automating the configuration of a new Mac. It adjusts default settings, installs essential Terminal tools, applications, and performs system checks for processor compatibility. Ideal for a quick and efficient setup process, this script is constantly evolving with community contributions.

### Features

- **Processor Compatibility Check**: Automatically detects M1/M2/M3 and Intel processors, adjusting installations as needed.
- **Homebrew Installation**: Installs and updates Homebrew, a package manager for macOS.
- **Finder Configuration**: Customizes Finder settings such as showing hidden files and Library folder.
- **Terminal Enhancements**: Installs Oh My Zsh for an improved terminal experience.
- **Powerline Fonts**: Adds JetBrains font for, IMHO, better aesthetics in the terminal.
- **Python and pip**: Ensures the latest Python version, along with pip, is installed.
- **Essential Applications**: Installs core applications like Visual Studio Code and 1Password.

### Installation with Curl

To install this script on a new Mac, run the following command in the terminal:

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/mikeprivette/yanmss/master/setup.sh)"
```

**Note**: If you do not have [Xcode Command Line Tools](https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-WHAT_IS_THE_COMMAND_LINE_TOOLS_PACKAGE_) installed, they will be automatically installed.

### Usage

After running the installation command, the script will request administrator access (`sudo`). It will then proceed with the setup process, providing updates in the terminal for each step. No further interaction is required.

### Contributions
Like, everyone.

Feel free to fork, submit issues, or PRs to help improve the script for the community.
