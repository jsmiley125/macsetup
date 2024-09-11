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

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Set Applications as the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://Applications/"

# Finder: Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Use column view in all Finder windows by default (codes for the other view modes: `icnv`, `clmv`, `Flwv`)
defaults write com.apple.finder FXPreferredViewStyle -string "Clmv"

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

#"Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#"Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

#"Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate"
defaults write com.apple.dock tilesize -int 36

#"Setting email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

#"Making Safari's search banners default to Contains instead of Starts With"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Prevent macOS from reopening Windows when logging back in
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

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

####
# The block below was originally written with the expection that we
# would be using 'brew install' to install all software.
# However, we can probaly use a "brew budle" command to get this completed
# and potentially provide a better more inclusive install experience.
# For now, we are commenting out the block below and then using the next
# block to install a brew bundle.
####

# # Core Applications Installation: Install essential applications using Homebrew.
# echo "Installing core applications..."
# brew install --casks visual-studio-code 1password powershell google-chrome firefox\
#                      speedtest adobe-acrobat-pro adobe-creative-cloud\
#                      typeface microsoft-office microsoft-teams microsoft-remote-desktop\
#                      onedrive soulver parallels microsoft-edge termius backblaze\
#                      spotify

# brew install mas wget genact nmap speedtest-cli

# Using "brew bundle" to install our applications:
brew bundle --file /Users/$USER/Documents/NewMacSetup/Brewfile

# Clean up: Remove outdated versions from the cellar.
echo "Running brew cleanup..."
brew cleanup
brew autoremove

# We're done!
echo "Mac setup script completed."
