#!/bin/bash

# Remove Btop entry for one that runs in Ghostty
sudo rm -rf /usr/share/applications/btop.desktop

# App doesn't do anything when started from the app grid
sudo rm -rf /usr/share/applications/org.flameshot.Flameshot.desktop

# Remove the ImageMagick icon
sudo rm -rf /usr/share/applications/display-im6.q16.desktop
sudo rm -rf /usr/share/applications/display-im7.q16.desktop

# Replacing stock monitors with btop (24.04 System Monitor / 26.04 Resources)
sudo rm -rf /usr/share/applications/org.gnome.SystemMonitor.desktop
sudo rm -rf /usr/share/applications/org.gnome.Resources.desktop
sudo rm -rf /usr/share/applications/org.gnome.PowerStats.desktop

# Hide stock GNOME Terminal / Ptyxis from grid if present (Ghostty is default)
sudo rm -rf /usr/share/applications/org.gnome.Terminal.desktop
sudo rm -rf /usr/share/applications/org.gnome.Ptyxis.desktop

# We added our own meant for Ghostty
sudo rm -rf /usr/local/share/applications/nvim.desktop
sudo rm -rf /usr/local/share/applications/vim.desktop

# Create folders (no LibreOffice — purged with Ubuntu bloat)
# Desktop IDs cover both 24.04 (eog, etc.) and 26.04 (Loupe, Papers, Showtime, …)
gsettings set org.gnome.desktop.app-folders folder-children "['Utilities', 'Sundry', 'YaST', 'Updates', 'Xtra', 'WebApps']"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Updates/ name 'Install & Update'
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Updates/ apps "['software-properties-drivers.desktop', 'software-properties-gtk.desktop', 'update-manager.desktop', 'firmware-updater_firmware-updater.desktop', 'firmware-updater.desktop']"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Xtra/ name 'Xtra'
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Xtra/ apps "['org.Characters.desktop', 'org.gnome.Characters.desktop', 'gnome-language-selector.desktop', 'org.gnome.Logs.desktop', 'org.gnome.eog.desktop', 'org.gnome.Loupe.desktop', 'org.gnome.Evince.desktop', 'org.gnome.Papers.desktop', 'org.gnome.Totem.desktop', 'org.gnome.Showtime.desktop', 'org.gnome.Sysprof.desktop']"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/WebApps/ name 'Web Apps'
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/WebApps/ apps "@as []"
