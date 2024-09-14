#!/usr/bin/env bash
# v.0.1919

# JJ Smiley
# Forked from: YANMSS (Yet Another New Mac Setup Script)
# https://github.com/mikeprivette/yanmss
# Original Author: Mike Privette

# Automated Mac Setup Script - Updated 9-24
# This script installs essential command-line tools and applications mostly using Homebrew.

echo "Starting Mac setup..."
echo

# Install Xcode Command Line Tools if not already installed.
if ! xcode-select -p > /dev/null 2>&1; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install

    # Wait until the Command Line Tools are installed
    echo "Waiting for Xcode Command Line Tools installation to complete..."
    until xcode-select -p > /dev/null 2>&1; do
        sleep 5
    done
    echo "Xcode Command Line Tools installed."
fi

# Request and keep the administrator password active.
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Initiate iCloud Folder Downloads
echo "Initiating iCloud folder downloads..."

# Folders to download
ICLOUD_FOLDERS=(
    "${HOME}/Documents/NewMacSetup"
    "${HOME}/Documents/Applications/AdGuard/Mac"
    "${HOME}/Documents/Development/Terminal"
    "${HOME}/Documents/Fonts"
)

# Check if brctl command is available
if ! command -v brctl >/dev/null 2>&1; then
    echo "brctl command not found. Skipping iCloud folder downloads."
else
    for folder in "${ICLOUD_FOLDERS[@]}"; do
        echo "Starting download of $folder..."
        brctl download "$folder" &
    done
    echo "iCloud folder downloads initiated in the background."
fi

# Close any open System Preferences panes to prevent them from overriding settings we're about to change
osascript -e 'tell application "System Preferences" to quit' || echo "Failed to close System Preferences"

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Prevent macOS from reopening windows when logging back in
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

# Reveal IP address, hostname, OS version, etc., when clicking the clock in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Use column view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Finder: Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Set Applications as the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Applications/"

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Expand the following File Info panes: “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Set the icon size of Dock items to 36 pixels for optimal size/screen real estate
defaults write com.apple.dock tilesize -int 36

# Set email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Make Safari's search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Unhide the Library folder
echo "Unhiding your Library folder..."
chflags nohidden ~/Library

# Restart Finder to apply changes
killall Finder

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
    echo
    echo "Homebrew already installed."
fi

# Update and upgrade Homebrew
echo "Updating and upgrading Homebrew..."
brew update && brew upgrade

# Shell Setup: Oh My Zsh
echo "Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Configure .zshrc for Oh My Zsh
echo "Configuring .zshrc for Oh My Zsh..."
sed -i '' 's/^ZSH_THEME="[^"]*"/ZSH_THEME="xiong-chiamiov"/' ~/.zshrc
sed -i '' '/^plugins=/c\
plugins=(\
    brew\
    macos\
    aliases\
    alias-finder\
    colored-man-pages\
    colorize\
    copypath\
    dircycle\
    command-not-found\
    nmap\
)
' ~/.zshrc

# Oh My Zsh configuration updated. Sourcing .zshrc.
echo "Oh My Zsh configuration updated. Sourced new .zshrc."
source /${HOME}/.zshrc

# Install JetBrains Mono Font
echo "Installing JetBrains Mono font..."
brew install --cask font-jetbrains-mono

# Python and pip Installation
echo "Checking for Python..."
if ! command -v python3 >/dev/null 2>&1; then
    echo "Installing Python..."
    brew install python
else
    echo "Python already installed."
fi

# Install applications from Brewfile
# While in testing phase, the path below will not work. Until testing is
# complete, the Brewfile will be located in the same directory as this script.
BREWFILE=./Brewfile                      # Temporary path for testing.
# When testing is complete and this script works as expected, uncomment the
# line below and comment out the line above.
# BREWFILE="${HOME}/Documents/NewMacSetup/Brewfile"

if [[ -f "$BREWFILE" ]]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file "$BREWFILE"
else
    echo "Brewfile not found at $BREWFILE!"
fi

# Clean up: Remove outdated versions
echo "Running brew cleanup..."
brew cleanup && brew autoremove

echo
echo "Mac setup script completed."
echo "Some changes may require a logout/restart to take full effect."