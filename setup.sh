#!/usr/bin/env zsh
# v.0.16.1732

# JJ Smiley
# Forked from: YANMSS (Yet Another New Mac Setup Script)
# https://github.com/mikeprivette/yanmss
# Original Author: Mike Privette

# Automated Mac Setup Script - Updated 9-24
# This script installs essential command-line tools and applications mostly using Homebrew.

# Functions for the script go here:

# Function to create a Dock item for the specified application
dock_item() {
    local app_path="$1"
    printf '<dict>
        <key>tile-data</key>
        <dict>
            <key>file-data</key>
            <dict>
                <key>_CFURLString</key>
                <string>%s</string>
                <key>_CFURLStringType</key>
                <integer>0</integer>
            </dict>
        </dict>
    </dict>' "$app_path"
}

echo "Starting Mac setup..."
echo

# Request and keep the administrator password active.
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Check for and install any macOS updates
echo "Checking for macOS updates..."
sudo softwareupdate --background
sudo softwareupdate --install-rosetta --agree-to-license > /dev/null 2>&1 &
sudo softwareupdate -d -a > /dev/null 2>&1 &

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
        brctl download "$folder" > /dev/null 2>&1 &
    done
    echo "iCloud folder downloads initiated in the background."
fi

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

# First, let's give this shiny new Mac (or rebuilt Mac) a name.
# Set Computer Name
echo "Configuring computer name..."

# Prompt the user for the new computer name
read -p "Enter the new computer name: " NEW_COMPUTER_NAME

if [ -z "$NEW_COMPUTER_NAME" ]; then
    echo "No computer name provided. Skipping computer name configuration."
else
    # Set the new computer name
    sudo scutil --set ComputerName "$NEW_COMPUTER_NAME"
    sudo scutil --set HostName "$NEW_COMPUTER_NAME"
    sudo scutil --set LocalHostName "$NEW_COMPUTER_NAME"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$NEW_COMPUTER_NAME"
    echo "Computer name set to '$NEW_COMPUTER_NAME'."
fi

# Close any open System Preferences panes to prevent them from overriding settings we're about to change
osascript -e 'tell application "System Preferences" to quit' || echo "Failed to close System Preferences"

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Prevent macOS from reopening windows when logging back in
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

# Decrease key repeat time and increase key repeat rate
defaults write -g InitialKeyRepeat -int 12 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)

# Hide "Recent Tags" from Finder Sidebar.
defaults write com.apple.Finder ShowRecentTags -bool false

# Remove items from the trash after 30 days.
defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true"

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
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ${HOME}/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Add :FK_StandardViewSettings:IconViewSettings:showItemInfo bool true" "${HOME}/Library/Preferences/com.apple.finder.plist"
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ${HOME}/Library/Preferences/com.apple.finder.plist

# Set the icon size of Dock items to 36 pixels for optimal size/screen real estate
defaults write com.apple.dock tilesize -int 36

# Set email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Make Safari's search banners default to Contains instead of Starts With
 sudo defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Unhide the Library folder
echo "Unhiding your Library folder..."
chflags nohidden ${HOME}/Library

# Restart Finder to apply changes
killall Finder

# Homebrew Installation: Install Homebrew if not already installed.
echo "Checking for Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."

# Define the log file path
LOGFILE="/tmp/homebrew_install.log"

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update and upgrade Homebrew
echo "Updating and upgrading Homebrew..."
brew update && brew upgrade

# Shell Setup: Oh My Zsh
echo "Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Backup .zshrc before we make any changes to it
cp ${HOME}/.zshrc ${HOME}/.zshrc.backup

# Configure .zshrc for Oh My Zsh
echo "Configuring .zshrc for Oh My Zsh..."

# Update the ZSH_THEME line
sed -i '' 's/^ZSH_THEME="[^"]*"/ZSH_THEME="xiong-chiamiov"/' "${HOME}/.zshrc"

# Update the plugins line
sed -i '' 's/^plugins=.*/plugins=(brew macos aliases alias-finder colored-man-pages colorize copypath dircycle command-not-found nmap)/' "${HOME}/.zshrc"

# Source the updated .zshrc file
echo "Reloading .zshrc to apply changes..."
source "${HOME}/.zshrc"

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
# Prompt the user for the path to the Brewfile
read -p "Enter the path to the Brewfile: " BREWFILE

# Check if the Brewfile exists and install the applications
if [[ -f "$BREWFILE" ]]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file "$BREWFILE"
else
    echo "Brewfile not found at $BREWFILE!"
fi

# Update and upgrade Homebrew
echo "Updating and upgrading Homebrew..."

if ! (brew update >/dev/null 2>&1 && brew upgrade >/dev/null 2>&1); then
    echo "Homebrew update/upgrade failed. Exiting."
    exit 1
fi

# Now, let's customize the Dock. We'll remove all existing items and add the ones we want.
# List of applications to add to the Dock
apps=(
    "/System/Applications/Messages.app"
    "/System/Applications/Mail.app"
    "/Applications/Safari.app"
    "/System/Applications/Photos.app"
    "/System/Applications/Calendar.app"
    "/Applications/Microsoft Outlook.app"
    "/Applications/Microsoft Teams.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Termius.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Notes.app"
    "/Applications/Adobe Illustrator 2024/Adobe Illustrator 2024.app"
    "/Applications/Adobe InDesign 2024/Adobe InDesign 2024.app"
    "/System/Applications/Music.app"
    "/System/Applications/Podcasts.app"
    "/System/Applications/News.app"
)

# Clear existing persistent apps in the Dock
echo "Clearing existing persistent apps in the Dock..."
defaults write com.apple.dock persistent-apps -array

# Add each application to the Dock if it exists
echo "Adding applications to the Dock..."
for app in "${apps[@]}"; do
    if [ -e "$app" ]; then
        defaults write com.apple.dock persistent-apps -array-add "$(dock_item "$app")"
    else
        echo "Application not found: $app"
    fi
done

# Restart the Dock to apply changes
echo "Restarting the Dock..."
killall Dock

echo
echo "Mac setup script completed."
echo "Some changes may require a logout/restart to take full effect."