#!/usr/bin/env bash

# JJ Smiley
# Forked from: YANMSS (Yet Another New Mac Setup Script)
# https://github.com/mikeprivette/yanmss
# Original Author: Mike Privette

# Automated Mac Setup Script - Updated 9-24
# This script installs essential command-line tools and applications mostly using Homebrew.

echo "Starting Mac setup..."

# Install Xcode Command Line Tools if not already installed. 
xcode-select -p > /dev/null 2>&1
if [ $# != 0 ]; then
  # Uninstall if already present (or) if an older version is installed
  sudo rm -rf $(xcode-select -p)
  xcode-select --install
  sudo xcodebuild -license accept
fi

# Request and keep the administrator password active.
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Check the system processor: M1/M2/M3 (ARM) or Intel.
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    echo "M1/M2/M3 Processor detected. Proceeding with compatible installations."
else
    echo "Intel Processor detected. Proceeding with installations."
fi

# Homebrew Installation: Install Homebrew if not already installed.
echo "Checking for Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    echo "Adding Homebrew to PATH..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed."
fi

# Update and Upgrade Homebrew: Ensure Homebrew is up-to-date.
echo "Updating and Upgrading Homebrew..."
brew update
brew upgrade

# Unhide the Library folder.
echo "Unhiding your Library folder..."
chflags nohidden ~/Library

# Restart Finder to apply changes using AppleScript.
osascript -e 'tell application "Finder" to quit'
osascript -e 'tell application "Finder" to launch'

# Shell Setup: Oh My Zsh.
echo "Installing oh-my-zsh..."
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Configure .zshrc for Oh My Zsh
echo "Configuring .zshrc for Oh My Zsh..."
sed -i '' 's/^ZSH_THEME=".*"$/ZSH_THEME="xiong-chiamiov"/' ~/.zshrc
sed -i '' 's/^plugins=(.*)$/plugins=(brew macos\
                                    aliases\
                                    alias-finder\
                                    colored-man-pages\
                                    colorize\
                                    copypath\
                                    dircycle\
                                    command-not-found\
                                    macos\
                                    nmap)/' ~/.zshrc
# Here Document: Append custom configuration to .zshrc.
# cat << 'EOF' >> ~/.zshrc
# At this time, there is nothing here to add.

# JetBrains Font Installation.
echo "Installing Powerline fonts..."
brew install --cask font-jetbrains-mono

# Python and pip Installation: Install Python and pip (pip is included with Python).
echo "Checking for Python..."
if ! command -v python3 >/dev/null 2>&1; then
    echo "Installing Python..."
    brew install python
else
    echo "Python already installed."
fi

# Core Applications Installation: Install essential applications using Homebrew.
echo "Installing core applications..."
brew install --casks visual-studio-code 1password powershell google-chrome firefox\
                     speedtest adobe-acrobat-pro adobe-creative-cloud\
                     typeface microsoft-office microsoft-teams microsoft-remote-desktop\
                     onedrive soulver parallels microsoft-edge termius backblaze

brew install wget genact nmap speedtest-cli

# Clean up: Remove outdated versions from the cellar.
echo "Running brew cleanup..."
brew cleanup
brew autoremove

# We're done!
echo "Mac setup script completed."
